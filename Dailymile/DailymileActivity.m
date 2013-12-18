//
//  DailymileActivity.m
//
//  Created by Mike Post on 1/12/13.
//  Copyright (c) 2013 Dashend. All rights reserved.
//

#import "DailymileActivity.h"
#import <GPX/GPX.h>


#pragma DailymileActivityType strings
NSString *const ACTIVITY_TYPE_RUNNING       = @"running";
NSString *const ACTIVITY_TYPE_CYCLING       = @"cycling";
NSString *const ACTIVITY_TYPE_WALKING       = @"walking";
NSString *const ACTIVITY_TYPE_SWIMMING      = @"swimming";
NSString *const ACTIVITY_TYPE_FITNESS       = @"fitness";

#pragma DailymileActivityFeeling strings
NSString *const ACTIVITY_FEELING_GREAT      = @"great";
NSString *const ACTIVITY_FEELING_GOOD       = @"good";
NSString *const ACTIVITY_FEELING_ALRIGHT    = @"alright";
NSString *const ACTIVITY_FEELING_BLAH       = @"blah";
NSString *const ACTIVITY_FEELING_TIRED      = @"tired";
NSString *const ACTIVITY_FEELING_INJURED    = @"injured";

#pragma DailymileDistanceUnit strings
NSString *const DISTANCE_UNIT_MILES         = @"miles";
NSString *const DISTANCE_UNIT_KM            = @"kilometers";
NSString *const DISTANCE_UNIT_METERS        = @"meters";
NSString *const DISTANCE_UNIT_YARDS         = @"yards";


@interface DailymileActivity()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end


@implementation DailymileActivity


#pragma mark - Init
- (id)initWithActivityType:(DailymileActivityType)activityType
{
    self = [super init];
    
    if (self) {
        [self setActivityType:activityType];
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    }
    return self;
}


- (id)initWithGPXData:(NSData *)gpxData
{
    self = [super init];
    
    if (self)
    {
        DailymileActivityRoute *route = [[DailymileActivityRoute alloc] initWithGPXFile:gpxData];
        [self setActivityRoute:route];
        
        //Use GPX data to set properties...
        GPXRoot *gpx = [GPXParser parseGPXWithData:gpxData];

        //Assumes there is only 1 track, but that track can contain multiple segments.
        GPXTrack *track = [[gpx tracks] lastObject];
        
        if (track == nil) {
            //There's no point in proceeding...
            self = nil;
        }
        else {
            //Set activityType...
            self.activityType = [self activityTypeForJSONString:track.name];
            
            [self setTitle:track.name];
            [self setMessage:track.comment];
        }
    }
    
    return self;
}


#pragma mark - Getters 
- (NSString *)dateCompletedJSON
{
    //ISO 8601 format should be: YYYY-MM-DDThh:mm:ss
    NSString *date = [self.dateFormatter stringFromDate:_dateCompleted];
    
    return date;
}


- (NSString *)durationInSecondsJSON
{
    NSString *duration = [_durationInSeconds stringValue];
    
    if (duration == nil) {
        duration = @"";
    }
    return duration;
}


- (NSString *)distanceValueJSON
{
    NSString *distValue = [_distanceValue stringValue];
    
    if (distValue == nil) {
        distValue = @"";
    }
    return distValue;
}


- (NSString *)caloriesJSON
{
    NSString *cals = [_calories stringValue];
    
    if (cals == nil) {
        cals = @"";
    }
    return cals;
}


- (NSString *)title
{
    if (_title == nil) {
        return @"";
    }
    return _title;
}


- (NSString *)message
{
    if (_message == nil) {
        return @"";
    }
    return _message;
}


#pragma mark - Enumeration convenience methods
- (NSString *)jsonStringForActivity:(DailymileActivityType)activityType
{
    NSString *activityString = nil;
    
    switch (activityType)
    {
        case kDMActivityTypeRunning:
            activityString = ACTIVITY_TYPE_RUNNING;
            break;
        case kDMActivityTypeCycling:
            activityString = ACTIVITY_TYPE_CYCLING;
            break;
        case kDMActivityTypeWalking:
            activityString = ACTIVITY_TYPE_WALKING;
            break;
        case kDMActivityTypeSwimming:
            activityString = ACTIVITY_TYPE_SWIMMING;
            break;
        case kDMActivityTypeFitness:
            activityString = ACTIVITY_TYPE_FITNESS;
            break;
    }
    
    return activityString;
}


