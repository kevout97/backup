/*
 * Copyright @ 2018-present 8x8, Inc.
 * Copyright @ 2017-2018 Atlassian Pty Ltd
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AppDelegate.h"
#import "FIRUtilities.h"
#import "Types.h"
#import <AppCenterReactNative.h>
#import <AppCenterReactNativeCrashes.h>
#import <AppCenterReactNativeAnalytics.h>


@import Crashlytics;
@import Fabric;
@import Firebase;
@import JitsiMeet;


@implementation AppDelegate

-             (BOOL)application:(UIApplication *)application
  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Initialize Crashlytics and Firebase if a valid GoogleService-Info.plist file was provided.
    if ([FIRUtilities appContainsRealServiceInfoPlist]) {
        NSLog(@"Enablign Crashlytics and Firebase");
        [FIRApp configure];
        [Fabric with:@[[Crashlytics class]]];
    }
  
  [AppCenterReactNative register];
  [AppCenterReactNativeAnalytics registerWithInitiallyEnabled:YES];
  [AppCenterReactNativeCrashes registerWithAutomaticProcessing];
  
  [GIDSignIn sharedInstance].clientID = CLIENT_ID;
  [GIDSignIn sharedInstance].serverClientID = SERVER_CLIENT_ID;
  [GIDSignIn sharedInstance].scopes = @[SCOPE_PROFILE_GOOGLE,SCOPE_EMAIL_GOOGLE,SCOPE_CALENDAR_GOOGLE];
    return YES;
}

#pragma mark Linking delegate methods

-    (BOOL)application:(UIApplication *)application
  continueUserActivity:(NSUserActivity *)userActivity
    restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *restorableObjects))restorationHandler {

    if ([FIRUtilities appContainsRealServiceInfoPlist]) {
        // 1. Attempt to handle Universal Links through Firebase in order to support
        //    its Dynamic Links (which we utilize for the purposes of deferred deep
        //    linking).
        BOOL handled
          = [[FIRDynamicLinks dynamicLinks]
                handleUniversalLink:userActivity.webpageURL
                         completion:^(FIRDynamicLink * _Nullable dynamicLink, NSError * _Nullable error) {
           NSURL *firebaseUrl = [FIRUtilities extractURL:dynamicLink];
           if (firebaseUrl != nil) {
             userActivity.webpageURL = firebaseUrl;
             [[JitsiMeet sharedInstance] application:application
                                continueUserActivity:userActivity
                                  restorationHandler:restorationHandler];
           }
        }];

        if (handled) {
          return handled;
        }
    }
  
  NSString *hostURL = userActivity.webpageURL.host;
  
  if ([hostURL isEqualToString:@"beta.claroconnect.com"] ) {
    NSDictionary* userInfo = @{@"url": userActivity.webpageURL};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadWebView" object:self userInfo:userInfo];
   }
  
  

    // 2. Default to plain old, non-Firebase-assisted Universal Links.
    return [[JitsiMeet sharedInstance] application:application
                              continueUserActivity:userActivity
                                restorationHandler:restorationHandler];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    // This shows up during a reload in development, skip it.
    // https://github.com/firebase/firebase-ios-sdk/issues/233
//    if ([[url absoluteString] containsString:@"google/link/?dismiss=1&is_weak_match=1"]) {
//        return NO;
//    }
//
//    NSURL *openUrl = url;
//
//    if ([FIRUtilities appContainsRealServiceInfoPlist]) {
//        // Process Firebase Dynamic Links
//        FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
//        NSURL *firebaseUrl = [FIRUtilities extractURL:dynamicLink];
//        if (firebaseUrl != nil) {
//            openUrl = firebaseUrl;
//        }
//    }
//
//    return [[JitsiMeet sharedInstance] application:app
//                                           openURL:openUrl
//                                           options:options];
  
  NSString *hostURL = url.host;
  
  if ([hostURL isEqualToString:@"beta.claroconnect.com"] ) {
    NSString *strMyURLWithScheme = url.absoluteString;
    NSString * strNoURLScheme = [strMyURLWithScheme stringByReplacingOccurrencesOfString:[url scheme] withString:@"https"];
    NSURL *newURLwithnoScheme = [NSURL URLWithString:strNoURLScheme];
   NSDictionary* userInfo = @{@"url": newURLwithnoScheme};
   [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadWebView" object:self userInfo:userInfo];
    return NO;
  }
  
  return [[GIDSignIn sharedInstance] handleURL:url];
  
}


@end
