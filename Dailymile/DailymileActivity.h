//
//  DailymileActivity.h
//
//  Created by Mike Post on 1/12/13.
//  Copyright (c) 2013 Dashend. All rights reserved.
//

#import "DailymileConstants.h"
#import "DailymileActivityRoute.h"

@class GPXRoot;


/**
 Contains all properties needed to upload a workout to Dailymile. 
 All properties are optional except for activityType, which is why the designated initialiser has this as a parameter.
 
 @discussion A few assumptions are made about any GPX file that data is extracted from, and it's up to you to create a GPX in that way:
    1) There is only 1 track, but that track can contain multiple track segments. It uses the last (or only) track in any array of tracks.
    2) The track name is a good value to use for the Dailymile title.
    3) The track comment is a good value to use for the Dailymile message.

 The property getters are set to return empty strings in the case of a NULL value, to avoid a dictionary crash in the DailymileManager.
 */
@interface DailymileActivity : NSObject

/**
 Corresponds to Dailymile's activity_type workout value
 */
@property (nonatomic, assign) DailymileActivityType activityType;

/**
 Corresponds to Dailymile's felt workout value
 */
@property (nonatomic, assign) DailymileActivityFeeling activityFeeling;

/**
 */
@property (nonatomic, assign) DailymileActivityRoute *activityRoute;

/**
 Corresponds to Dailymile's workout[completed_at] value.
 */
@property (nonatomic, strong) NSDate *dateCompleted;

/**
 Corresponds to Dailymile's workout[duration] value.
 */
@property (nonatomic, strong) NSNumber *durationInSeconds;

/**
 Corresponds to Dailymile's workout[distance-value] value.
 */
@property (nonatomic, strong) NSNumber *distanceValue;

/**
 Corresponds to Dailymile's workout[distance-unit] value.
 */
@property (nonatomic, assign) DailymileDistanceUnit distanceUnit;

/**
 Corresponds to Dailymile's workout[calories] value.
 */
@property (nonatomic, strong) NSNumber *calories;

/**
 Corresponds to Dailymile's workout[title] value.
 */
@property (nonatomic, copy) NSString *title;

/**
 Notes about the workout, corresponds to Dailymile's message value.
 */
@property (nonatomic, copy) NSString *message;

/**
 Corresponds to Dailymile's media[type] value.
 */
@property (nonatomic, strong) NSData *sharedImage;


#pragma These getters are set to return empty strings in the case of a NULL value.
/**
 The equivalent of the dateCompleted getter, except it returns the value as an `NSString`.
 */
- (NSString *)dateCompletedJSON;

/**
 The equivalent of the durationInSeconds getter, except it returns the value as an `NSString`.
 */
- (NSString *)durationInSecondsJSON;

/**
 The equivalent of the distanceValue getter, except it returns the value as an `NSString`.
 */
- (NSString *)distanceValueJSON;

/**
 The equivalent of the calories getter, except it returns the value as an `NSString`.
 */
- (NSString *)caloriesJSON;


/**
 Seeing as "activity_type" is the only non-optional Dailymile value in a workout, it makes sense that this is the convenience initialiser.
 @param activityType One of the 5 values.
 @return self
 */
- (id)initWithActivityType:(DailymileActivityType)activityType;

/**
 Initialises with the convenience intialiser `initWithActivityType:` with the `GPXTrack` name attribute.
 If this attribute doesn't comply to a type supported by `DailymileActivityType`, the activityType defaults to kDMActivityTypeRunning seeing as this is non-optional.
 @param gpx A `GPXRoot` object from the GPX framework.
 @return self
 */
- (id)initWithGPXData:(NSData *)gpxData;

/**
 Convenient method to get the string needed for the dailymile API, from the enumeration.
 */
- (NSString *)jsonStringForActivity:(DailymileActivityType)activityType;

/**
 */
- (DailymileActivityType)activityTypeForJSONString:(NSString *)typeString;

/**
 Convenient method to get the string needed for the dailymile API, from the enumeration.
 */
- (NSString *)jsonStringForFeeling:(DailymileActivityFeeling)activityFeeling;

/**
 */
- (DailymileActivityFeeling)activityFeelingForJSONString:(NSString *)feelingString;

/**
 Convenient method to get the string needed for the dailymile API, from the enumeration.
 */
- (NSString *)jsonStringForDistanceUnit:(DailymileDistanceUnit)distanceUnit;

/**
 */
- (DailymileDistanceUnit)distanceUnitForJSONString:(NSString *)unitString;


@end
