//
//  AppDelegate.m
//  TextMuse2
//
//  Created by Peter Tucker on 4/18/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "AppDelegate.h"
#import "Settings.h"
#import "WalkthroughViewController.h"
#import "ImageDownloader.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

-(id)init {
    self = [super init];
    
    NSString* path = [[NSBundle mainBundle] bundlePath];
    NSString* pListPath = [path stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
    NSDictionary* pList = [NSDictionary dictionaryWithContentsOfFile:pListPath];
    NSMutableArray* prefsArray = [pList objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary* regDict = [NSMutableDictionary dictionary];
    for (NSDictionary* dict in prefsArray) {
        NSString* key = [dict objectForKey:@"Key"];
        if (key) {
            id value = [dict objectForKey:@"DefaultValue"];
            [regDict setObject:value forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:regDict];

    [Settings LoadSettings];
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupNavigationBar:application];
    
    [GlobalState init];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Class userNotification = NSClassFromString(@"UIUserNotificationSettings");
        
        UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        UIApplication* app = [UIApplication sharedApplication];
        if ([app respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            [app registerUserNotificationSettings:settings];
        }
        
        if (userNotification)
        {
            UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    });
    //sleep(2.0);

    return YES;
}

-(void)setupNavigationBar:(UIApplication*) application {
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    NSDictionary* txtAttrs =[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor whiteColor], NSForegroundColorAttributeName,
                             [UIFont fontWithName:@"Lato-Regular" size:21.0], NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:txtAttrs];
    
    UIColor* colorTint = nil;
    
#ifdef UOREGON
    //ffef01
    colorTint = [UIColor colorWithRed:255.0/256 green:239.0/256 blue:1.0/256 alpha:1.0];
#endif
#ifdef WHITWORTH
    //c20202
    colorTint = [UIColor colorWithRed:194.0/256 green:2.0/256 blue:2.0/256 alpha:1.0];
#endif
    
    if (Skin != nil)
        colorTint = [Skin createColor1];

    if (colorTint == nil)
        colorTint = [UIColor colorWithRed:22.0/256 green:194.0/256 blue:223./256 alpha:1.0];
    
    [[UINavigationBar appearance] setTintColor:colorTint];
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NotificationRegistered = ([notificationSettings types] != UIUserNotificationTypeNone);
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSCharacterSet *angleBrackets = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString* token = [[deviceToken description] stringByTrimmingCharactersInSet:angleBrackets];
    [self setDeviceToken: token];
    
    NSString* conn = @"Endpoint=sb://textmusehub-ns.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=9hnIUk/Qjj9zusMfK570F10o5mXY1F9eXVS8REI3ZCw=";
    //NSString*conn2 = @"Endpoint=sb://textmusehub-ns.servicebus.windows.net/;SharedAccessKeyName=DefaultFullSharedAccessSignature;SharedAccessKey=0aoaY8qFpFQkDvxF6ntqKtVEHoqlzeuZGpYDL+2pblw=";
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:conn
                                                             notificationHubPath:@"textmusehub"];
    
    [hub registerNativeWithDeviceToken:deviceToken tags:nil completion:^(NSError* error) {
        if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
        }
    }];
}

// Handle any failure to register. In this case we set the deviceToken to an empty
// string to prevent the insert from failing.
- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register for remote notifications: %@", error);
    //[self setDeviceToken:@""];
}

// Because toast alerts don't work when the app is running, the app handles them.
// This uses the userInfo in the payload to display a UIAlertView.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (NotificationOn) {
        /*
         NSMutableString* msgs = [[NSMutableString alloc] init];
         for (NSString* k in [userInfo keyEnumerator]) {
         [msgs appendFormat:@"\n%@: %@", k, [userInfo objectForKey:k]];
         }
         */
        NSString* msg = [userInfo objectForKey:@"alert"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification Title", nil)
                                                        message:msg delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)application:(UIApplication *)application
        didReceiveLocalNotification:(UILocalNotification *)notification {
    if (NotificationOn) {
        /*
         NSMutableString* msgs = [[NSMutableString alloc] init];
         for (NSString* k in [userInfo keyEnumerator]) {
         [msgs appendFormat:@"\n%@: %@", k, [userInfo objectForKey:k]];
         }
         */
        NSString* msg = [notification alertBody];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification Title", nil)
                                                        message:msg delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self addNotification];
    [self checkForReminder];
    
    [Settings SaveCachedMapFile];
}

