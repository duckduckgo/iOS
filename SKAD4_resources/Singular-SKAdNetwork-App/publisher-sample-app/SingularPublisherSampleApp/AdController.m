//
//  AdController.m
//  SingularPublisherSampleApp
//
//  Created by Eyal Rabinovich on 24/06/2020.
//

#import "AdController.h"


@implementation AdController

- (id)initWithProductParameters:(NSDictionary*)data {
    self = [super init];
    self->productParameters = data;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Please note that in order to use loadProductWithParameters,
    // Your ViewController must inherit from SKStoreProductViewController
    
    // Step 4: Showing the AppStore window with the product we got from the Ad Network.
    [self loadProductWithParameters:self->productParameters completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (error || !result){
            // Loading the ad failed, try to load another ad or retry the current ad.
        } else {
            // Ad loaded successfully! :)
        }
    }];
}

@end
