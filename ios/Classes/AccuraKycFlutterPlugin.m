#import "AccuraKycFlutterPlugin.h"
#if __has_include(<accura_kyc_flutter/accura_kyc_flutter-Swift.h>)
#import <accura_kyc_flutter/accura_kyc_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "accura_kyc_flutter-Swift.h"
#endif

@implementation AccuraKycFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAccuraKycFlutterPlugin registerWithRegistrar:registrar];
}
@end
