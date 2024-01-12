//
//  ViewController.m
//  SingularPublisherSampleApp
//
//  Created by Eyal Rabinovich on 24/06/2020.
//

#import "ViewController.h"
#import "AdController.h"

// Don't forget to import this to have access to the SKAdnetwork consts
#import <StoreKit/SKAdNetwork.h>

@interface ViewController ()

@end

@implementation ViewController

// Ad Request Keys
NSString * const REQUEST_SOURCE_APP_ID_KEY = @"source_app_id";
NSString * const REQUEST_SKADNETWORK_VERSION_KEY = @"skadnetwork_version";

// Ad Request Values
NSString * const REQUEST_SOURCE_APP_ID = @"663592361";
NSString * const REQUEST_SKADNETWORK_V1 = @"1.0";
NSString * const REQUEST_SKADNETWORK_V2 = @"2.0";
NSString * const REQUEST_SKADNETWORK_V22 = @"2.2";
NSString * const REQUEST_SKADNETWORK_V3 = @"3.0";
NSString * const REQUEST_SKADNETWORK_V4 = @"4.0";

// We use http for local tests, use https in production.
NSString * const REQUEST_AD_SERVER_ADDRESS = @"http://192.168.1.53:8000/get-ad-impression"; //@"http://<ENTER_YOU_SERVER_IP_HERE>:8000/get-ad-impression";

// Ad Response Keys - These are the same as our server, but real Ad Networks may return different keys.
NSString * const RESPONSE_AD_NETWORK_ID_KEY = @"adNetworkId";
NSString * const RESPONSE_SOURCE_APP_ID_KEY = @"sourceAppId";
NSString * const RESPONSE_SKADNETWORK_VERSION_KEY = @"adNetworkVersion";
NSString * const RESPONSE_TARGET_APP_ID_KEY = @"id";
NSString * const RESPONSE_SIGNATURE_KEY = @"signature";
NSString * const RESPONSE_CAMPAIGN_ID_KEY = @"campaignId";
NSString * const RESPONSE_TIMESTAMP_KEY = @"timestamp";
NSString * const RESPONSE_NONCE_KEY = @"nonce";
NSString * const RESPONSE_SOURCE_IDENTIFIER_KEY = @"sourceIdentifier";
NSString *skanVersion = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    // skan version depends on OS version. Ad signing defers between skan version.
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];

    if (osVersion < 14){
        skanVersion = REQUEST_SKADNETWORK_V1;
    } else if (osVersion < 14.5){
        skanVersion = REQUEST_SKADNETWORK_V2;
    } else if (osVersion < 14.6){
        skanVersion = REQUEST_SKADNETWORK_V22;
    } else if (osVersion < 16.1){
        skanVersion = REQUEST_SKADNETWORK_V3;
    } else {
        skanVersion = REQUEST_SKADNETWORK_V4;
    }
}

- (IBAction)showAdClick:(id)sender {
    // Step 1: Retrieving ad data from a python server simulating a real Ad Network API.
    // Our server uses the adnetwork key to sign the ad payload.
    // For more information please check out the skadnetwork_server folder in the repo.
    [self getProductDataFromServer];
}

- (void)getProductDataFromServer {
    // Building the URL for the GET request to the server
    NSURLComponents *components = [NSURLComponents componentsWithString:REQUEST_AD_SERVER_ADDRESS];
    NSURLQueryItem *sourceAppId = [NSURLQueryItem queryItemWithName:REQUEST_SOURCE_APP_ID_KEY value:REQUEST_SOURCE_APP_ID];
    
    NSURLQueryItem *skAdNetworkVersion = [NSURLQueryItem
                                          queryItemWithName:REQUEST_SKADNETWORK_VERSION_KEY
                                          value:skanVersion];
    
    components.queryItems = @[skAdNetworkVersion, sourceAppId];
    
    // Sending an Async GET request to the server to get the Ad data.
    [[[NSURLSession sharedSession] dataTaskWithURL:components.URL
                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            return;
        }
        
        // Step 2: Parsing the data that we got from the Ad Network to fit the `loadProductWithParameters` format in the AdController.
        NSDictionary *productParameters = [self parseResponseDataToProductParameters:data];
        
        if (!productParameters) {
            return;
        }
        
        // Step 3: Show the AdController with the product data we got from the Ad Network.
        [self loadProductFromResponseData:productParameters];
    }] resume];
}

