//
//  DailymileManager.m
//
//  Created by Mike Post on 30/11/13.
//  Copyright (c) 2013 Dashend. All rights reserved.
//

#import "DailymileManager.h"
#import "AFNetworking.h"
#import <GPX/GPX.h>


#define kDailymileClientID      @"YOUR_CLIENT_ID_HERE"
#define kDailymileClientSecret  @"YOUR_CLIENT_SECRET_HERE"


@interface DailymileManager()

//@property (nonatomic, strong) AFHTTPSessionManager *networkManager;

@property (nonatomic, strong, readwrite) DailymileAuthentication *dailymileAuthentication;

@end


@implementation DailymileManager


#pragma mark - Init
+ (DailymileManager *)sharedInstance
{
    static DailymileManager *singleton = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    
    return singleton;
}


- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.dailymileAuthentication = [[DailymileAuthentication alloc] initWithDelegate:self
                                                                                clientID:kDailymileClientID
                                                                              withSecret:kDailymileClientSecret];
//        self.networkManager = []
    }
    return self;
}


#pragma mark - DailymileAuthentication
- (void)connectWithSuccess:(DMRequestAuthenticationBlock)successBlock failure:(DMFailBlock)failBlock
{
    if ([self.dailymileAuthentication isConnected] == YES) {
        successBlock(nil);
    }
    else {
        [self.dailymileAuthentication attemptConnectWithSuccess:^(NSURL *authorizationURL) {
            successBlock(authorizationURL);
        }
                                                       failure:^(NSError *error) {
                                                           failBlock(error);
                                                       }];
    }
}


- (void)disconnectWithSuccess:(DMRequestAuthenticationBlock)successBlock failure:(DMFailBlock)failBlock
{
    [self.dailymileAuthentication disconnectWithSuccess:successBlock
                                                failure:failBlock];
}


- (void)openAuthURL:(NSURL *)authURL {
    [self.dailymileAuthentication handleRedirectedURL:authURL];
}


#pragma mark - DailymileProfile
- (void)downloadProfile:(NSString *)profileName withSuccess:(DMRequestSuccessBlock)successBlock failure:(DMFailBlock)failBlock
{
    NSURL *profileURL = [DailymileProfile requestURLForPerson:profileName];
    
    //Make GET request with profileURL...
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    //Set auth header...
    NSString *accessToken = [[[self.dailymileAuthentication oauthClient] accessToken] accessToken];
    [requestSerializer setAuthorizationHeaderFieldWithToken:accessToken];
    
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    [requestManager setRequestSerializer:requestSerializer];
    
    [requestManager GET:[profileURL description]
             parameters:@{@"oauth_token": accessToken}
                success:^(AFHTTPRequestOperation *operation, id response) {
                    successBlock(response);
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    failBlock(error);
                }];
}


#pragma mark - DailymileActivity
- (void)uploadActivity:(DailymileActivity *)activity withSuccess:(DMRequestSuccessBlock)successBlock failure:(DMFailBlock)failBlock
{
    if (activity == nil) {
        NSError *error = [NSError errorWithDomain:DMErrorEntryUploadDomain
                                             code:DMErrorCodeInvalidActivity
                                         userInfo:@{NSLocalizedDescriptionKey: @"Error with DailymileActivity: cannot construct a Dailymile entry with nil object"}];
        failBlock(error);
    }
    else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSString *urlFormat = [NSString stringWithFormat:@"%@%@.json", kDailymileBasePath, kDailymileEntryURL];
        
        //Make GET request with profileURL...
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        //Set auth header...
        NSString *accessToken = [[[self.dailymileAuthentication oauthClient] accessToken] accessToken];
        [requestSerializer setAuthorizationHeaderFieldWithToken:accessToken];
        
        AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager setRequestSerializer:requestSerializer];
        
        //Set the Dailymile values from our DailymileActivity object...
        NSDictionary *params = @{@"oauth_token": accessToken,
                                 @"message": [activity message],
                                 @"workout": @{@"activity_type": [activity jsonStringForActivity:activity.activityType],
                                               @"title": [activity title],
                                               @"completed_at": [activity dateCompletedJSON],
                                               @"duration": [activity durationInSecondsJSON],
                                               @"felt": [activity jsonStringForFeeling:activity.activityFeeling],
                                               @"calories": [activity caloriesJSON],
                                               @"distance": @{@"value": [activity distanceValueJSON],
                                                              @"units": [activity jsonStringForDistanceUnit:activity.distanceUnit]}
                                               }
                                 };
        
        [requestManager POST:urlFormat
                  parameters:params
                     success:^(AFHTTPRequestOperation *operation, id response) {
                         successBlock(response);
                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         failBlock(error);
                         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                     }];
    }
}


- (void)uploadGPXTraining:(NSData *)gpxData toActivityID:(NSInteger)entryID withSuccess:(DMRequestSuccessBlock)successBlock failure:(DMFailBlock)failBlock
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //Create DailymileActivity object from GPX...
     NSString *urlFormat = [NSString stringWithFormat:@"%@%@/%d%@.json",
                            kDailymileBasePath,
                            kDailymileEntryURL,
                            entryID,
                            kDailymileEntryTrackURL];
     
     //Make GET request with profileURL...
     AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
     [requestSerializer setValue:@"application/gpx+xml" forHTTPHeaderField:@"Accept"];
    
    //Reset HTTPMethodsEncodingParametersInURI with "PUT"...
    NSMutableSet *newHTTPMethods = [[NSMutableSet alloc] initWithSet:requestSerializer.HTTPMethodsEncodingParametersInURI
                                                           copyItems:YES];
    [newHTTPMethods addObject:@"PUT"];
    [requestSerializer setHTTPMethodsEncodingParametersInURI:newHTTPMethods];
        

     //Set auth header...
     NSString *accessToken = [[[self.dailymileAuthentication oauthClient] accessToken] accessToken];
     [requestSerializer setAuthorizationHeaderFieldWithToken:accessToken];

     AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
     [requestManager setRequestSerializer:requestSerializer];


    //Get GPX file...
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"fitfriend_log_2013-11-30" ofType:@"gpx"];
    NSData *newData = [NSData dataWithContentsOfFile:resourcePath];
    
    NSDictionary *params = @{@"oauth_token": accessToken};

         [requestManager PUT:urlFormat
                   parameters:params
                        body:newData
                      success:^(AFHTTPRequestOperation *operation, id response) {
                          successBlock(response);
                          NSLog(@"Uploaded GPX: %@", response);
                          
                          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          failBlock(error);
                          NSLog(@"Error uploading GPX: %@", [error description]);
                          
                          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                      }];
}


#pragma mark - DailymileAuthenticationDelegate
- (void)dailymileDidRequestAuthenticationWithURL:(NSURL *)authorizationURL {
    //Do nothing here. Handled in earlier DMRequestAuthenticationBlock. Perhaps you could notify the view controller to update it's view if needed?
}


- (void)dailymileDidConnectWithError:(NSError **)error {
    //Notify your view controller to present a login alert, if the error is not null...
}


- (void)dailymileDidUploadWithError:(NSError **)error {
    //Notify your view controller to present an upload alert, if the error is not null...
}


@end
