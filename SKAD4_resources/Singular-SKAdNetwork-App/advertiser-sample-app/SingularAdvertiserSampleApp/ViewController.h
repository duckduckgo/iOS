//
//  ViewController.h
//  SingularAdvertiserSampleApp
//
//  Created by Eyal Rabinovich on 25/06/2020.
//

#import <StoreKit/SKAdNetwork.h>
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property NSInteger fineValue; /* should be an integer between 0-63  */
@property SKAdNetworkCoarseConversionValue coarseValue API_AVAILABLE(ios(16.1)); 
@property bool lockWindow; /* should be flase/NO as defualt .*/

@end
