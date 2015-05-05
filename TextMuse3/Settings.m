//
//  Settings.m
//  FriendlyNotes
//
//  Created by Peter Tucker on 5/31/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import "Settings.h"
#import "UserContact.h"

BOOL WalkThrough = false;

NSString* InitialCategory = @"Trending";
BOOL SaveRecentContacts = true;
BOOL SaveRecentMessages = false;
BOOL ShowIntro = true;
BOOL AskRegistration = true;

NSString* SettingInitialCategory = @"SettingInitialCategory";
NSString* SettingSaveRecentContacts = @"SettingSaveRecentContacts";
NSString* SettingSaveRecentMessages = @"SettingSaveRecentMessages";
NSString* SettingRecentContacts = @"SettingRecentContacts";
NSString* SettingRecentMessages = @"SettingRecentMessages";
NSString* SettingRecentCategories = @"SettingRecentCategories";
NSString* SettingYourMessages = @"YourMessages";
NSString* SettingRecentContactsCount = @"SettingRecentContactsCount";
NSString* SettingRecentMessagesCount = @"SettingRecentMessagesCount";
NSString* SettingReminderMessages = @"SettingReminderMessages";
NSString* SettingReminderContactLists = @"SettingReminderContactLists";
NSString* SettingSortLastName = @"SettigSortLastName";
NSString* SettingReminderDates = @"SettingReminderDates";
NSString* SettingNotificationDate = @"SettingNotificationDate";
NSString* SettingNotificationOn = @"SettingNotificationOn";
NSString* SettingNotificationMsgs = @"SettingNotificationMsgs";
NSString* SettingShowIntro = @"SettingShowIntro";
NSString* SettingAskRegistration = @"SettingAskRegistration";
NSString* SettingNamedGroups = @"SettingNamedGroups";
NSString* SettingChosenCategories = @"SettingChosenCategories";
NSString* SettingKnownCategories = @"SettingKnownCategories";
NSString* SettingLastNoteDownload = @"SettingLastNoteDownload";
NSString* SettingUserName=@"SettingUserName";
NSString* SettingUserEmail=@"SettingUserEmail";
NSString* SettingUserAge=@"SettingUserAge";
NSString* SettingUserBirthMonth=@"SettingBirthMonth";
NSString* SettingUserBirthYear=@"SettingBirthYear";
NSString* SettingAppID=@"SettingAppID";

NSString* ReminderDateFormat = @"dd/MM/yyyy hh:mm:ss a";
NSString* NotificationDateFormat = @"dd/MM/yyyy 12:00:00 a";
BOOL NotificationOn = YES;
BOOL NotificationRegistered = YES;

NSMutableArray* RecentContacts = nil;
int MaxRecentContacts = 5;
NSMutableArray* RecentMessages = nil;
int MaxRecentMessages = 5;
NSMutableArray* YourMessages = nil;
NSMutableDictionary* RecentCategories = nil;

NSMutableArray* ReminderMessages = nil;
NSMutableArray* ReminderContactLists = nil;
NSMutableArray* ReminderDates = nil;
NSString* NotificationDate = nil;
NSMutableArray* NotificationMsgs = nil;
NSMutableDictionary* NamedGroups = nil;
BOOL SortLastName = YES;
NSMutableArray* ChosenCategories = nil;
NSMutableDictionary* KnownCategories = nil;

NSString* CachedMediaMappingFile = @"media.dat";
NSMutableDictionary* CachedMediaMapping  = nil;
NSMutableDictionary* ActiveURLs = nil;

NSString* LastNoteDownload;

NSString* UserName;
NSString* UserEmail;
NSString* UserAge;
NSString* UserBirthMonth;
NSString* UserBirthYear;
NSString* AppID;

@implementation Settings

+(void)SaveSetting:(NSString *)setting withValue:(NSObject *)value {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    
    [defs setObject:value forKey:setting];
    [defs synchronize];
}

+(void)AppendSettingToArray:(NSString*)setting withValue:(NSObject*)value {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray* values =  [NSMutableArray arrayWithArray: [defs arrayForKey:setting]];
    [values addObject:value];
    [defs setObject:values forKey:setting];
}

