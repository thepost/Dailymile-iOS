//
//  DailymileConstants.h
//  DailymileDemo
//
//  Created by Mike Post on 6/12/13.
//  Copyright (c) 2013 Dashend. All rights reserved.
//

#ifndef DailymileDemo_DailymileConstants_h

#define kDailymileBasePath          @"https://api.dailymile.com"
#define kDailymileAuthorizationURL  @"/oauth/authorize?"
#define kDailymileAccessTokenURL    @"/oauth/token?"
#define kDailymilePeopleURL         @"/people"
#define kDailymilePeopleUserSelf    @"me"
#define kDailymileEntryURL          @"/entries"
#define kDailymileEntryTrackURL     @"/track"
#define kDailymileRouteURL          @"/routes"

typedef enum DailymileActivityType {
    kDMActivityTypeRunning      = 0,
    kDMActivityTypeCycling      = 1,
    kDMActivityTypeWalking      = 2,
    kDMActivityTypeSwimming     = 3,
    kDMActivityTypeFitness      = 4
} DailymileActivityType;

typedef enum DailymileActivityFeeling {
    kDMActivityFeelingGreat     = 0,
    kDMActivityFeelingGood      = 1,
    kDMActivityFeelingAlright   = 2,
    kDMActivityFeelingBlah      = 3,
    kDMActivityFeelingTired     = 4,
    kDMActivityFeelingInjured   = 5
} DailymileActivityFeeling;

typedef enum DailymileDistanceUnit {
    kDMDistanceUnitMiles        = 0,
    kDMDistanceUnitKM           = 1,
    kDMDistanceUnitMeters       = 2,
    kDMDistanceUnitYards        = 3
} DailymileDistanceUnit;


#pragma mark Errors
enum {
    DMErrorCodeInvalidGPXData           = -5001,
    DMErrorCodeInsufficientGPXData,
    DMErrorCodeInvalidActivity
};

NSString *const DMErrorEntryUploadDomain;

#define DailymileDemo_DailymileConstants_h


#endif
