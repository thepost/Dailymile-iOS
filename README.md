iOS-Dailymile
=============

The iOS-Dailymile library is for any iOS app that needs to sync to dailymile.

It was created for the needs of "FitFriend" for iPhone, therefore the initial version is fairly limited. Only uploading Entries, and uploading Routes are currently supported. Social integration with dailymile such as Comments, Likes, and Streams are in the future pipeline, but with no set date. I encourage anyone else with this immediate need, to fork the repo and add to this library. 

Dependencies
=============

The following libraries will need to be used for the dailymile-iOS library to use. These are the leading libraries used for networking and authentication, and are also lightweight. So if you're not already using them, please import for Dailymile use:
  - OAuth2Client (https://github.com/nxtbgthng/OAuth2Client) for OAuth2 authentication. 
  - AFNetworking (https://github.com/AFNetworking/AFNetworking) for bridging between iOS6's NSURLConnection and NSURLSession. 

Getting Started: 
=============

### Instantiate Dailymile

1) Drag and drop the Dailymile library folder into your Xcode project, copying the contents. Import the Dailymile library

  ```
  #import "DailymileManager.h"
  ```

2) Create a singleton instance of Dailymile with your Client ID and Secret ID
  
  ```
  self.dailymileManager = [DailymileManager sharedInstance];
  ```  

### Register your app on Dailymile

1) Register it here: http://www.dailymile.com/api/consumers/new It'll give you a client ID and a secret key.

2) In DailymileManager.m replace the kDailymileClientID and kDailymileClientSecret constants with your client ID and secret from Dailymile.

  ```
  #define kDailymileClientID      @"YOUR_CLIENT_ID_HERE"
  #define kDailymileClientSecret  @"YOUR_CLIENT_SECRET_HERE"
  ```

### Create a Custom URL Scheme

1) Click on the main project folder, then select the Info tab. 

2) Under "URL Types" add your client ID to the URL Schemes field, for the auth callback.
  You can append anything to the client ID to make it easier if you're managing multiple redirects in your app. I appended   "dailymile-" to make it "dailymile-CLIENT_ID". 


### Redirect the Auth Code URL

1) In the app delegate, implement the application:openURL:sourceApplication:annotation: method

2) Place whatever validation you want to check for OAuth2, and call DailymileManager's openAuthURL method

  ```
  - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url host] isEqualToString:@"oauth2"])
    {
        NSDictionary *bundleURLs = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"] lastObject];
        NSArray *urlSchemes = [bundleURLs objectForKey:@"CFBundleURLSchemes"];
        
        if ([urlSchemes lastObject])
        {
            //Dailymile string...
            [[DailymileManager sharedInstance] openAuthURL:url];
        }
    }
    
    return TRUE;
}
  ```

The DailymileAuthentication then uses the auth code to get an auth token. You don't have to do anything more, but wait for the success or fail block of whatever action you're trying to do. 


Authenticating Dailymile:
=============

Now that you're set up, you can work in some calls. Here's how you connect via login...

###Connect

Call the DailymileManager's connectWithSuccess:failure: method

```
    [self.dailymileManager connectWithSuccess:^(NSURL *authorizationURL) {
        NSLog(@"Dailymile Connected!");
    }
                                      failure:^(NSError *error) {
                                          NSLog(@"Failed to connect Dailymile! %@", [error description]);
                                      }];
```

###Disconnect

Call the DailymileManager's disconnectWithSuccess:failure: method in the same way.


Uploading to Dailymile:
=============

Uploading is done in 2 stages:

  1) Creating a new Entry

  2) Adding GPS data to the Entry
  
You create a new Dailymile entry through the DailymileManager's uploadActivity method.

You can then update that Dailymile entry with GPS data through the DailymileManager's uploadGPXTraining method. Uploading GPS data is optional, an entry can exist without one. 

Here's an example of uploading:

```
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
```


A few assumptions are made about any GPX file that data is extracted from, and it's up to you to create a GPX in that way:
    
    1) There is only 1 track, but that track can contain multiple track segments. It uses the last (or only) track in any array of tracks.
    
    2) The track name is a good value to use for the Dailymile title.
    
    3) The track comment is a good value to use for the Dailymile message.
