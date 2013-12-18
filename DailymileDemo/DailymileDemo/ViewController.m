//
//  ViewController.m
//  DailymileDemo
//
//  Created by Mike Post on 4/12/13.
//  Copyright (c) 2013 Dashend. All rights reserved.
//

#import "ViewController.h"
#import <GPX/GPX.h>


@interface ViewController ()

@property (nonatomic, weak) DailymileManager *dailymileManager;

@end


@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dailymileManager = [DailymileManager sharedInstance];
    
    //Update the connectButton before the user can use it...
    [self determineConnect];
}


- (void)determineConnect
{
    BOOL isConnected = [[self.dailymileManager dailymileAuthentication] isConnected];
    
    if (isConnected == YES) {
        [self.connectButton setTitle:@"Disconnect Dailymile" forState:UIControlStateNormal];
        
        [self.connectButton removeTarget:self action:@selector(connectDailymile:) forControlEvents:UIControlEventTouchUpInside];
        [self.connectButton addTarget:self action:@selector(disconnectDailymile:) forControlEvents:UIControlEventTouchUpInside];
        
        //Download profile with connected login. Test only.
        [self.dailymileManager downloadProfile:kDailymilePeopleUserSelf
                                   withSuccess:^(id response) {
//                                       DailymileProfile *profile = [DailymileProfile profileFromJSON:response];
//                                       NSLog(@"Profile: \n%@", profile);
                                   }
                                       failure:^(NSError *error) {
                                           NSLog(@"Error: %@", error);
                                       }];
    }
    else {
        [self.connectButton setTitle:@"Connect Dailymile" forState:UIControlStateNormal];
        
        [self.connectButton removeTarget:self action:@selector(disconnectDailymile:) forControlEvents:UIControlEventTouchUpInside];
        [self.connectButton addTarget:self action:@selector(connectDailymile:) forControlEvents:UIControlEventTouchUpInside];
    }
}


#pragma mark - IBAction
- (IBAction)connectDailymile:(id)sender
{
    [self.dailymileManager connectWithSuccess:^(NSURL *authorizationURL) {
        NSLog(@"Dailymile Connected!");
        [self determineConnect];
    }
                                      failure:^(NSError *error) {
                                          NSLog(@"Failed to connect Dailymile! %@", [error description]);
                                      }];
}


- (IBAction)disconnectDailymile:(id)sender
{
    [self.dailymileManager disconnectWithSuccess:^(NSURL *authorizationURL) {
        NSLog(@"Dailymile Disconnected!");
        [self determineConnect];
    }
                                         failure:^(NSError *error) {
                                             NSLog(@"Failed to disconnect Dailymile! %@", [error description]);
                                         }];
}


- (IBAction)uploadDailymile:(id)sender
{
    //Set a DailymileActivity test object...
    DailymileActivity *activity = [[DailymileActivity alloc] initWithActivityType:kDMActivityTypeRunning];
    
    [activity setTitle:@"Running"];
    [activity setMessage:@"Fake test run only."];
    
    [activity setActivityFeeling:kDMActivityFeelingGood];
    [activity setDateCompleted:[NSDate date]];
    [activity setDurationInSeconds:@(1496)];
    [activity setDistanceUnit:kDMDistanceUnitKM];
    [activity setDistanceValue:@(6.57)];
    
    //Upload
    [self.dailymileManager uploadActivity:activity
                                 withSuccess:^(id response) {
                                     NSLog(@"Uploaded Log: %@", response);
                                     
                                     NSInteger entryID = [[response objectForKey:@"id"] integerValue];
                                     if (([response objectForKey:@"id"] != nil) && (entryID > 0))
                                     {
                                         //Get GPX file...
                                         NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"fitfriend_log_2013-11-30" ofType:@"gpx"];
                                         NSData *gpxData = [NSData dataWithContentsOfFile:resourcePath];
                                         
                                         [self.dailymileManager uploadGPXTraining:gpxData
                                                                     toActivityID:entryID
                                                                      withSuccess:^(id response) {
                                                                      }
                                                                          failure:^(NSError *error) {
                                                                          }];
                                     }
                                 }
                                     failure:^(NSError *error) {
                                         NSLog(@"Error uploading Log: %@", [error description]);
                                     }];
}


@end