+ (BOOL)checkNotificationType:(UIUserNotificationType)type
{
    UIApplication* app = [UIApplication sharedApplication];
    if ([app respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        return (currentSettings.types & type);
    }
    else
        return true;
}

-(void)addNotification {
    if (!NotificationOn) return;
    
    [Settings LoadSettings];
    BOOL n = (NotificationDates == nil || [NotificationDates count] == 0);
    NSDate* notification;
    if (NotificationDates != nil && [NotificationDates count] > 0) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
        [formatter setDateFormat:NotificationDateFormat];
        NSString* lastNotify = [NotificationDates objectAtIndex:[NotificationDates count] - 1];
        notification = [formatter dateFromString:lastNotify];
        n = ([notification compare:[NSDate date]] == NSOrderedAscending);
    }
    if (!n)
        return;
    
    if (NotificationDates == nil)
        NotificationDates = [[NSMutableArray alloc] init];
    
    NSDate* notify = [self getNextNotifyDate: [NSDate date]];
    while (notify != nil) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
        [formatter setDateFormat:NotificationDateFormat];
        NSString* notifyString = [formatter stringFromDate:notify];
        NSDate* notifyDate = [formatter dateFromString:notifyString];
        
        if ([AppDelegate checkNotificationType:UIUserNotificationTypeBadge])
        {
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            [localNotification setApplicationIconBadgeNumber:1];
            [localNotification setFireDate: notifyDate];
            NSString* alertMsg = [Settings GetNotificationText: Data];
            [localNotification setAlertBody: alertMsg];
            [localNotification setTimeZone: [NSTimeZone defaultTimeZone]];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            [NotificationDates addObject:notifyString];
        }

        notify = [self getNextNotifyDate: notify];
    }
    
    [Settings SaveSetting:SettingNotificationDates withValue:NotificationDates];
}

-(NSDate*)getNextNotifyDate:(NSDate*)dateOfInterest {
    NSDate* ret;
    const NSTimeInterval day = 60*60*24;
    
    //If we're looking one week ahead, we're done
    if ([dateOfInterest timeIntervalSinceNow] > day*7)
        return nil;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:dateOfInterest];
    NSInteger weekday = [weekdayComponents weekday];
    // weekday 1 = Sunday for Gregorian calendar
    switch (weekday) {
        case 1: //Sunday
            ret = [dateOfInterest dateByAddingTimeInterval:day];
            break;
        case 2: //Monday
            ret = [dateOfInterest dateByAddingTimeInterval:2*day];
            break;
        case 3: //Tuesday
            ret = [dateOfInterest dateByAddingTimeInterval:day];
            break;
        case 4: //Wednesday
            ret = [dateOfInterest dateByAddingTimeInterval:2*day];
            break;
        case 5: //Thursday
            ret = [dateOfInterest dateByAddingTimeInterval:day];
            break;
        case 6: //Friday
            ret = [dateOfInterest dateByAddingTimeInterval:2*day];
            break;
        case 7: //Saturday
            ret = [dateOfInterest dateByAddingTimeInterval:day];
            break;
    }
    
    return ret;
}

-(void)checkForReminder {
    /*
    //If there's a reminder message and its date has passed, push the message screen to the navigation stack
    if (ReminderMessages != nil && [ReminderMessages count] > 0 &&
        ReminderContactLists != nil && [ReminderContactLists count] > 0) {
        for (int i=(int)[ReminderMessages count]-1; i>=0; i--) {
            NSString* reminderString = [ReminderDates objectAtIndex:i];
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
            [formatter setDateFormat:ReminderDateFormat];
            NSDate* reminder = [formatter dateFromString:reminderString];
            NSDate* now = [NSDate date];
            if (reminder != nil && [reminder compare:now] == NSOrderedAscending) {
                SendMsgViewController* mc = [[SendMsgViewController alloc] init];
                CurrentMessage = [[Message alloc] initFromStorage:[ReminderMessages objectAtIndex:i]];
                
                NSMutableArray* contacts = [[NSMutableArray alloc] init];
                for (NSString* p in [ReminderContactLists objectAtIndex:i]) {
                    UserContact* uc = [Data findUserByPhone:p];
                    if (uc != nil)
                        [contacts addObject:uc];
                }
                
                CurrentContactList = contacts;
                
                [Settings RemoveSettingFromArray:SettingReminderMessages atIndex:i];
                [Settings RemoveSettingFromArray:SettingReminderContactLists atIndex:i];
                [Settings RemoveSettingFromArray:SettingReminderDates atIndex:i];
                
                [navController pushViewController:mc animated:YES];
            }
        }
    }
     */
    if ([AppDelegate checkNotificationType:UIUserNotificationTypeBadge])
    {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self addNotification];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self addNotification];
}

@end