+(void)RemoveSettingFromArray:(NSString*)setting atIndex:(int)i {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray* values =  [NSMutableArray arrayWithArray: [defs arrayForKey:setting]];
    if (i >= 0 && i < [values count])
        [values removeObjectAtIndex:i];
    
    [defs setObject:values forKey:setting];
}

+(void)ClearSetting:(NSString *)setting {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    
    [defs removeObjectForKey:setting];
    [defs synchronize];
}

+(void)LoadSettings {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    
    if ([defs stringForKey:SettingInitialCategory] != nil &&
            [[defs stringForKey:SettingInitialCategory] length] > 0)
        InitialCategory = [defs stringForKey:SettingInitialCategory];

    if ([defs stringForKey:SettingSaveRecentContacts] != nil &&
            [[defs stringForKey:SettingSaveRecentContacts] isEqualToString:@"NO"])
        SaveRecentContacts = false;
    if ([defs stringForKey:SettingRecentContactsCount] != nil)
        MaxRecentContacts = [[defs stringForKey:SettingRecentContactsCount] intValue];
    if ([defs stringForKey:SettingSaveRecentMessages] != nil &&
        [[defs stringForKey:SettingSaveRecentMessages] isEqualToString:@"YES"])
        SaveRecentMessages = true;
    if ([defs stringForKey:SettingRecentMessagesCount] != nil)
        MaxRecentMessages = [[defs stringForKey:SettingRecentMessagesCount] intValue];
    if ([defs stringForKey:SettingSaveRecentMessages] != nil &&
            [[defs stringForKey:SettingSaveRecentMessages] isEqualToString:@"YES"])
        SaveRecentMessages = true;
    if ([defs arrayForKey:SettingRecentContacts] != nil)
        RecentContacts = [NSMutableArray arrayWithArray:[defs arrayForKey:SettingRecentContacts]];
    else
        RecentContacts = [[NSMutableArray alloc] init];
    if ([defs dictionaryForKey:SettingRecentCategories] != nil)
        RecentCategories = [NSMutableDictionary dictionaryWithDictionary:[defs dictionaryForKey:SettingRecentCategories]];
    else
        RecentCategories = [[NSMutableDictionary alloc] init];
    
    SortLastName = NO;
    [Settings SaveSetting:SettingSortLastName withValue:SortLastName ? @"YES" : @"NO"];
    if ([defs stringForKey:SettingSortLastName] != nil)
        SortLastName = [[defs stringForKey:SettingSortLastName] isEqualToString:@"NO"];

    SortLastName = NO;
    //[defs setObject:nil forKey:SettingRecentMessages];
    if ([defs arrayForKey:SettingRecentMessages] != nil) {
        NSMutableArray* rmsgs = [NSMutableArray arrayWithArray:[defs arrayForKey:SettingRecentMessages]];
        RecentMessages = [[NSMutableArray alloc] init];
        for (NSString*rmsg in rmsgs) {
            [RecentMessages addObject:[[Message alloc] initFromStorage:rmsg]];
        }
    }
    else
        RecentMessages = [[NSMutableArray alloc] init];
    if ([defs arrayForKey:SettingYourMessages] != nil) {
        NSMutableArray* rmsgs = [NSMutableArray arrayWithArray:[defs arrayForKey:SettingYourMessages]];
        YourMessages = [[NSMutableArray alloc] init];
        for (int i=0; i<[rmsgs count]; i++) {
            NSString* rmsg = [rmsgs objectAtIndex:i];
            [YourMessages addObject:[[Message alloc] initFromUserText:rmsg atIndex:i]];
        }
    }
    else {
        YourMessages = [[NSMutableArray alloc] init];
        for (int i=0; i<10; i++)
            [YourMessages addObject:[[Message alloc] initFromUserText:@"" atIndex:i]];
    }
    
    if ([defs arrayForKey:SettingReminderMessages] != nil)
        ReminderMessages = [NSMutableArray arrayWithArray: [defs arrayForKey:SettingReminderMessages]];
    if ([defs arrayForKey:SettingReminderContactLists] != nil)
        ReminderContactLists =
            [NSMutableArray arrayWithArray:[defs arrayForKey:SettingReminderContactLists]];
    if ([defs arrayForKey:SettingReminderDates] != nil)
        ReminderDates = [NSMutableArray arrayWithArray: [defs arrayForKey:SettingReminderDates]];

    if ([defs stringForKey:SettingNotificationDate] != nil &&
            [[defs stringForKey:SettingNotificationDate] length] > 0)
        NotificationDate = [defs stringForKey:SettingNotificationDate];
    NotificationOn = YES;
    if ([defs stringForKey:SettingNotificationOn] != nil &&
        [[defs stringForKey:SettingNotificationOn] length] == 1)
        NotificationOn = [[defs stringForKey:SettingNotificationOn] isEqualToString:@"1"];
    if ([defs arrayForKey:SettingNotificationMsgs] != nil)
        NotificationMsgs = [NSMutableArray arrayWithArray: [defs arrayForKey:SettingNotificationMsgs]];
    
    if ([defs stringForKey:SettingShowIntro] != nil &&
        [[defs stringForKey:SettingShowIntro] length] == 1)
        ShowIntro = [[defs stringForKey:SettingShowIntro] isEqualToString:@"1"];
    if ([defs stringForKey:SettingAskRegistration] != nil &&
        [[defs stringForKey:SettingAskRegistration] length] == 1)
        AskRegistration = [[defs stringForKey:SettingAskRegistration] isEqualToString:@"1"];
    
    NamedGroups = [[NSMutableDictionary alloc] init];
    //[defs setObject:nil forKey:SettingNamedGroups];
    if ([defs arrayForKey:SettingNamedGroups] != nil) {
        NSArray* grps = [defs arrayForKey:SettingNamedGroups];
        for (NSString* grp in grps) {
            //[defs removeObjectForKey:grp];
            NSArray* names = [defs arrayForKey:grp];
            if (names != nil)
                [NamedGroups setObject:names forKey:grp];
        }
    }
    //[defs removeObjectForKey:SettingNamedGroups];
    
    //[defs removeObjectForKey:SettingChosenCategories];
    if ([defs arrayForKey:SettingChosenCategories] != nil) {
        ChosenCategories = [NSMutableArray arrayWithArray:[defs arrayForKey:SettingChosenCategories]];
        //remove duplicates
        NSOrderedSet *mySet = [[NSOrderedSet alloc] initWithArray:ChosenCategories];
        ChosenCategories = [[NSMutableArray alloc] initWithArray:[mySet array]];
    }
    else
        ChosenCategories = nil;
    if ([defs dictionaryForKey:SettingKnownCategories] != nil)
        KnownCategories = [NSMutableDictionary dictionaryWithDictionary:[defs dictionaryForKey:SettingKnownCategories]];
    else
        KnownCategories = [[NSMutableDictionary alloc] init];

    LastNoteDownload = nil;
    if ([defs stringForKey:SettingLastNoteDownload] != nil &&
        [[defs stringForKey:SettingLastNoteDownload] length] == 1)
        LastNoteDownload = [defs stringForKey:SettingLastNoteDownload];
    
    //[defs removeObjectForKey:SettingUserName];
    //[defs removeObjectForKey:SettingUserEmail];
    //[defs removeObjectForKey:SettingUserAge];
    if ([defs stringForKey:SettingUserName] != nil &&
        [[defs stringForKey:SettingUserName] length] > 0)
        UserName = [defs stringForKey:SettingUserName];
    if ([defs stringForKey:SettingUserEmail] != nil &&
        [[defs stringForKey:SettingUserEmail] length] > 0)
        UserEmail = [defs stringForKey:SettingUserEmail];
    if ([defs stringForKey:SettingUserAge] != nil &&
        [[defs stringForKey:SettingUserAge] length] > 0)
        UserAge = [defs stringForKey:SettingUserAge];
    if ([defs stringForKey:SettingUserBirthMonth] != nil &&
        [[defs stringForKey:SettingUserBirthMonth] length] > 0)
        UserBirthMonth = [defs stringForKey:SettingUserBirthMonth];
    if ([defs stringForKey:SettingUserBirthYear] != nil &&
        [[defs stringForKey:SettingUserBirthYear] length] > 0)
        UserBirthYear = [defs stringForKey:SettingUserBirthYear];
    if ([defs stringForKey:SettingAppID] != nil &&
        [[defs stringForKey:SettingAppID] length] > 0)
        AppID = [defs stringForKey:SettingAppID];
    
    [self LoadCachedMapping];
}

