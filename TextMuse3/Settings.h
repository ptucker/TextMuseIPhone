//
//  Settings.h
//  FriendlyNotes
//
//  Created by Peter Tucker on 5/31/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import "Message.h"
#import "DataAccess.h"
#import "SkinInfo.h"
#import <Foundation/Foundation.h>

@interface Settings : NSObject

+(void) SaveSetting:(NSString*)setting withValue:(NSObject*)value;
+(void) SaveSkinData;
+(void) ClearSkinData;
+(void) SaveCachedMapFile;
+(void) ClearStaleMediaFiles;
+(void) AppendSettingToArray:(NSString*)setting withValue:(NSObject*)value;
+(void) RemoveSettingFromArray:(NSString*)setting atIndex:(int)i;
+(void) ClearSetting:(NSString*)setting;
+(void) LoadSettings;
+(void) AddRecentContact:(NSString*)phone;
+(void) AddRecentMessage:(Message*)msg;
+(void) SaveUserMessages;
+(void) AddGroup:(NSString*)grp withContacts:(NSArray*)contacts;
+(void) RemoveGroup:(NSString*)grp;
+(void) AddContact:(NSString*)contact forGroup:(NSString*)group;
+(void) RemoveContact:(NSString*)contact fromGroup:(NSString*)group;
+(NSString*) GetNotificationText:(DataAccess*)data;
+(void) UpdateCategoryList;

@end

extern BOOL WalkThrough;

extern NSString* InitialCategory;
extern BOOL SaveRecentContacts;
extern BOOL SaveRecentMessages;
extern NSMutableArray* RecentContacts;
extern NSMutableArray* RecentMessages;
extern NSMutableDictionary* RecentCategories;
extern NSMutableArray* YourMessages;

extern NSString* SettingInitialCategory;
extern NSString* SettingSaveRecentContacts;
extern NSString* SettingSaveRecentMessages;
extern NSString* SettingRecentContacts;
extern NSString* SettingRecentMessages;
extern NSString* SettingRecentCategories;
extern NSString* SettingYourMessages;
extern NSString* SettingRecentContactsCount;
extern NSString* SettingRecentMessagesCount;
extern NSString* SettingReminderMessages;
extern NSString* SettingReminderContactLists;
extern NSString* SettingSortLastName;
extern NSString* SettingReminderDates;
extern NSString* SettingNotificationDate;
extern NSString* SettingNotificationDates;
extern NSString* SettingNotificationOn;
extern NSString* SettingNotificationMsgs;
extern NSString* SettingShowIntro;
extern NSString* SettingAskRegistration;
extern NSString* SettingNamedGroups;
extern NSString* SettingChosenCategories;
extern NSString* SettingKnownCategories;
extern NSString* SettingCategoryList;
extern NSString* SettingLastNoteDownload;
extern NSString* SettingUserName;
extern NSString* SettingUserEmail;
extern NSString* SettingUserAge;
extern NSString* SettingUserBirthMonth;
extern NSString* SettingUserBirthYear;
extern NSString* SettingAppID;
extern NSString* SettingSkin;

extern int MaxRecentContacts;
extern int MaxRecentMessages;

extern NSMutableArray* ReminderMessages;
extern NSMutableArray* ReminderContactLists;
extern NSMutableArray* ReminderDates;
extern NSString* ReminderDateFormat;
extern NSString* NotificationDate;
extern NSMutableArray* NotificationDates;
extern NSString* NotificationDateFormat;
extern NSMutableArray* NotificationMsgs;
extern BOOL NotificationOn;
extern BOOL NotificationRegistered;
extern NSMutableDictionary* NamedGroups;
extern BOOL SortLastName;
//extern NSMutableArray* ChosenCategories;
//extern NSMutableDictionary* KnownCategories;
extern NSMutableDictionary* CategoryList;
extern BOOL ShowIntro;
extern BOOL AskRegistration;
extern NSString* UserName;
extern NSString* UserEmail;
extern NSString* UserAge;
extern NSString* UserBirthMonth;
extern NSString* UserBirthYear;
extern NSString* AppID;
extern SkinInfo* Skin;

extern NSString* CachedMediaMappingFile;
extern NSMutableDictionary* CachedMediaMapping;
extern NSMutableDictionary* ActiveURLs;

extern NSString* LastNoteDownload;
