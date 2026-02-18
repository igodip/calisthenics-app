import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var secureTextField: UITextField?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    enableScreenSecurity()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func enableScreenSecurity() {
    guard let window = window else { return }

    let textField = UITextField(frame: .zero)
    textField.isSecureTextEntry = true
    textField.isUserInteractionEnabled = false
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.backgroundColor = .clear
    textField.text = " "

    window.addSubview(textField)
    NSLayoutConstraint.activate([
      textField.leadingAnchor.constraint(equalTo: window.leadingAnchor),
      textField.trailingAnchor.constraint(equalTo: window.trailingAnchor),
      textField.topAnchor.constraint(equalTo: window.topAnchor),
      textField.bottomAnchor.constraint(equalTo: window.bottomAnchor)
    ])

    if let superlayer = window.layer.superlayer {
      superlayer.addSublayer(textField.layer)
      textField.layer.sublayers?.first?.addSublayer(window.layer)
    }

    secureTextField = textField
  }
}