+(void)LoadCachedMapping {
    if (CachedMediaMapping != nil) return;
    
    //NSArray* docdirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString* docdir = [docdirs objectAtIndex:0];
    //NSString* mapfile = [docdir stringByAppendingPathComponent:CachedMediaMappingFile];
    NSString* mapfile = [NSTemporaryDirectory() stringByAppendingPathComponent:CachedMediaMappingFile];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:mapfile])
        CachedMediaMapping = [NSKeyedUnarchiver unarchiveObjectWithFile:mapfile];
    else
        CachedMediaMapping = [[NSMutableDictionary alloc] init];
    
    ActiveURLs = [[NSMutableDictionary alloc] init];
}

+(void)SaveCachedMapFile {
    //NSArray* docdirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString* docdir = [docdirs objectAtIndex:0];
    //NSString* mapfile = [docdir stringByAppendingPathComponent:CachedMediaMappingFile];
    NSString* mapfile = [NSTemporaryDirectory() stringByAppendingPathComponent:CachedMediaMappingFile];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:mapfile])
        [[NSFileManager defaultManager] removeItemAtPath:mapfile error:nil];
    [NSKeyedArchiver archiveRootObject:CachedMediaMapping toFile:mapfile];
}

+(void) ClearStaleMediaFiles {
    @synchronized(CachedMediaMapping) {
        for (NSString* k in [CachedMediaMapping keyEnumerator]) {
            if ([ActiveURLs objectForKey:k] == nil) {
                [[NSFileManager defaultManager] removeItemAtPath:[CachedMediaMapping objectForKey:k] error:nil];
                [CachedMediaMapping removeObjectForKey:k];
            }
        }
    }
}

