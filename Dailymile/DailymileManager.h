//
//  DailymileManager.h
//
//  Created by Mike Post on 30/11/13.
//  Copyright (c) 2013 Dashend. All rights reserved.
//


#import "DailymileAuthentication.h"
#import "DailymileProfile.h"
#import "DailymileActivity.h"


/**
 Basic upload blocks.
 */
typedef void(^DMUploadSuccessBlock)(DailymileActivity *activity);


#pragma mark - DailymileManager
/**
 Main interface to handle all Dailymile connect and upload calls.
 */
@interface DailymileManager : NSObject <DailymileAuthenticationDelegate> {
}

/**
 The DailymileAuthentication is a non-singleton instance that handles authentication with OAuth login and keys. Set on init.
 */
@property (nonatomic, strong, readonly) DailymileAuthentication *dailymileAuthentication;

/**
 Use this to return the class instance as a singleton.
 */
+ (DailymileManager *)sharedInstance;

/**
 Asks the DailymileAuthentication if it's connected, and if not it attempts to connect.
 @param success The block is implemented if the auth is valid.
 @param failure The block is implemented if the auth fails.
 */
- (void)connectWithSuccess:(DMRequestAuthenticationBlock)successBlock failure:(DMFailBlock)failBlock;

/**
 Attempts to remove the access token via DailymileAuthentication.
 @param success The block is implemented if the auth has been removed.
 @param failure The block is implemented if the auth removal has failed.
 */
- (void)disconnectWithSuccess:(DMRequestAuthenticationBlock)successBlock failure:(DMFailBlock)failBlock;

/**
 Redirect from Dailymile OAuth.
 @param authURL This should contain the `kDailymileClientID` with "dm" prepended.
 */
- (void)openAuthURL:(NSURL *)authURL;

/**
 Retrieves the profile of the signed in user. Implements the failBlock if it fails.
 @param profileName The name of the profile to retrieve. Pass "me" for the logged in user profile.
 @param successBlock Block with a response parameter of type `id`. Perfect for the JSON response.
 @param failBlock Block with an `NSError` parameter.
 */
- (void)downloadProfile:(NSString *)profileName withSuccess:(DMRequestSuccessBlock)successBlock failure:(DMFailBlock)failBlock;

/**
 Parses the DailymileActivity object as JSON then uploads it to Dailymile.
 @param activity
 @param successBlock Block with a response parameter of type `id`.
 @param failBlock Block with an `NSError` parameter.
 */
- (void)uploadActivity:(DailymileActivity *)activity withSuccess:(DMRequestSuccessBlock)successBlock failure:(DMFailBlock)failBlock;

/**
 */
- (void)uploadGPXTraining:(NSData *)gpxData toActivityID:(NSInteger)entryID withSuccess:(DMRequestSuccessBlock)successBlock failure:(DMFailBlock)failBlock;


@end
