//
//  DailymileProfile.m
//
//  Created by Mike Post on 6/12/13.
//  Copyright (c) 2013 Dashend. All rights reserved.
//

#import "DailymileProfile.h"
#import "DailymileConstants.h"


@implementation DailymileProfile


- (id)init {
    self = [super init];
    return self;
}


+ (DailymileProfile *)profileFromJSON:(NSDictionary *)jsonProfile
{
    DailymileProfile *profile = nil;
    
    if ([NSJSONSerialization isValidJSONObject:jsonProfile])
    {
        profile = [[DailymileProfile alloc] init];
        
        [profile setUserName:[jsonProfile objectForKey:@"username"]];
        [profile setDisplayName:[jsonProfile objectForKey:@"display_name"]];
        [profile setLocation:[jsonProfile objectForKey:@"location"]];
        
        [profile setProfileURL:[NSURL URLWithString:[jsonProfile objectForKey:@"url"]] ];
        [profile setPhotoURL:[NSURL URLWithString:[jsonProfile objectForKey:@"photo_url"]] ];
    }
    
    return profile;
}


+ (NSURL *)requestURLForPerson:(NSString *)username
{
    NSURL *personURL = nil;
    
    NSString *urlFormat = [NSString stringWithFormat:@"%@%@/%@.json",
                           kDailymileBasePath,
                           kDailymilePeopleURL,
                           username];
    
    personURL = [NSURL URLWithString:urlFormat];
    
    return personURL;
}


- (NSString *)description
{
    NSString *description = [NSString stringWithFormat:@"userName == %@ \ndisplayName == %@ \nlocation == %@ \nprofileURL == %@ \nphotoURL == %@",
                             self.userName,
                             self.displayName,
                             self.location,
                             self.profileURL,
                             self.photoURL];
    
    return description;
}


@end
