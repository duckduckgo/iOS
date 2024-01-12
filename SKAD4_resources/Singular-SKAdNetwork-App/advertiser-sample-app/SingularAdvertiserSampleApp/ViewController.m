//
//  ViewController.m
//  SingularAdvertiserSampleApp
//
//  Created by Eyal Rabinovich on 25/06/2020.
//

#import "ViewController.h"

// Important: Add the AppTrackingTransparency.framework in the build phases tab.
#import <AppTrackingTransparency/ATTrackingManager.h>

// Don't forget to import this to have access to the SKAdnetwork framework
#import <StoreKit/SKAdNetwork.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 16.1, *)) {
        /* set to SKAdNetworkCoarseConversionValueLow, SKAdNetworkCoarseConversionValueMedium or SKAdNetworkCoarseConversionValueHigh */
        self.coarseValue = SKAdNetworkCoarseConversionValueMedium;
    }

    self.fineValue = 3; /* set your fine value here */
    self.lockWindow = NO;
}

- (IBAction)showTrackingConsentDialog:(id)sender {
    // Checking the OS version before calling the Tracking Consent dialog, it's available only in iOS 14 and above
    if (@available(iOS 14, *)) {
        // If the tracking authorization status is other than not determined, this means that the Tracking Consent dialog has already been shown.
        // The `trackingAuthorizationStatus` persists the result of the Tracking Consent dialog and can only be changed through the iOS settings screen.
        // Tracking Consent dialog is only shown once per install, meaning that calling `requestTrackingAuthorizationWithCompletionHandler` won't show the dialog again.
        if ([ATTrackingManager trackingAuthorizationStatus] != ATTrackingManagerAuthorizationStatusNotDetermined) {
            [self alertTrackingConsentIsAlreadySet];
        }

        // Before showing the Tracking Consent dialog, you'll need to add the `Privacy - Tracking Usage Description` to your app's info.plist.
        // If you don't add it, an exception will be thrown.
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            // Here we get the result of the dialog
            // If `requestTrackingAuthorizationWithCompletionHandler` was called twice, the completion handler will be called twice, but will show the dialog on the first time.
            // On the second time this method is called the completion handler will be called with the value returned by `trackingAuthorizationStatus`
        }];
    } else {
        // No need to display the dialog in earlier versions
    }
}

- (IBAction)updateConversionValueClick:(id)sender {
    // For SKAN 3 Once `registerAppForAdNetworkAttribution` is called for the first time
    // (check the AppDelegate.m for explanations on `registerAppForAdNetworkAttribution`),
    // a 24 hours window is opened to update conversion value for attribution data.
    
    // In SKAN 4 the behvior changed and supports 3 different time windows, each sending a postback.
    // while you can call updatePostbackConversionValue function in all time windows, only in the first one you can affect the 'fineConversionValue'
    // more on that: https://developer.apple.com/documentation/storekit/skadnetwork 
    // passing YES to lockWindow will signal to the SKAN framework that a postback for the specific time window can be sent and not wait for the time window to pass.
    if (@available(iOS 16.1, *)) {
        [SKAdNetwork updatePostbackConversionValue:self.fineValue
                                       coarseValue:self.coarseValue
                                        lockWindow:self.lockWindow
                                 completionHandler: ^(NSError *_Nullable error) {
            if (error) {
                [self alertConversionValueError:error];
            } else {
                [self alertConversionValueUpdated];
            }
        }];
    } else if (@available(iOS 15.4, *)) {
    // Using `updateConversionValue` we can add a value (a number between 0-63) to be sent with the attribution notification.
    // Every time we call this method, we start a new 24 hours window until the notification is sent.
    // Please note that calling `updateConversionValue` is only effective in the first 24 hours since `registerAppForAdNetworkAttribution` is first called.
    // Any calls after 24 hours will not update the conversion value in the attribution notification.
        [SKAdNetwork updatePostbackConversionValue:self.fineValue
                                 completionHandler: ^(NSError *_Nullable error) {
            if (error) {
                [self alertConversionValueError:error];
            } else {
                [self alertConversionValueUpdated];
            }
        }];
    } else {
        [SKAdNetwork updateConversionValue:self.fineValue];
        [self alertConversionValueUpdated];
    }
}

- (IBAction)showSingularClick:(id)sender {
    NSURL *singular = [NSURL URLWithString:@"https://www.singular.net?utm_medium=sample-app&utm_source=sample-app-advertiser"];

    if ([[UIApplication sharedApplication] canOpenURL:singular]) {
        [[UIApplication sharedApplication] openURL:singular options:[[NSDictionary alloc] init] completionHandler:nil];
    }
}

- (void)alertConversionValueUpdated {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = nil;

        if (@available(iOS 16.1, *)) {
            message = [NSString stringWithFormat:@"fine value: %d coarse value: %@ lock window: %@", (int)self.fineValue, self.coarseValue, self.lockWindow ? @"true" : @"false"];
        } else {
            message = [NSString stringWithFormat:@"value: %d", (int)self.fineValue];
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Conversion Value Updated!"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {}];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)alertConversionValueError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Conversion Value Error!"
                                                                       message:error.description
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {}];

        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)alertTrackingConsentIsAlreadySet {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Can't Display Dialog"
                                                                   message:@"Can't display Tracking Consent dialog because it has already been displayed. "
                                @"To see this dialog again please remove & reinstall this app."
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {}];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
