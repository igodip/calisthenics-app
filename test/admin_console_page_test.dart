import 'package:calisync/admin/admin_models.dart';
import 'package:calisync/admin/pages/admin_console_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups assignments by trainer and keeps alphabetical order', () {
    final assignments = [
      const AdminAssignment(
        traineeId: 't1',
        traineeName: 'Alice',
        trainerId: 'r2',
        trainerName: 'Coach B',
      ),
      const AdminAssignment(
        traineeId: 't2',
        traineeName: 'Bob',
        trainerId: 'r1',
        trainerName: 'Coach A',
      ),
      const AdminAssignment(
        traineeId: 't3',
        traineeName: 'Charlie',
        trainerId: 'r1',
        trainerName: 'Coach A',
      ),
    ];

    final groups = groupAssignmentsByTrainer(assignments);

    expect(groups.map((group) => group.trainerName), ['Coach A', 'Coach B']);
    expect(
      groups.first.assignments.map((assignment) => assignment.traineeName),
      ['Bob', 'Charlie'],
    );
  });

  test('filters assignments by trainee or trainer name', () {
    final assignments = [
      const AdminAssignment(
        traineeId: 't1',
        traineeName: 'Alice',
        trainerId: 'r1',
        trainerName: 'Coach A',
      ),
      const AdminAssignment(
        traineeId: 't2',
        traineeName: 'Bruno',
        trainerId: 'r2',
        trainerName: 'Coach B',
      ),
    ];

    final groups = groupAssignmentsByTrainer(assignments, query: 'bruno');

    expect(groups, hasLength(1));
    expect(groups.single.trainerName, 'Coach B');
    expect(groups.single.assignments.single.traineeName, 'Bruno');
  });
}
