#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>

//#import <BrazeUI/BrazeUI-Swift.h>
//#import "BrazeUI.h"
#import <BrazeKit/BrazeKit-Swift.h>
#import "BrazeReactBridge.h"
#import "BrazeReactUtils.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSString* brazeKey = @"BRAZE_KEY_IOS";
  NSString* brazeEndpoint = @"BRAZE_SDK_ENDPOINT";
  
  BRZConfiguration *configuration = [[BRZConfiguration alloc] initWithApiKey:brazeKey
                                                                    endpoint:brazeEndpoint];
  configuration.triggerMinimumTimeInterval = 1;
  configuration.logger.level = BRZLoggerLevelInfo;
  Braze *braze = [BrazeReactBridge initBraze:configuration];
  AppDelegate.braze = braze;
  
  self.moduleName = @"BrazeTest";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

/// This method controls whether the `concurrentRoot`feature of React18 is turned on or off.
///
/// @see: https://reactjs.org/blog/2022/03/29/react-v18.html
/// @note: This requires to be rendering on Fabric (i.e. on the New Architecture).
/// @return: `true` if the `concurrentRoot` feature is enabled. Otherwise, it returns `false`.
- (BOOL)concurrentRootEnabled
{
  return true;
}

#pragma mark - Override In-app messaging
-(enum BRZInAppMessageUIDisplayChoice)inAppMessage:(BrazeInAppMessageUI *)ui
                            displayChoiceForMessage:(BRZInAppMessageRaw *)message  {
  NSData *inAppMessageData = [message json];
  NSString *inAppMessageString = [[NSString alloc] initWithData:inAppMessageData encoding:NSUTF8StringEncoding];
  NSDictionary *arguments = @{
    @"inAppMessage" : inAppMessageString
  };
  // Send to JavaScript
  [self.bridge.eventDispatcher
             sendDeviceEventWithName:@"inAppMessageReceived"
             body:arguments];

  // If the feed_type key is present in extras we discard the Braze SDK UI and allow this to be handled in our RN App.
  // Otherwise the message will be displayed using the default Braze SDK UI.
  return inAppMessage.extras[@"feed_type"] ? BRZInAppMessageUIDisplayChoiceDiscard : BRZInAppMessageUIDisplayChoiceNow;
}

#pragma mark - AppDelegate.braze

static Braze *_braze = nil;

+ (Braze *)braze {
  return _braze;
}

+ (void)setBraze:(Braze *)braze {
  _braze = braze;
}

@end
