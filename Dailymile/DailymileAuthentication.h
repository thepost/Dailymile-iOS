//
//  DailymileAuthentication.h
//
//  Created by Mike Post on 2/12/13.
//  Copyright (c) 2013 Dashend. All rights reserved.
//

#import "NXOAuth2.h"
#import "DailymileConstants.h"


/**
 Basic auth blocks.
 */
typedef void(^DMRequestAuthenticationBlock)(NSURL *authorizationURL);
typedef void(^DMRequestSuccessBlock)(id response);
typedef void(^DMFailBlock)(NSError *error);


#pragma mark - DailymileAuthenticationDelegate
/**
 Protocol that relays responsed from OAuth, and Dailymile calls.
 @discussion Delegation isn't recommended on a Singleton. It's optional to use this, but recommended to use blocks instead.
 */
@protocol DailymileAuthenticationDelegate <NSObject>

/**
 Called when authentication is needed, in order to connect to Dailymile.
 @param authorizationURL The `NSURL` to either handle in a webview or redirect to the browser.
 */
- (void)dailymileDidRequestAuthenticationWithURL:(NSURL *)authorizationURL;

/**
 Called when an attempt to connect to OAuth has been made.
 @param error The error returned from OAuth if the connection failed.
 */
- (void)dailymileDidConnectWithError:(NSError **)error;

/**
 Called when an attempt to upload a workout to Dailymile has been made.
 @param error The error returned from Dailymile if the upload failed.
 */
- (void)dailymileDidUploadWithError:(NSError **)error;

@end


#pragma mark - DailymileAuthentication
@interface DailymileAuthentication : NSObject <NXOAuth2ClientDelegate>

/**
 The main delegate to relay Dailymile responses.
 */
@property (nonatomic, assign) id <DailymileAuthenticationDelegate> delegate;

/**
 Calls `attemptToConnectWithSuccess:` and returns true if there's no error.
 */
@property (nonatomic, assign, readonly, getter=isConnected) BOOL connected;

/**
 The OAuth client that handles auth requests.
 */
@property (nonatomic, strong, readonly) NXOAuth2Client *oauthClient;


/**
 Convenience intialiser.
 @param delegate
 @param clientID The Dailymile clientID needed for auth.
 @param secret The Dailymile secret key needed for auth.
 */
- (id)initWithDelegate:(id <DailymileAuthenticationDelegate>)delegate clientID:(NSString *)clientID withSecret:(NSString *)secret;

/**
 Merely just checks for existing authorization via the Dailymile API.
 If it fails and needs authentication, it's up to the caller to call `attemptToAuthorize`.
 @param success The block is implemented if the auth is valid.
 @param failure The block is implemented if the auth fails.
 */
- (void)attemptConnectWithSuccess:(DMRequestAuthenticationBlock)successBlock failure:(DMFailBlock)failBlock;

/**
 
 @param success The block is implemented if the auth is valid.
 @param failure The block is implemented if the auth fails.
 */
- (void)disconnectWithSuccess:(DMRequestAuthenticationBlock)successBlock failure:(DMFailBlock)failBlock;

/**
 If `attemptConnectWithSuccess` has failed, this executes.
 */
- (void)attemptToAuthorize:(DMRequestAuthenticationBlock)successBlock failure:(DMFailBlock)failBlock;

/**
 Returns the `kDailymileAuthorizationURL` with the `kDailymileBasePath` as an `NSURL`.
 */
- (NSURL *)authorizationURL;

/**
 Returns the `kDailymileAccessTokenURL` with the `kDailymileBasePath` as an `NSURL`.
 */
- (NSURL *)accessTokenURL;

/**
 Notifies the auth client of the need to get an access token, and handles the redirected URL from the user authenticating. 
 Does nothing but notifies the delegate if the access code is NULL.
 @param authURL The oauth2 URL with the access code or an error string appended to it.
 */
- (void)handleRedirectedURL:(NSURL *)authURL;

@end
