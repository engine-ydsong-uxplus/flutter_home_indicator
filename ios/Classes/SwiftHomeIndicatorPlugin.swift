import Flutter
import UIKit

class HomeIndicatorAwareFlutterViewController : FlutterViewController {
  var hidingHomeIndicator: Bool = false

  @available(iOS 11.0, *)
  override func prefersHomeIndicatorAutoHidden() -> Bool {
    return hidingHomeIndicator
  }

  func setHidingHomeIndicator(newValue: Bool) {
    if (newValue != hidingHomeIndicator) {
      hidingHomeIndicator = newValue
      if #available(iOS 11.0, *) {
        setNeedsUpdateOfHomeIndicatorAutoHidden()
      } else {
        // Fallback on earlier versions: do nothing
      }
    }
  }
}

public class SwiftHomeIndicatorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "home_indicator", binaryMessenger: registrar.messenger())
    let instance = SwiftHomeIndicatorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  private func controller() -> HomeIndicatorAwareFlutterViewController? {
    guard let window = UIApplication.shared.keyWindow else { print("no window"); return nil }
    guard let rvc = window.rootViewController else { print("no rvc"); return nil }
    if let rvc = rvc as? HomeIndicatorAwareFlutterViewController { return rvc }
    guard let fvc = rvc as? FlutterViewController else { return nil }
    object_setClass(fvc, HomeIndicatorAwareFlutterViewController.self)
    let newController = fvc as! HomeIndicatorAwareFlutterViewController
    window.rootViewController = newController as UIViewController?
    return newController
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let noController = FlutterError(code: "NO_CONTROLLER", message: "Error fetching HomeIndicatorAwareFlutterViewController", details: nil);
    if (call.method == "hide") {
      guard let controller = controller() else { result(noController); return }
      controller.setHidingHomeIndicator(newValue: true)
      result(nil)
    } else if (call.method == "show") {
      guard let controller = controller() else { result(noController); return }
      controller.setHidingHomeIndicator(newValue: false)
      result(nil)
    } else if (call.method == "isHidden") {
      guard let controller = controller() else { result(noController); return }
      result(controller.hidingHomeIndicator)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}