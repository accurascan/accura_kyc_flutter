import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var orientationLock = UIInterfaceOrientationMask.portrait
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
//    override func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return self.orientationLock
//    }
//    
//    struct AppUtility {
//
//        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
//        
//            if let delegate = UIApplication.shared.delegate as? AppDelegate {
//                delegate.orientationLock = orientation
//            }
//        }
//
//        /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
//        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
//       
//            self.lockOrientation(orientation)
//            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
//            UINavigationController.attemptRotationToDeviceOrientation()
//        }
//
//    }
}