+(void)AddRecentContact:(NSString *)phone {
    if (!SaveRecentContacts) return;
    
    BOOL found = false;
    for (int i=0; !found && i < [RecentContacts count]; i++) {
        found |= [phone isEqualToString:[RecentContacts objectAtIndex:i]];
    }
    if (found)
        [RecentContacts removeObject:phone];
    
    [RecentContacts insertObject:phone atIndex:0];
    while ([RecentContacts count] > MaxRecentContacts)
        [RecentContacts removeLastObject];
    
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    
    [defs setObject:RecentContacts forKey:SettingRecentContacts];
    [defs synchronize];

}

+(void)AddRecentMessage:(Message *)msg {
    if (!SaveRecentMessages) return;
    if ([msg text] == nil) return;
    
    BOOL found = false;
    for (int i=0; !found && i < [RecentMessages count]; i++) {
        Message* recentMsg = [RecentMessages objectAtIndex:i];
        found |= [[msg text] isEqualToString:[recentMsg text]];
    }
    if (found) return;
    
    [RecentMessages addObject:msg];
    long start = [RecentMessages count] >= MaxRecentMessages
        ? MaxRecentMessages - 1 : [RecentMessages count] - 1;
    for (long i=start; i>0; i--) {
        [RecentMessages replaceObjectAtIndex:i withObject:[RecentMessages objectAtIndex:i-1]];
    }
    [RecentMessages replaceObjectAtIndex:0 withObject:msg];
    
    NSMutableArray* save = [[NSMutableArray alloc] init];
    for (Message* m in RecentMessages) {
        NSString* msgConvert = [m stringForStorage];
        [save addObject:msgConvert];
    }
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    
    [defs setObject:save forKey:SettingRecentMessages];
    [defs synchronize];
}

+(void)SaveUserMessages {
    NSMutableArray* umsgs = [[NSMutableArray alloc] init];
    for (Message* m in YourMessages) {
        [umsgs addObject:[m text]];
    }
    [Settings SaveSetting:SettingYourMessages withValue:umsgs];
}

