//
//  DailymileActivityRoute.h
//
//  Created by Mike Post on 11/12/13.
//  Copyright (c) 2013 Dashend. All rights reserved.
//

#import "DailymileConstants.h"

@interface DailymileActivityRoute : NSObject

/**
 Data with that contains a validated GPX file in XML format. It's up to you to ensure it's valid.
 */
@property (nonatomic, strong) NSData *gpxFileData;

/**
 Name given to the GPX file, if the data needs to be retrieved at all.
 */
@property (nonatomic, copy) NSString *gpxFileName;

/**
 Optional name given to a Dailymile route.
 */
@property (nonatomic, copy) NSString *routeName;

/**
 The route type can vary from an activity type, but is of similar variables.
 */
@property (nonatomic, assign) DailymileActivityType routeType;


/**
 Convenience initialiser to set the GPX file to the gpxFileData property.
 @param gpxData
 */
- (id)initWithGPXFile:(NSData *)gpxData;

/**
 Parses the `gpxFileData` as GPXRoot then converts it into an `NSString`.
 @return the XML format as a string.
 */
- (NSString *)gpxString;

@end
