//
//  DailymileProfile.h
//
//  Created by Mike Post on 6/12/13.
//  Copyright (c) 2013 Dashend. All rights reserved.
//


/**
 Contains common properties related to the JSON response of a Dailymile profile.
 */
@interface DailymileProfile : NSObject

/**
 The name used by dailymile's API to identify the user.
 */
@property (nonatomic, copy) NSString *userName;

/**
 The name publicly displayed to other users view the user's profile.
*/
@property (nonatomic, copy) NSString *displayName;

/**
 City and state of the location the user has set in their profile.
*/
@property (nonatomic, copy) NSString *location;

/**
 URL of the user's profile on dailymile.com.
*/
@property (nonatomic, strong) NSURL *profileURL;

/**
 URL of the user's most recent avatar photo.
*/
@property (nonatomic, strong) NSURL *photoURL;


/**
 Constructs the URL needed for a profile GET request, for either the authorized user or a requested username.
 @param username The user that the profile URL will be constructed for. Pass `kDailymilePeopleUserSelf` for the authorized user!
 @return The URL suitable for http://www.dailymile.com/api/documentation#people
 */
+ (NSURL *)requestURLForPerson:(NSString *)username;

/**
 */
+ (DailymileProfile *)profileFromJSON:(NSDictionary *)jsonProfile;

@end
