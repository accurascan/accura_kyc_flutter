import Flutter
import UIKit

public class SwiftAccuraKycFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "getMrzAndCountryList", binaryMessenger: registrar.messenger())
        let instance = SwiftAccuraKycFlutterPlugin()
        
        let viewFactory = FlutterUnityViewFactory.init(binaryMessenger: registrar.messenger())
        registrar.register(viewFactory, withId: "scan_preview")
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("SomeString"+call.method)
        switch(call.method){
        case "getMrzList":
            MrzListClass().MrzListClass(call: call, result: result)//(call,result)
            break
        case "updateFilters":
            UpdateFilterClass().UpdateFilterClass(call: call, result: result)//UpdateFilterClass(call: call, result: result)
            
            break
        case "checkLiveness":
            //        LivenessClass().window = FlutterViewController().view.window
            //        LivenessClass().LivenessClass(call: call, result: result,vc: FlutterViewController())
            
            //        let bundle = Bundle.init(identifier: "org.cocoapods.accura-kyc-flutter")
            let myBundle = Bundle(for: Self.self)
            
            // Get the URL to the resource bundle within the bundle
            // of the current class.
            guard let resourceBundleURL = myBundle.url(
                    forResource: "accura_kyc_flutter", withExtension: "bundle")
            else { fatalError("accura_kyc_flutter.bundle not found!") }
            
            // Create a bundle object for the bundle found at that URL.
            guard let resourceBundle = Bundle(url: resourceBundleURL)
            else { fatalError("Cannot access accura_kyc_flutter.bundle!") }
            
            let viewController = UIStoryboard.init(name: "Liveness", bundle: resourceBundle).instantiateViewController(withIdentifier: "LIvenessViewController") as! LIvenessViewController
            viewController.call=call
            viewController.result=result
            viewController.isCheckLiveness=true
            viewController.win = FlutterViewController().view.window
            viewController.VC = FlutterViewController()
            //        self.present(viewController, animated: true, completion: nil)
            //FlutterViewController().present(viewController, animated: true, completion: nil)
            UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: nil)
            break;
        case "start_facematch" :
            let myBundle = Bundle(for: Self.self)
            
            // Get the URL to the resource bundle within the bundle
            // of the current class.
            guard let resourceBundleURL = myBundle.url(
                    forResource: "accura_kyc_flutter", withExtension: "bundle")
            else { fatalError("accura_kyc_flutter.bundle not found!") }
            
            // Create a bundle object for the bundle found at that URL.
            guard let resourceBundle = Bundle(url: resourceBundleURL)
            else { fatalError("Cannot access accura_kyc_flutter.bundle!") }
            
            let viewController = UIStoryboard.init(name: "Liveness", bundle: resourceBundle).instantiateViewController(withIdentifier: "LIvenessViewController") as! LIvenessViewController
            viewController.call=call
            viewController.result=result
            viewController.isCheckLiveness=false
            viewController.win = FlutterViewController().view.window
            viewController.VC = FlutterViewController()
            //        self.present(viewController, animated: true, completion: nil)
            //FlutterViewController().present(viewController, animated: true, completion: nil)
            UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: nil)
            break;
            
        case "start_facematching":
            FaceMatchResultClass().FaceMatchResultClass(call: call, result: result)
            break;
        default:
            break
        }
        
    }
    
}