+(void)AddGroup:(NSString*)grp withContacts:(NSArray*)contacts {
    NSMutableArray* cs = [[NSMutableArray alloc] init];
    for (UserContact* uc in contacts) {
        [cs addObject:[uc getPhone]];
    }
    [NamedGroups setObject:cs forKey:grp];
    
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSMutableArray* gs = [[NSMutableArray alloc] init];
    for (NSString* k in [NamedGroups keyEnumerator]) {
        [gs addObject:k];
    }
    [defs setObject:gs forKey:SettingNamedGroups];
    for (NSString* k in [NamedGroups keyEnumerator]) {
        NSArray* grp = [NamedGroups objectForKey:k];
        [defs setObject:grp forKey:k];
    }
    
    [defs synchronize];
}

+(void)RemoveGroup:(NSString*)grp {
    [NamedGroups removeObjectForKey:grp];
    
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSMutableArray* gs = [[NSMutableArray alloc] init];
    for (NSString* k in [NamedGroups keyEnumerator]) {
        [gs addObject:k];
    }
    [defs setObject:gs forKey:SettingNamedGroups];
    for (NSString* k in [NamedGroups keyEnumerator]) {
        NSArray* grp = [NamedGroups objectForKey:k];
        [defs setObject:grp forKey:k];
    }
    
    [defs synchronize];
}

+(void)RemoveContact:(NSString*)contact fromGroup:(NSString*)group {
    NSMutableArray* cs = [NSMutableArray arrayWithArray:[NamedGroups objectForKey:group]];
    [cs removeObject:contact];
    [NamedGroups setObject:cs forKey:group];

    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    
    cs = [NSMutableArray arrayWithArray:[defs objectForKey:group]];
    [cs removeObject:contact];
    [defs setObject:cs forKey:group];
    [defs synchronize];
}

+(void)AddContact:(NSString*)contact forGroup:(NSString*)group {
    NSMutableArray* cs = [NSMutableArray arrayWithArray:[NamedGroups objectForKey:group]];
    if (cs == nil)
        cs = [[NSMutableArray alloc] init];
    [cs addObject:contact];
    [NamedGroups setObject:cs forKey:group];

    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    
    cs = [NSMutableArray arrayWithArray:[defs objectForKey:group]];
    [cs addObject:contact];
    [defs setObject:cs forKey:group];
    [defs synchronize];
}

+(NSString*) GetNotificationText:(DataAccess*)data {
    if (NotificationMsgs == nil) {
        NotificationMsgs = [NSMutableArray arrayWithObjects:
                            NSLocalizedString(@"Notification 1", nil),
                            NSLocalizedString(@"Notification 2", nil),
                            NSLocalizedString(@"Notification 3", nil),
                            NSLocalizedString(@"Notification 4", nil),
                            nil];
    }

    int inot = arc4random() % [NotificationMsgs count];
    NSString* txt = [NotificationMsgs objectAtIndex:inot];
    if ([txt rangeOfString:@"{RecentContact}"].location != NSNotFound) {
        if (data != nil && [[data getContacts] count] > 0) {
            UserContact* uc = nil;
            if ([RecentContacts count] != 0) {
                int icon = arc4random() % [RecentContacts count];
                NSString* phone = [RecentContacts objectAtIndex:icon];
                uc = [data findUserByPhone:phone];
            }
            else {
                uc = [data chooseRandomContact];
            }
            NSString* name = [NSString stringWithFormat:@"%@ %@", [uc firstName], [uc lastName]];
            txt = [txt stringByReplacingOccurrencesOfString:@"{RecentContact}" withString:name];
        }
        else
            txt = [txt stringByReplacingOccurrencesOfString:@"{RecentContact}" withString:@"a friend"];

    }
    else if ([txt rangeOfString:@"{RecentNote}"].location != NSNotFound) {
        NSString* msg;
        if ([RecentMessages count] != 0) {
            int imsg = arc4random() % [RecentMessages count];
            msg = [NSString stringWithFormat:@"'%@'", [[RecentMessages objectAtIndex:imsg] text]];
        }
        else if (data != nil && [[data getCategories] count] > 0) {
            msg = [NSString stringWithFormat:@"'%@'", [[data chooseRandomMessage] text]];
        }
        else
            msg = NSLocalizedString(@"Notification suffix", nil);
        txt = [txt stringByReplacingOccurrencesOfString:@"{RecentNote}" withString:msg];
    }
    return txt;
}

@end
