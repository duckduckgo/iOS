//
//  AppDelegate.m
//  SingularAdvertiserSampleApp
//
//  Created by Eyal Rabinovich on 25/06/2020.
//

#import "AppDelegate.h"

// Don't forget to import this to have access to the SKAdnetwork
#import <StoreKit/SKAdNetwork.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // The first call to registerAppForAdNetworkAttribution generates the notification if the device has attribution data for that app.
    // It's best to call this method as soon as possible, that's why we call it from didFinishLaunchingWithOptions.

    // When the app is opened for the first time and this method is called, it starts a 24-hour timer, any subsequent calls to updateCovnersionValue reset this timer.
    // once the first 24h timer ends, after a randomized period of time the attribution notification will be sent to the ad network.
    if (@available(iOS 15.4, *)) {
    } else {
        [SKAdNetwork registerAppForAdNetworkAttribution];
    }

    return YES;
}

@end