- (void)loadProductFromResponseData:(NSDictionary *)productParameters {
    if (!productParameters) {
        return;
    }
    
    // Initializing and showing the AdController with the product parameters.
    // Check out the `viewDidLoad` method in the AdController for the next step.
    dispatch_async(dispatch_get_main_queue(), ^{
        AdController *adController = [[AdController alloc] initWithProductParameters:productParameters];
        [self showViewController:adController sender:self];
    });
}

// This function take the server's response and convert it to the loadProductWithParameters format.
- (NSDictionary *)parseResponseDataToProductParameters:(NSData *)data {
    if (!data){
        return nil;
    }
    
    NSError *error;
    NSDictionary *responseData = [[NSMutableDictionary alloc]initWithDictionary:
                                        [NSJSONSerialization JSONObjectWithData:data
                                                                        options:kNilOptions
                                                                          error:&error]];
    
    if (error){
        return nil;
    }
    
    NSMutableDictionary* productParameters = [[NSMutableDictionary alloc] init];
    
    // These product params should be of NSString* type.
    [productParameters setObject:[responseData objectForKey:RESPONSE_SIGNATURE_KEY] forKey:SKStoreProductParameterAdNetworkAttributionSignature];
    [productParameters setObject:[responseData objectForKey:RESPONSE_TARGET_APP_ID_KEY] forKey:SKStoreProductParameterITunesItemIdentifier];
    [productParameters setObject:[responseData objectForKey:RESPONSE_AD_NETWORK_ID_KEY] forKey:SKStoreProductParameterAdNetworkIdentifier];
    
    // These product params should be of NSNumber* type.
    [productParameters setObject:@([[responseData objectForKey:RESPONSE_CAMPAIGN_ID_KEY] intValue]) forKey:SKStoreProductParameterAdNetworkCampaignIdentifier];
    [productParameters setObject:@([[responseData objectForKey:RESPONSE_TIMESTAMP_KEY] longLongValue]) forKey:SKStoreProductParameterAdNetworkTimestamp];
    
    if (@available(iOS 14, *)) {
        // These product params are only included in SKAdNetwork version 2.0
        [productParameters setObject:skanVersion forKey:SKStoreProductParameterAdNetworkVersion];
        [productParameters setObject:@([[responseData objectForKey:RESPONSE_SOURCE_APP_ID_KEY] intValue]) forKey:SKStoreProductParameterAdNetworkSourceAppStoreIdentifier];
    }
	
    if (@available(iOS 16.1, *)) {
    	[productParameters setObject:[NSNumber numberWithInt: [[responseData objectForKey:RESPONSE_SOURCE_IDENTIFIER_KEY] intValue]] forKey:SKStoreProductParameterAdNetworkSourceIdentifier];
    }
    
    // This param has to be of NSUUID type, an exception is thrown if it is passed in NSString* type.
    [productParameters setObject:[[NSUUID alloc] initWithUUIDString:[responseData objectForKey:RESPONSE_NONCE_KEY]] forKey:SKStoreProductParameterAdNetworkNonce];
    
    return productParameters;
}

- (IBAction)showSingularClick:(id)sender {
    NSURL *singular = [NSURL URLWithString:@"https://www.singular.net?utm_medium=sample-app&utm_source=sample-app-publisher"];
    
    if( [[UIApplication sharedApplication] canOpenURL:singular]){
        [[UIApplication sharedApplication] openURL:singular options:[[NSDictionary alloc] init] completionHandler:nil];
    }
}

@end
