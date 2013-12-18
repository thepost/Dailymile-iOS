//
//  ViewController.h
//  DailymileDemo
//
//  Created by Mike Post on 4/12/13.
//  Copyright (c) 2013 Dashend. All rights reserved.
//

#import "DailymileManager.h"


/**
 The is the root `UIViewController`. Demos connecting to Dailymile, and uploading a pre-existing GPX to Dailymile.
 
 @discussion
 For the exclusive purpose of the demo, there are some shortcomings you should be aware of:
 - Minimal error handling is demoed. A consumer app should have a lot more error handling if anything goes wrong either with connecting or uploading.
 - The pre-existing GPX file is just a training log exported from `FitFriend`, and is sufficient for demo purposes.
 For non-demo purposes, it is encouraged to create a GPX file from your NSObject or NSManagedObject subclasses that store the run data, then upload in the same way via GPX.
 */
@interface ViewController : UIViewController {
}

/**
 `UIButton` to connect or disconnect from Dailymile.
 */
@property (strong, nonatomic) IBOutlet UIButton *connectButton;

/**
 `UIButton` to upload to Dailymile.
 */
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;

/**
 Sets up the connectButton with the appropriate title and `IBAction`, according to the auth status given by the DailymileManager.
 */
- (void)determineConnect;

/**
 Connects to Dailymile, if already disconnected.
 */
- (IBAction)connectDailymile:(id)sender;

/**
 Connects to Dailymile, if already disconnected.
 */
- (IBAction)disconnectDailymile:(id)sender;

/**
 Uploads GPX file to Dailymile.
 */
- (IBAction)uploadDailymile:(id)sender;

@end
