import Flutter
import UIKit
import YandexLoginSDK

enum PluginMethod: String {
    case signIn
    case signOut
}

enum InitSdkArg: String {
    case clientId
}

public class SwiftFlutterLoginYandexPlugin: NSObject, FlutterPlugin {

    private lazy var _loginDelegate = LogInDelegate()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_login_yandex", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterLoginYandexPlugin()
        let clientId = Bundle.main.object(forInfoDictionaryKey: "YAClientId") as? String
        do {
            try YandexLoginSDK.shared.activate(with: clientId!)
        } catch let error {
            print("err YandexLoginSDK: \(error.localizedDescription)")
        }
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let method = PluginMethod(rawValue: call.method) else {
            result(FlutterMethodNotImplemented)
            return
        }

        switch method {
            case .signIn:
                logIn(result: result)
            case .signOut:
                logOut(result: result)
        }
    }

    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
       do {
          try YandexLoginSDK.shared.handleOpenURL(url)
       } catch {
          return false
       }
       return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        do {
           try YandexLoginSDK.shared.tryHandleUserActivity(userActivity)
        } catch {
           return false
        }
        return true
    }

    private func logIn(result: @escaping FlutterResult) {
        guard let viewController: UIViewController = UIApplication.shared.keyWindow?.rootViewController else {
              result(nil)
              return
          }
        _loginDelegate.startLogin(result: result)
        do {
            try YandexLoginSDK.shared.authorize(with: viewController)
        } catch {
            result(nil)
        }
    }
    
    private func logOut(result: @escaping FlutterResult) {
        do {
          try YandexLoginSDK.shared.logout()
          result(nil)
        } catch {
          result(nil)
        }
        YandexLoginSDK.shared.remove(observer: _loginDelegate)
    }
}

class LogInDelegate : NSObject, YandexLoginSDKObserver {

    private var _pendingLoginResult: FlutterResult?

    public func startLogin(result: @escaping FlutterResult) {
        if let prevResult = _pendingLoginResult {
            prevResult(["error": "Interrupted by another login call"])
        }
        YandexLoginSDK.shared.add(observer: self)
        _pendingLoginResult = result
    }

    public func didFinishLogin(with result: Result<LoginResult, Error>) {
        if let pendingResult = _pendingLoginResult {
            _pendingLoginResult = nil
            switch result{
            case .success(let loginResult):
                let token = loginResult.token
                pendingResult([
                    "token": token,
                ])
            case .failure(let error):
                pendingResult([
                    "error": error.localizedDescription
                ])
            }
        }
       //YandexLoginSDK.shared.remove(observer:self)
    }
}