- (DailymileActivityType)activityTypeForJSONString:(NSString *)typeString
{
    DailymileActivityType type = kDMActivityTypeRunning;
    
    if ([typeString isEqualToString:ACTIVITY_TYPE_CYCLING]) {
        type = kDMActivityTypeCycling;
    }
    else if ([typeString isEqualToString:ACTIVITY_TYPE_WALKING]) {
        type = kDMActivityTypeWalking;
    }
    else if ([typeString isEqualToString:ACTIVITY_TYPE_SWIMMING]) {
        type = kDMActivityTypeSwimming;
    }
    else if ([typeString isEqualToString:ACTIVITY_TYPE_FITNESS]) {
        type = kDMActivityTypeFitness;
    }

    return type;
}


- (NSString *)jsonStringForFeeling:(DailymileActivityFeeling)activityFeeling
{
    NSString *feelingString = nil;
    
    switch (activityFeeling)
    {
        case kDMActivityFeelingGreat:
            feelingString = ACTIVITY_FEELING_GREAT;
            break;
        case kDMActivityFeelingGood:
            feelingString = ACTIVITY_FEELING_GOOD;
            break;
        case kDMActivityFeelingAlright:
            feelingString = ACTIVITY_FEELING_ALRIGHT;
            break;
        case kDMActivityFeelingBlah:
            feelingString = ACTIVITY_FEELING_BLAH;
            break;
        case kDMActivityFeelingTired:
            feelingString = ACTIVITY_FEELING_TIRED;
            break;
        case kDMActivityFeelingInjured:
            feelingString = ACTIVITY_FEELING_INJURED;
            break;
    }
    
    return feelingString;
}


- (DailymileActivityFeeling)activityFeelingForJSONString:(NSString *)feelingString;
{
    DailymileActivityFeeling feeling = kDMActivityFeelingGreat;
    
    if ([feelingString isEqualToString:ACTIVITY_FEELING_GOOD]) {
        feeling = kDMActivityFeelingGood;
    }
    else if ([feelingString isEqualToString:ACTIVITY_FEELING_ALRIGHT]) {
        feeling = kDMActivityFeelingAlright;
    }
    else if ([feelingString isEqualToString:ACTIVITY_FEELING_BLAH]) {
        feeling = kDMActivityFeelingBlah;
    }
    else if ([feelingString isEqualToString:ACTIVITY_FEELING_TIRED]) {
        feeling = kDMActivityFeelingTired;
    }
    else if ([feelingString isEqualToString:ACTIVITY_FEELING_INJURED]) {
        feeling = kDMActivityFeelingInjured;
    }
    
    return feeling;
}


- (NSString *)jsonStringForDistanceUnit:(DailymileDistanceUnit)distanceUnit
{
    NSString *unit = nil;
    
    switch (distanceUnit)
    {
        case kDMDistanceUnitKM:
            unit = DISTANCE_UNIT_KM;
            break;
            
        case kDMDistanceUnitMeters:
            unit = DISTANCE_UNIT_METERS;
            break;
            
        case kDMDistanceUnitYards:
            unit = DISTANCE_UNIT_YARDS;
            break;
            
        case kDMDistanceUnitMiles:
        default:
            unit = DISTANCE_UNIT_MILES;
            break;
    }
    return unit;
}


- (DailymileDistanceUnit)distanceUnitForJSONString:(NSString *)unitString
{
    DailymileDistanceUnit unit = kDMDistanceUnitMiles;
    
    if ([unitString isEqualToString:DISTANCE_UNIT_KM]) {
        unit = kDMDistanceUnitKM;
    }
    else if ([unitString isEqualToString:DISTANCE_UNIT_METERS]) {
        unit = kDMDistanceUnitMeters;
    }
    else if ([unitString isEqualToString:DISTANCE_UNIT_YARDS]) {
        unit = kDMDistanceUnitYards;
    }
    
    return unit;
}


@end
