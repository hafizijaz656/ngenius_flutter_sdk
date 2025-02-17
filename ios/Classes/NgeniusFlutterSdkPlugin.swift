import Flutter
import UIKit
import NISdk


public class NgeniusFlutterSdkPlugin: NSObject, FlutterPlugin, CardPaymentDelegate {


private var methodChannel: FlutterMethodChannel!
private var resultCallback: FlutterResult?


  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ngenius_flutter_sdk", binaryMessenger: registrar.messenger())
    let instance = NgeniusFlutterSdkPlugin()
    instance.methodChannel = channel
    NISdk.initialize()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "launchCardPayment":
                guard let args = call.arguments as? [String: Any] else {
                        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments are missing or invalid", details: nil))
                        return
                    }
                launchCardPayment(args: args, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  private func launchCardPayment(args: [String: Any], result: @escaping FlutterResult) {

          self.resultCallback = result

       guard let orderResponseMap = args["orderJsonObject"] as? [String: Any], !orderResponseMap.isEmpty else {
           result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid orderResponse", details: nil))
           return
       }

          do {
              let jsonData = try JSONSerialization.data(withJSONObject: orderResponseMap, options: [])
              let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: jsonData)

              guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
                  result(FlutterError(code: "NO_ROOT_VIEW_CONTROLLER",
                                    message: "Root view controller is not available",
                                    details: nil))
                  return
              }

              let sharedSDKInstance = NISdk.sharedInstance
              sharedSDKInstance.showCardPaymentViewWith(
                  cardPaymentDelegate: self,
                  overParent: viewController,
                  for: orderResponse
              )

              DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                  self.removeButtonText(from: viewController.view)
              }

          } catch let error {
              result(FlutterError(code: "ORDER_RESPONSE_ERROR",
                                message: "Failed to parse orderResponse: \(error.localizedDescription)",
                                details: nil))
          }
      }
      private func removeButtonText(from view: UIView) {
              let allButtons = view.subviews.compactMap { $0 as? UIButton }

              for button in allButtons {
                  if let title = button.title(for: .normal), title.contains("0") {
                      button.setTitle("Pay", for: .normal)
                      button.setImage(nil, for: .normal)
                  }
              }
          }

      public func paymentDidComplete(with status: PaymentStatus) {
              var resultDict: [String: Any]

              switch status {
              case .PaymentSuccess:
                  resultDict = [
                      "code": 200,
                      "status": "success",
                      "reason": "PAYMENT_SUCCESSFUL",
                      "result": "success"
                  ]
              case .PaymentFailed:
                  resultDict = [
                      "code": 0,
                      "status": "failed",
                      "reason": "STATUS_PAYMENT_FAILED",
                      "result": "failed"
                  ]
              case .PaymentCancelled:
                  resultDict = [
                      "code": 401,
                      "status": "canceled",
                      "reason": "CANCELLED_BY_USER",
                      "result": "canceled"
                  ]
              @unknown default:
                  resultDict = [
                      "code": -1,
                      "status": "unknown",
                      "reason": "STATUS_GENERIC_ERROR",
                      "result": "unknown"
                  ]
              }

              if let jsonData = try? JSONSerialization.data(withJSONObject: resultDict),
                 let jsonString = String(data: jsonData, encoding: .utf8) {
                 if let resultCallback = self.resultCallback {
                         resultCallback(jsonString)
                         self.resultCallback = nil
                     }
              }
          }
         public func authorizationDidComplete(with status: AuthorizationStatus) {
             if status == .AuthFailed {
                 let resultDict: [String: Any] = [
                     "code": -1,
                     "status": "failed",
                     "reason": "STATUS_GENERIC_ERROR",
                     "result": "auth_failed"
                 ]

                 if let jsonData = try? JSONSerialization.data(withJSONObject: resultDict),
                    let jsonString = String(data: jsonData, encoding: .utf8) {
                     if let resultCallback = self.resultCallback {
                         resultCallback(jsonString)
                         self.resultCallback = nil
                     }
                 }
             }
         }
}