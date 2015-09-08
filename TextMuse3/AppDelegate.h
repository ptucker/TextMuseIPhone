//
//  AppDelegate.h
//  TextMuse2
//
//  Created by Peter Tucker on 4/18/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
#import "GlobalState.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSData *deviceToken;

-(void)registerRemoteNotificationWithAzure;

@end

