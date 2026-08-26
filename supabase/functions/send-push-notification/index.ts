import { createClient } from 'npm:@supabase/supabase-js@2';
import { GoogleAuth } from 'npm:google-auth-library@9.15.1';

import { corsHeaders } from '../_shared/cors.ts';

type PushEvent =
  | 'trainee_feedback_created'
  | 'trainer_feedback_answered'
  | 'trainer_plan_updated'
  | 'trainer_coach_tip_updated'
  | 'trainer_payment_updated';

type Notification = {
  recipientIds: string[];
  title: string;
  body: string;
  route: string;
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

const one = <T>(value: T | T[] | null): T | null =>
  Array.isArray(value) ? (value[0] ?? null) : value;

const short = (value: string, max = 140) =>
  value.length <= max ? value : `${value.substring(0, max - 1)}…`;

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  try {
    const authorization = request.headers.get('Authorization');
    if (!authorization?.startsWith('Bearer ')) {
      return json({ error: 'Authentication required' }, 401);
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authorization } },
    });
    const admin = createClient(supabaseUrl, serviceRoleKey);
    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) return json({ error: 'Invalid session' }, 401);

    const payload = await request.json() as {
      type?: PushEvent;
      entityId?: string;
    };
    if (!payload.type || !payload.entityId || payload.entityId.length > 100) {
      return json({ error: 'Invalid notification event' }, 400);
    }

    const notification = await resolveNotification(
      admin,
      user.id,
      payload.type,
      payload.entityId,
    );
    if (!notification) return json({ error: 'Event not found' }, 404);
    if (notification.recipientIds.length === 0) {
      return json({ sent: 0, reason: 'No recipients' });
    }

    const { data: tokenRows, error: tokenError } = await admin
      .from('push_device_tokens')
      .select('token')
      .in('user_id', notification.recipientIds);
    if (tokenError) throw tokenError;
    const tokens = [...new Set((tokenRows ?? []).map((row) => row.token as string))];
    if (tokens.length === 0) return json({ sent: 0, reason: 'No registered devices' });

    const serviceAccountText = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
    if (!serviceAccountText) throw new Error('FIREBASE_SERVICE_ACCOUNT_JSON is not set');
    const serviceAccount = JSON.parse(serviceAccountText);
    const auth = new GoogleAuth({
      credentials: serviceAccount,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    });
    const authClient = await auth.getClient();
    const accessTokenResult = await authClient.getAccessToken();
    const accessToken = typeof accessTokenResult === 'string'
      ? accessTokenResult
      : accessTokenResult.token;
    if (!accessToken) throw new Error('Unable to obtain an FCM access token');

    const invalidTokens: string[] = [];
    let sent = 0;
    await Promise.all(tokens.map(async (token) => {
      const response = await fetch(
        `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
        {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            message: {
              token,
              notification: {
                title: notification.title,
                body: notification.body,
              },
              data: { route: notification.route, type: payload.type },
              android: {
                priority: 'high',
                notification: { sound: 'default' },
              },
              apns: { payload: { aps: { sound: 'default' } } },
            },
          }),
        },
      );
      if (response.ok) {
        sent++;
        return;
      }
      const errorText = await response.text();
      if (response.status === 404 || errorText.includes('UNREGISTERED')) {
        invalidTokens.push(token);
        return;
      }
      console.error(`FCM send failed (${response.status}): ${errorText}`);
    }));

    if (invalidTokens.length > 0) {
      await admin.from('push_device_tokens').delete().in('token', invalidTokens);
    }
    return json({ sent, invalidTokensRemoved: invalidTokens.length });
  } catch (error) {
    console.error(error);
    return json({ error: 'Unable to send notification' }, 500);
  }
});

async function resolveNotification(
  admin: ReturnType<typeof createClient>,
  callerId: string,
  type: PushEvent,
  entityId: string,
): Promise<Notification | null> {
  if (type === 'trainee_feedback_created') {
    const { data } = await admin
      .from('trainee_feedbacks')
      .select('trainee_id, message, trainees(name, trainee_trainers(trainer_id))')
      .eq('id', entityId)
      .eq('trainee_id', callerId)
      .maybeSingle();
    if (!data) return null;
    const trainee = one(data.trainees as {
      name?: string;
      trainee_trainers?: { trainer_id: string }[];
    } | {
      name?: string;
      trainee_trainers?: { trainer_id: string }[];
    }[] | null);
    const assignments = trainee?.trainee_trainers ?? [];
    return {
      recipientIds: assignments.map((row) => row.trainer_id),
      title: `${trainee?.name?.trim() || 'A trainee'} sent feedback`,
      body: short((data.message as string | null)?.trim() || 'New training update'),
      route: 'trainer_feedback',
    };
  }

  if (type === 'trainer_feedback_answered') {
    const { data } = await admin
      .from('trainee_feedbacks')
      .select('trainee_id, answer_message')
      .eq('id', entityId)
      .not('answered_at', 'is', null)
      .maybeSingle();
    if (!data || !await isAssignedTrainer(admin, callerId, data.trainee_id)) return null;
    return {
      recipientIds: [data.trainee_id],
      title: 'Your trainer replied',
      body: short((data.answer_message as string | null)?.trim() || 'Open CaliSync to read the reply'),
      route: 'trainee_feedback',
    };
  }

  if (type === 'trainer_plan_updated') {
    const { data } = await admin
      .from('workout_plans')
      .select('trainee_id, title')
      .eq('id', entityId)
      .maybeSingle();
    if (!data || !await isAssignedTrainer(admin, callerId, data.trainee_id)) return null;
    return {
      recipientIds: [data.trainee_id],
      title: 'Workout plan updated',
      body: short((data.title as string | null)?.trim() || 'Your trainer updated your workout plan'),
      route: 'trainee_plan',
    };
  }

  if (type === 'trainer_coach_tip_updated') {
    if (!await isAssignedTrainer(admin, callerId, entityId)) return null;
    const { data } = await admin
      .from('trainee_trainers')
      .select('coach_tip')
      .eq('trainer_id', callerId)
      .eq('trainee_id', entityId)
      .maybeSingle();
    return {
      recipientIds: [entityId],
      title: 'New tip from your trainer',
      body: short((data?.coach_tip as string | null)?.trim() || 'Open CaliSync to see the update'),
      route: 'trainee_home',
    };
  }

  if (type === 'trainer_payment_updated') {
    if (!await isAssignedTrainer(admin, callerId, entityId)) return null;
    const monthStart = new Date().toISOString().substring(0, 7) + '-01';
    const { data } = await admin
      .from('trainee_monthly_payments')
      .select('paid')
      .eq('trainee_id', entityId)
      .eq('month_start', monthStart)
      .maybeSingle();
    return {
      recipientIds: [entityId],
      title: 'Payment status updated',
      body: data?.paid ? 'Your monthly payment is marked as paid' : 'Your monthly payment status changed',
      route: 'trainee_home',
    };
  }

  return null;
}

async function isAssignedTrainer(
  admin: ReturnType<typeof createClient>,
  trainerId: string,
  traineeId: string,
) {
  const { data } = await admin
    .from('trainee_trainers')
    .select('trainer_id')
    .eq('trainer_id', trainerId)
    .eq('trainee_id', traineeId)
    .maybeSingle();
  return data != null;
}
