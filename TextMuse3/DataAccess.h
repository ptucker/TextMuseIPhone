//
//  DataAccess.h
//  FriendlyNotes
//
//  Created by Peter Tucker on 4/20/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UserContact.h"
#import "UserPhone.h"
#import "SponsorInfo.h"
#import "Message.h"
#import "MessageCategory.h"
#import "SkinInfo.h"

@protocol DataRefreshDelegate
-(void)dataRefresh;
@end

@interface DataAccess : NSObject<NSXMLParserDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSMutableDictionary* categories;
    NSMutableDictionary* tmpCategories;
    NSMutableArray* allMessages;
    NSArray* pinnedMsgs;
    NSMutableArray* tmpRegMessages;
    NSMutableArray* tmpVersionMessages;
    NSMutableArray* localImages;
    NSArray* contacts;
    NSArray* headings;
    NSMutableArray* selectContacts;
    BOOL loadingContacts;
    NSTimer* timerLoad;
    BOOL notificationOnly;
    
    NSMutableArray* listeners;

    NSURLConnection* conn;
    NSMutableData* inetdata;
    
    BOOL parseFailed;
    NSMutableString* xmldata;
    NSMutableString* partsdata;
    MessageCategory* currentCategory;
    NSString* currentElement;
    int currentMsgId;
    int categoryOrder;
    BOOL newMsg;
    BOOL likedMsg;
    int likeCount;
    BOOL versionMsg;
    NSString* currentText, *currentMediaUrl, *currentUrl;
    
    //NSString* documentdir;
    
    int backgroundRefresh;
}

@property (nonatomic, copy) NSString* contactFilter;

-(id)init;
-(void)reloadData;
-(void)reloadNotifications;
-(void)initContacts;
-(void)addListener:(id)listener;
-(NSArray*)getCategories;
-(NSArray*)getRequiredCategories;
-(MessageCategory*)getCategory:(NSString*)c;
-(SponsorInfo*)getSponsorForCategory:(NSString*)category;
-(NSArray*)getContacts;
-(void)sortContacts;
-(NSArray*)getContactHeadings;
-(NSArray*)getContactsForHeading: (NSString*)h;
-(int)getIndexForContact:(UserContact*)uc;
-(UserContact*)findUserByPhone:(NSString*)targetPhone;
-(UserContact*)chooseRandomContact;
-(NSArray*)getAllMessages;
-(NSArray*)getPinnedMessages;
-(NSArray*)resortMessages;
-(void)setMessagePin:(Message*)msg withValue:(BOOL)pin;
-(NSArray*)getMessagesForCategory:(NSString*)category;
-(int)getNewMessageCountForCategory:(NSString*)category;
-(Message*)chooseRandomMessage;
-(void)selectUser:(UserContact*)contact toValue:(BOOL)on;
-(NSArray*)getSelectedUsers;
-(BOOL)isUserSelected:(UserContact*)contact;
-(void)clearSelectedUsers;

@end
