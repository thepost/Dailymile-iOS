//
//  DailymileActivityRoute.m
//
//  Created by Mike Post on 11/12/13.
//  Copyright (c) 2013 Dashend. All rights reserved.
//

#import "DailymileActivityRoute.h"
#import <GPX/GPX.h>


@implementation DailymileActivityRoute


- (id)initWithGPXFile:(NSData *)gpxData
{
    self = [super init];
    
    if (self) {
        [self setGpxFileData:gpxData];
    }
    return self;
}


- (NSString *)gpxString
{
    GPXRoot *gpxRoot = [GPXParser parseGPXWithData:self.gpxFileData];
    
    NSString *gpxString = gpxRoot.gpx;
    return gpxString;
}


@end
