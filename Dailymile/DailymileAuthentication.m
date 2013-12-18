//
//  DailymileAuthentication.m
//
//  Created by Mike Post on 2/12/13.
//  Copyright (c) 2013 Dashend. All rights reserved.
//

#import "DailymileAuthentication.h"
//#import "AFNetworking.h"


@interface DailymileAuthentication()

@property (nonatomic, strong) NSString *clientID;

@property (nonatomic, strong) NSString *clientSecret;

@property (nonatomic, strong, readwrite) NXOAuth2Client *oauthClient;

@property (nonatomic, assign, readwrite, getter=isConnected) BOOL connected;

/**
 The most current success block set for authentication. Executes in a NXOAuth2ClientDelegate method.
 */
@property (nonatomic, strong) DMRequestAuthenticationBlock currentSuccessBlock;

/**
 The most current failure block set for authentication. Executes in a NXOAuth2ClientDelegate method.
 */
@property (nonatomic, strong) DMFailBlock currentFailBlock;

@end


@implementation DailymileAuthentication


#pragma mark - Init
- (id)initWithDelegate:(id <DailymileAuthenticationDelegate>)delegate clientID:(NSString *)clientID withSecret:(NSString *)secret
{
    self = [super init];

    if (self) {
        [self setDelegate:delegate];
        [self setClientID:clientID];
        [self setClientSecret:secret];
    }
    return self;
}


#pragma mark - Accessors
- (BOOL)isConnected
{
    _connected = YES;
    
    if ([self.oauthClient accessToken] == nil) {
        _connected = NO;
    }
    return _connected;
}


- (NSURL *)authorizationURL
{    
    NSString *authFormat = [NSString stringWithFormat:@"%@%@", kDailymileBasePath, kDailymileAuthorizationURL];
    
    NSURL *authURL = [NSURL URLWithString:authFormat];
    return authURL;
}


- (NSURL *)accessTokenURL
{
    NSString *urlFormat = [NSString stringWithFormat:@"%@%@grant_type=authorization_code", kDailymileBasePath, kDailymileAccessTokenURL];
    
    NSURL *accessURL = [NSURL URLWithString:urlFormat];
    return accessURL;
}


- (NXOAuth2Client *)oauthClient
{
    if (_oauthClient == nil) {
        _oauthClient = [[NXOAuth2Client alloc] initWithClientID:self.clientID
                                                   clientSecret:self.clientSecret
                                                   authorizeURL:[self authorizationURL]
                                                       tokenURL:[self accessTokenURL]
                                                       delegate:self];
        
//        [self.httpClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", oauthClient.accessToken.accessToken]];
    }
    
    return _oauthClient;
}


#pragma mark - Mutators


#pragma mark - OAuth2
- (void)attemptConnectWithSuccess:(DMRequestAuthenticationBlock)successBlock failure:(DMFailBlock)failBlock
{
    [self setCurrentSuccessBlock:successBlock];
    [self setCurrentFailBlock:failBlock];
    
    [self.oauthClient requestAccess];
}


- (void)disconnectWithSuccess:(DMRequestAuthenticationBlock)successBlock failure:(DMFailBlock)failBlock
{
    [self setCurrentSuccessBlock:successBlock];
    [self setCurrentFailBlock:failBlock];
    
    [self.oauthClient setAccessToken:nil];
}


- (void)attemptToAuthorize:(DMRequestAuthenticationBlock)successBlock failure:(DMFailBlock)failBlock
{
    NSString *redirectURI = [NSString stringWithFormat:@"dailymile-%@://oauth2", self.clientID];
    
    NSURL *oauthURL = [NSURL URLWithString:redirectURI];
    NSURL *authorizationURL = [self.oauthClient authorizationURLWithRedirectURL:oauthURL];

    [[UIApplication sharedApplication] openURL:authorizationURL];
}


- (void)handleRedirectedURL:(NSURL *)authURL
{
    NSString *authCode = [authURL nxoauth2_valueForQueryParameterKey:@"code"];
    NSString *caseSensitiveURL = nil;
    
    if (authCode == nil) {
        //Construct a relevant error parameter so oauthClient can parse the error and notify the delegate...
        caseSensitiveURL = [NSString stringWithFormat:@"dailymile-%@://oauth2?error=access_denied",
                            self.clientID];
    }
    else {
        //Try to get an access token...
        caseSensitiveURL = [NSString stringWithFormat:@"dailymile-%@://oauth2?code=%@",
                            self.clientID,
                            authCode];
    }
    
    [self.oauthClient openRedirectURL:[NSURL URLWithString:caseSensitiveURL]];
}


#pragma mark NXOAuth2ClientDelegate
- (void)oauthClientDidGetAccessToken:(NXOAuth2Client *)client
{
    NSLog(@"oauthClientDidGetAccessToken: %@", [client accessToken]);
    
    if (self.currentSuccessBlock != nil) {
        self.currentSuccessBlock([self accessTokenURL]);
    }    
    
    if ([self.delegate respondsToSelector:@selector(dailymileDidConnectWithError:)]) {
        [self.delegate dailymileDidConnectWithError:nil];
    }
}

- (void)oauthClientDidLoseAccessToken:(NXOAuth2Client *)client
{
    NSLog(@"didLoseAccessToken");
    
    if (client.accessToken == nil) {
        if (self.currentSuccessBlock != nil) {
            self.currentSuccessBlock(NULL);
        }
    }
    else {
        if (self.currentFailBlock != nil) {
            NSError *error = [NSError errorWithDomain:@"Access Token failed to delete" code:0 userInfo:nil];
            self.currentFailBlock(error);
        }
    }
}

- (void)oauthClient:(NXOAuth2Client *)client didFailToGetAccessTokenWithError:(NSError *)error
{
    NSLog(@"didFailToGetAccessToken: %@", [error description]);
    
    if (self.currentFailBlock != nil) {
        self.currentFailBlock(error);
    }
    
    if ([self.delegate respondsToSelector:@selector(dailymileDidConnectWithError:)]) {
        [self.delegate dailymileDidConnectWithError:&error];
    }
}

- (void)oauthClientNeedsAuthentication:(NXOAuth2Client *)client
{
    NSLog(@"oauthClientNeedsAuthentication");
    
    [self attemptToAuthorize:^(NSURL *authorizationURL)
    {
        if (self.currentSuccessBlock != nil) {
            self.currentSuccessBlock(authorizationURL);
        }
        
        if ([self.delegate respondsToSelector:@selector(dailymileDidRequestAuthenticationWithURL:)]) {
            [self.delegate dailymileDidRequestAuthenticationWithURL:authorizationURL];
        }
    }
                     failure:^(NSError *error) {
                         if (self.currentFailBlock != nil) {
                             self.currentFailBlock(error);
                         }
                     }];
}


@end
