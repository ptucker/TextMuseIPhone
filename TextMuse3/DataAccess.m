/*
 SELECT C.ID, C.Name, IFNULL(NS.Sends, 0) AS Sends, NSTotal.TotalSends as SendsTotal
 from Categories C LEFT JOIN (select C.ID, count(*) as Sends from NoteSends, Notes N, Categories C where NoteID=N.ID AND N.CategoryID=C.ID AND TIMESTAMPDIFF(HOUR, SendDate, now()) < 24 group by C.ID order by Sends DESC) AS NS on C.ID=NS.ID, (select C.ID, count(*) as TotalSends from NoteSends, Notes N, Categories C where NoteID=N.ID AND N.CategoryID=C.ID group by C.ID order by TotalSends DESC) AS NSTotal WHERE C.ID=NSTotal.ID ORDER BY NS.Sends DESC, NSTotal.TotalSends DESC, C.Name limit 0, 100;
 
 */

//
//  DataAccess.m
//  FriendlyNotes
//
//  Created by Peter Tucker on 4/20/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataAccess.h"
#import "Settings.h"
#import "GlobalState.h"
#import "Reachability.h"
#import "ImageDownloader.h"
#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>

NSString* urlNotes = @"http://www.textmuse.com/admin/notes.php";
NSString* localNotes = @"notes.xml";
const int HIDEMESSAGE = 1000;

@implementation DataAccess
@synthesize contactFilter;

-(id)init {
    timerLoad = nil;
    
    [self reloadData];
    
    return self;
}

-(void)reloadData {
    //We're already downloading. Knock it off!
    if (conn != nil) {
        for (NSObject* l in listeners) {
            if ([l respondsToSelector:@selector(dataRefresh)])
                [l performSelector:@selector(dataRefresh)];
        }

        return;
    }
    
    selectContacts = [[NSMutableArray alloc] init];
    SponsorFollows = [[NSMutableSet alloc] init];
    notificationOnly = false;
    
    pinnedMsgs = [SqlDb getPinnedMessages];
    [self initCategories];
    
    //[self initContacts];
}

-(void)reloadNotifications {
    notificationOnly = true;
    [self initCategories];
}

-(void)addListener:(id)listener {
    if (listeners == nil)
        listeners = [[NSMutableArray alloc] init];
    
    [listeners addObject:listener];
}

-(void)initCategories {
    currentMsgId = 0;
    
    if (categories == nil || [categories count] == 0) {
        [self loadFromFile];
    }
    
    [self loadFromInternet];
    
#ifdef UNIVERSITY
    if (!notificationOnly) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadLocalImages];
        });
    }
#endif
}

-(void) loadFromFile {
    @try {
        NSString* file = [NSTemporaryDirectory() stringByAppendingPathComponent:localNotes];

        if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
            inetdata = [NSMutableData dataWithData:[[self createFile]
                                                    dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else {
            inetdata = [NSMutableData dataWithContentsOfFile:file];
        }
    
        [self parseMessageData];
        if (parseFailed) {
            inetdata = [NSMutableData dataWithData:[[self createFile] dataUsingEncoding:NSUTF8StringEncoding]];
            [self parseMessageData];
        }
        categories = tmpCategories;
        [self mergeMessages];
    }
    @catch (id ex) {
        inetdata = [NSMutableData dataWithData:[[self createFile] dataUsingEncoding:NSUTF8StringEncoding]];
        [self parseMessageData];
        categories = tmpCategories;
        [self mergeMessages];
    }
    for (NSObject* l in listeners) {
        if ([l respondsToSelector:@selector(dataRefresh)])
            [l performSelector:@selector(dataRefresh)];
    }

    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"** Debug **"
                                                    message:[NSString stringWithFormat:@"cached category count: %ld bytes", [[self getCategories] count]]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
     */
}

-(NSString*)createFile {
    NSString* initialXMLFile = @"textmusedata";
#ifdef OODLES
    initialXMLFile = @"oodlesdata";
#endif
#ifdef NRCC
    initialXMLFile = @"nrccdata";
#endif
#ifdef YOUTHREACH
    initialXMLFile = @"youthreach";
#endif
    NSString *filePath = [[NSBundle mainBundle] pathForResource:initialXMLFile ofType:@"xml"];
    NSString* initialXML = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    return initialXML;
}

-(void)loadFromInternet {
    if (timerLoad != nil)
        [timerLoad invalidate];
    timerLoad = nil;
    
    [ImageDownloader CancelDownloads];
    
    NSDateFormatter *dateformat=[[NSDateFormatter alloc]init];
    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // Date formatter
    NSString *lastDownload = [dateformat stringFromDate:[NSDate date]];
    //NSString* lastDownload = @"2015-4-6 12:00:00";
    if (LastNoteDownload != nil)
        lastDownload = LastNoteDownload;
    lastDownload = [lastDownload stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    //Bug fix to make sure anyone with this appid gets a new one.
    if ([AppID isEqualToString: @"55339"])
        AppID = nil;
    NSString* appid = (AppID != nil) ? [NSString stringWithFormat:@"&app=%@", AppID] : @"";
    NSString* notif = (notificationOnly) ? @"&notifyonly=1" : @"";
    NSString* sponsor = @"";
#ifdef UNIVERSITY
    if (Skin != nil)
        sponsor = [NSString stringWithFormat:@"&sponsor=%ld", [Skin SkinID]];
#endif
#ifdef HUMANIX
    sponsor = @"&sponsor=82";
#endif
#ifdef OODLES
    sponsor = @"&sponsor=91";
#endif
#ifdef NRCC
    sponsor = @"&sponsor=115";
#endif
#ifdef YOUTHREACH
    sponsor = @"&sponsor=171";
#endif
    NSString* surl = [NSString stringWithFormat:@"%@?ts=%@%@%@&highlight=1%@",
                      urlNotes, lastDownload, appid, notif, sponsor];
    
    if (!notificationOnly)
        LastNoteDownload = [dateformat stringFromDate:[NSDate date]];
    NSURL* url = [NSURL URLWithString:surl];
    NSURLRequest* req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    inetdata = [[NSMutableData alloc] initWithCapacity:60000];

    conn = [[NSURLConnection alloc] initWithRequest:req
                                           delegate:self
                                   startImmediately:YES];

    timerLoad = [NSTimer scheduledTimerWithTimeInterval:7200
                                                 target:self
                                               selector:@selector(autoReloadMessages)
                                               userInfo:nil
                                                repeats:NO];
    
}

-(void)autoReloadMessages {
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi) {
        [self loadFromInternet];
    }
    else {
        timerLoad = [NSTimer scheduledTimerWithTimeInterval:7200
                                                     target:self
                                                   selector:@selector(autoReloadMessages)
                                                   userInfo:nil
                                                    repeats:NO];
    }
}

-(void)loadLocalImages {
    /*
    NSMutableArray* dates = [[NSMutableArray alloc] init];
    localImages = [[NSMutableArray alloc] init];
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop){
                @try {
                if (asset){
                    int i=0;
                    NSDate* pdate = [asset valueForProperty:ALAssetPropertyDate];
                    for (;i < [dates count]; i++) {
                        if ([pdate compare:[dates objectAtIndex:i]] == NSOrderedDescending)
                            break;
                    }
                    if (i < 15) {
                        if (i < [dates count]) {
                            [dates insertObject:pdate atIndex:i];
                            [localImages insertObject:[[Message alloc] initFromUserPhoto:asset] atIndex:i];
                        }
                        else if ([dates count] < 15) {
                            [dates addObject:pdate];
                            [localImages addObject:[[Message alloc] initFromUserPhoto:asset]];
                        }
                    }
                }
                if ([localImages count] > 15)
                    [localImages removeObjectsInRange:NSMakeRange(15, [localImages count] - 15)];
                }
                @catch (id ex) {
                    NSLog(@"Exception occurred");
                }
            }];
        }
        else {
            //NSLog(@"All photos loaded");
            for (Message*m in localImages) {
                [m loadUserImage];
            }
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"error enumerating AssetLibrary groups %@\n", error);
    }];
     */
}

-(void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [inetdata appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //NSLog([error localizedDescription]);
    
    for (NSObject* l in listeners) {
        if ([l respondsToSelector:@selector(dataRefresh)])
            [l performSelector:@selector(dataRefresh)];
    }

    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
    */
    conn = nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection*) connection {
    //Now that we have data from the server, re-initialize Categories to an empty dictionary
    @try {
        //NSString* result = [[NSString alloc] initWithData:inetdata encoding:NSUTF8StringEncoding];
        //NSLog(result);
        [self parseMessageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self->notificationOnly) {
                self->categories = self->tmpCategories;
                [self mergeMessages];
            }

            NSString* file = [NSTemporaryDirectory() stringByAppendingPathComponent:localNotes];
            [[NSFileManager defaultManager] createFileAtPath:file
                                                    contents:self->inetdata
                                                  attributes:nil];
            
            for (NSObject* l in self->listeners) {
                if ([l respondsToSelector:@selector(dataRefresh)])
                    [l performSelector:@selector(dataRefresh)];
            }
        });
    }
    @catch(id ex) {
        NSLog(@"Exception loading from Internet");
    }
    conn = nil;
}

-(void)parseMessageData {
    tmpCategories = [[NSMutableDictionary alloc] init];
    tmpRegMessages = [[NSMutableArray alloc] init];
    tmpVersionMessages = [[NSMutableArray alloc] init];
    parseFailed = false;
    //NSString* xml = [[NSString alloc] initWithData:inetdata encoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:inetdata];
    [parser setDelegate:self];
    [parser parse];
}

-(BOOL)initContacts {
    if ([contacts count] == 0)
        [self loadContacts];

    return YES;
}

-(void)loadContacts {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized) {
        CNContactStore* store = [[CNContactStore alloc] init];
        NSMutableArray* _contacts = [[NSMutableArray alloc] init];

        NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
        NSArray* containers = [store containersMatchingPredicate:nil error:nil];
        for (CNContainer* container in containers) {
            NSString *containerId = [container identifier];
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error;
            NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];
            if (error) {
                NSLog(@"error fetching contacts %@", error);
            } else {
                for (CNContact *contact in cnContacts) {
                    
                    NSMutableArray* phones = [[NSMutableArray alloc] init];
                    for (CNLabeledValue *label in contact.phoneNumbers) {
                        NSString *phone = [label.value stringValue];
                        if ([phone length] > 0) {
                            [phones addObject:[[UserPhone alloc] initWithNumber:phone Label:label.label]];
                        }
                    }

                    if ([[contact givenName] length] > 0 && [[contact familyName] length] > 0 && [phones count] > 0) {
                        UserContact* c = [[UserContact alloc] initWithFName:[contact givenName]
                                                                      LName:[contact familyName]
                                                                     Phones:phones
                                                                      Photo:[contact imageData]];
                        if (c != nil)
                            [_contacts addObject:c];
                    }
                }
            }
        }
        contacts = [_contacts sortedArrayUsingSelector:@selector(compareName:)];
    }
}

/*
-(void)loadContacts:(ABAddressBookRef)addressBook {
    NSMutableArray* _contacts = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    if (allPeople == nil) return;
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    if (numberOfPeople == 0) return;
    
    for(int i = 0; i < numberOfPeople; i++){
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        NSMutableArray* phones = [[NSMutableArray alloc] init];
        long cphones = ABMultiValueGetCount(phoneNumbers);
        if (cphones > 0) {
            for (long i=0; i<cphones; i++) {
                CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
                NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
                phoneLabel = [phoneLabel lowercaseString];
                NSString* phoneNumber = (__bridge NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                [phones addObject:[[UserPhone alloc] initWithNumber:phoneNumber Label:phoneLabel]];
            }
        }
        
        NSData* photo = nil;
        if (ABPersonHasImageData(person)){
            photo = (__bridge NSData*)(ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail));
        }
        
        if (([firstName length] > 0 || [lastName length] > 0) && [phones count] > 0) {
            UserContact* c = [[UserContact alloc] initWithFName:firstName
                                                          LName:lastName
                                                          Phones:phones
                                                          Photo:photo];
            if (c != nil)
                [_contacts addObject:c];
        }
    }
    
    contacts = [_contacts sortedArrayUsingSelector:@selector(compareName:)];
}
*/

-(void)sortContacts {
    contacts = [contacts sortedArrayUsingSelector:@selector(compareName:)];
}

-(NSArray*) sortCategories {
    NSComparisonResult (^categoryCmp)(id, id);
    categoryCmp = ^NSComparisonResult(id c1, id c2) {
        MessageCategory* cat1 = [self->categories objectForKey:c1];
        MessageCategory* cat2 = [self->categories objectForKey:c2];
        if ([cat1 required] != [cat2 required]) {
            return ([cat1 required]) ? NSOrderedAscending : NSOrderedDescending;
        }
        if ([cat1 newCategory] != [cat2 newCategory]) {
            return ([cat1 newCategory]) ? NSOrderedAscending : NSOrderedDescending;
        }
        if ([CategoryList objectForKey:[cat1 name]] != [CategoryList objectForKey:[cat2 name]]) {
            int v1 = [[CategoryList objectForKey:[cat1 name]] intValue];
            int v2 = [[CategoryList objectForKey:[cat2 name]] intValue];
            if (v1 == 0)
                return NSOrderedDescending;
            else if (v2 == 0)
                return NSOrderedAscending;
            else if (v1 > v2)
                return NSOrderedDescending;
            else if (v1 < v2)
                return NSOrderedAscending;
        }
        
        return ([cat1 order] > [cat2 order]) ? NSOrderedDescending :
        (([cat1 order] < [cat2 order]) ? NSOrderedAscending : NSOrderedSame);
    };

    NSArray* sortedCats = [[[categories keyEnumerator] allObjects] sortedArrayUsingComparator: categoryCmp];
    return sortedCats;
}

-(NSArray*)getCategories {
    NSArray* sorted = [self sortCategories];
    NSMutableArray* cs = [[NSMutableArray alloc] init];
    for (NSString* m in sorted)
        [cs addObject:m];

#ifdef UNIVERSITY
    /*
    if (localImages != nil && [localImages count] > 0)
        [cs addObject:NSLocalizedString(@"Your Photos Title", nil)];
    [cs addObject:NSLocalizedString(@"Your Messages Title", nil)];
    if (SaveRecentMessages && [RecentMessages count] > 0)
        [cs addObject:NSLocalizedString(@"Recent Messages Title", nil)];
     */
#endif
    
    return cs;
}

-(NSArray*)getRequiredCategories {
    NSArray* sorted = [self sortCategories];
    NSMutableArray* cs = [[NSMutableArray alloc] init];
    for (NSString*c in sorted) {
        if ([[categories objectForKey:c] required])
            [cs addObject:c];
    }

#ifdef UNIVERSITY
    int i=0;
    if (localImages != nil && [localImages count] > 0)
        [cs insertObject:NSLocalizedString(@"Your Photos Title", nil) atIndex:i++];
    [cs insertObject:NSLocalizedString(@"Your Messages Title", nil) atIndex:i++];
    if (SaveRecentMessages && [RecentMessages count] > 0)
        [cs insertObject:NSLocalizedString(@"Recent Messages Title", nil) atIndex:i];
#endif
    
    return cs;
}

-(NSArray*)getSponsorCategories {
    NSArray* sorted = [self sortCategories];
    NSMutableArray* cs = [[NSMutableArray alloc] init];
    for (NSString*c in sorted) {
        if ([[categories objectForKey:c] sponsor] != nil)
            [cs addObject:c];
    }
    
    return cs;
}

-(MessageCategory*)getCategory:(NSString *)c {
    return [categories objectForKey:c];
}

-(SponsorInfo*)getSponsorForCategory:(NSString *)category {
    return [[categories objectForKey:category] sponsor];
}

-(NSArray*)getContactHeadings {
    NSMutableArray* _headings = [[NSMutableArray alloc] init];
    NSArray* cs = contacts;
    for (UserContact* uc in cs) {
        NSString* n = [uc getSortValue];
        unichar ch = toupper([n characterAtIndex:0]);
        NSString* c = [NSString stringWithCharacters:&ch length:1];
        if ([_headings count] == 0 || ![[_headings objectAtIndex:[_headings count]-1] isEqualToString:c])
            [_headings addObject:c];
    }
        
    return _headings;
}

-(NSArray*)getContacts {
    while (loadingContacts)
        [NSThread sleepForTimeInterval:0.20];
    return contacts;
}

-(NSArray*)getContactsForHeading:(NSString *)h {
    while (loadingContacts)
        [NSThread sleepForTimeInterval:0.20];
    NSMutableArray* _cs = [[NSMutableArray alloc] init];
    NSArray* cs = contacts;
    for (UserContact* uc in cs) {
        NSString* n = [uc getSortValue];
        if (toupper([n characterAtIndex:0]) == toupper([h characterAtIndex:0]))
            [_cs addObject:uc];
    }
    
    return _cs;
}

-(int)getIndexForContact:(UserContact*)uc {
    int index = -1;
    for (int i=0; i<[contacts count] && index == -1; i++) {
        UserContact*u = [contacts objectAtIndex:i];
        if ([uc isEqual:u])
            index = i;
    }
    return index;
}

-(UserContact*) chooseRandomContact {
    while (loadingContacts)
        [NSThread sleepForTimeInterval:0.20];
    if ([contacts count] == 0) return nil;
    
    BOOL chooseRecent = ([RecentContacts count] > 0 && arc4random() % 3 != 0);
    NSArray* cs = (chooseRecent) ? RecentContacts : contacts;
    NSInteger r = arc4random() % [cs count];
    return chooseRecent ? [self findUserByPhone:[cs objectAtIndex:r]] : [cs objectAtIndex:r];
}

-(NSArray*)getAllMessages {
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:allMessages];
    NSArray *ret = [orderedSet array];
    return ret;
}

-(NSArray*)getEventMessages {
    NSMutableArray* eventMessages = [[NSMutableArray alloc] init];
    for (int i=0; i<[allMessages count]; i++) {
        if ([[allMessages objectAtIndex:i] eventToggle])
            [eventMessages addObject:[allMessages objectAtIndex:i]];
    }
    return eventMessages;
}

-(NSArray*)getPinnedMessages {
    return [SqlDb getPinnedMessages];
}

-(void) mergeMessages {
    int v = 0, r = 0;
    NSArray* bs = [self getMessagesForCategory:@"Badges"];
    if (bs == nil)
        allMessages = [[NSMutableArray alloc] init];
    else
        allMessages = [NSMutableArray arrayWithArray:bs];
    while (v < [tmpVersionMessages count]) {
        if (v < [tmpVersionMessages count]){
            [allMessages addObject:[tmpVersionMessages objectAtIndex:v]];
            v++;
        }
        int s = arc4random() % 3; //Only show regular messages 1 out of 4 times
        if (r < [tmpRegMessages count] && s == 0) {
            [allMessages addObject:[tmpRegMessages objectAtIndex:r]];
            r++;
        }
    }

    [allMessages filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary* bindings) {
        return [self getMessageScore:(Message*)obj] < HIDEMESSAGE || Skin == nil;
    }]];
}

-(NSArray*)resortMessages {
    [tmpVersionMessages sortUsingComparator:^NSComparisonResult(id m1, id m2) {
        int score1 = [self getMessageScore:(Message*)m1];
        int score2 = [self getMessageScore:(Message*)m2];
        
        return (score1 < score2) ? NSOrderedAscending : (score1 > score2) ? NSOrderedDescending : NSOrderedSame;
    }];
    [tmpRegMessages sortUsingComparator:^NSComparisonResult(id m1, id m2) {
        int score1 = [self getMessageScore:(Message*)m1];
        int score2 = [self getMessageScore:(Message*)m2];
        
        return (score1 < score2) ? NSOrderedAscending : (score1 > score2) ? NSOrderedDescending : NSOrderedSame;
    }];
    
    [self mergeMessages];
    
    return allMessages;
}

-(void)setMessagePin:(Message*)msg withValue:(BOOL)pin {
    Message*m = [self findMessageWithID:[msg msgId]];
    
    if (m != nil)
        [m setPinned:pin];
}

-(Message*)findMessageWithID:(int)msgid {
    if (conn != nil)
        return nil;
    
    Message* ret;
    for (Message* m in allMessages) {
        if ([m msgId] == msgid) {
            ret = m;
            break;
        }
    }
    
    return ret;
}

-(int)getMessageScore:(Message*)m {
    int s = arc4random() % 3;
    
    if ([[m category] isEqualToString:@"Badges"])
        s = 0;
    else {
        //if ([[categories objectForKey:[m category]] sponsor] == NULL)
        //s += 5;
        if (CategoryList != nil && [[CategoryList objectForKey:[m category]] isEqualToString: @"0"])
            s += HIDEMESSAGE;
        
        if (![m newMsg])
            s += 4;
        if (![m liked])
            s += 1;
        if (![m pinned])
            s += 1;
        
        s += ([m order] / 3);
    }
    
    return s;
}

-(NSArray*)getMessagesForCategory:(NSString*)category {
    if ([category isEqualToString:NSLocalizedString(@"Your Photos Title", nil)])
        return localImages;
    else if ([category isEqualToString:NSLocalizedString(@"Your Messages Title", nil)])
        return YourMessages;
    else if ([category isEqualToString:NSLocalizedString(@"Recent Messages Title", nil)])
        return RecentMessages;
    else {
        if ([categories objectForKey:category] == nil)
            return nil;
        
        NSMutableArray* ms = [[NSMutableArray alloc] init];
        for (Message*m in [[categories objectForKey:category] messages]) {
            if (![SqlDb isFlagged:m])
                [ms addObject:m];
        }
        return ms;
    }
}

-(int)getNewMessageCount {
    int c = 0;
    for (MessageCategory* category in [categories keyEnumerator]) {
        for (Message* msg in [[categories objectForKey:category] messages]) {
            if ([msg newMsg])
                c++;
        }
    }
    return c;
}

-(int)getNewMessageCountForCategory:(NSString*)category {
    int c = 0;
    for (Message* msg in [[categories objectForKey:category] messages]) {
        if ([msg newMsg])
            c++;
    }
    return c;
}

const int RECENTWATCHCOUNT=5;
int irecent = 0;
Message* recentMsgs[RECENTWATCHCOUNT];
-(Message*)chooseRandomMessage {
    BOOL chooseRecent = ([RecentCategories count] > 0 && arc4random() % 3) != 0;
    BOOL chooseSponsor = Skin != nil && arc4random() % 3 != 0;
    NSInteger m = -1;
    MessageCategory* cat;
    
    int iloop = 0;
    Message* rndmsg = nil;
    while (rndmsg == nil) {
        NSMutableDictionary* cs = (chooseRecent) ? RecentCategories : categories;
        if (chooseSponsor && [self getSponsorCategories] != nil) {
            NSArray* sponsoredCats = [self getSponsorCategories];
            cat = [sponsoredCats objectAtIndex:(arc4random() % [sponsoredCats count])];
        }
        else {
            NSInteger c = arc4random() % [cs count];
            for (MessageCategory* ms in cs) {
                if (c == 0)
                    cat = ms;
                c--;
            }
        }
        if ([categories objectForKey:cat] == nil || [[[categories objectForKey:cat] messages] count] == 0) {
            [RecentCategories removeObjectForKey:cat];
            chooseRecent = ([RecentCategories count] > 0 && arc4random() % 3) != 0;
            [Settings SaveSetting:SettingRecentCategories withValue:RecentCategories];
        }
        else {
            m = arc4random() % [[[categories objectForKey:cat] messages] count];
        }
        rndmsg = [[[categories objectForKey:cat] messages] objectAtIndex:m];
        for (int i=0; iloop < 10 && i<RECENTWATCHCOUNT; i++) {
            if (recentMsgs[i] != nil && [recentMsgs[i] msgId] == [rndmsg msgId])
                rndmsg = nil;
        }
        iloop++;
    }
    recentMsgs[irecent%RECENTWATCHCOUNT] = rndmsg;
    irecent++;
    return rndmsg;
}

-(UserContact*)findUserByPhone:(NSString*)targetPhone {
    while (loadingContacts)
        [NSThread sleepForTimeInterval:0.20];

    for (UserContact* uc in contacts) {
        if ([uc hasPhone:targetPhone])
             return uc;
    }
    
    return nil;
}

-(void)selectUser:(UserContact*)contact toValue:(BOOL)on {
    bool found = false;
    for (int i=0; i<[selectContacts count]; i++) {
        UserContact* uc = (UserContact*)[selectContacts objectAtIndex:i];
        found |= ([[contact phones] count] > 0 && [uc hasPhone:[[contact phones] objectAtIndex:0]]);
        if (found && !on) {
            [selectContacts removeObjectAtIndex:i];
            i--;
        }
    }
    if (!found && on)
        [selectContacts addObject:contact];
}

-(NSArray*)getSelectedUsers {
    return selectContacts;
}

-(BOOL)isUserSelected:(UserContact*)contact {
    bool found = false;
    for (int i=0; !found && i<[selectContacts count]; i++) {
        UserContact* uc = (UserContact*)[selectContacts objectAtIndex:i];
        found |= [[contact phones] count] > 0 && [uc hasPhone:[[contact phones] objectAtIndex:0]];
    }
    
    return found;
}

-(void)clearSelectedUsers {
    [selectContacts removeAllObjects];
}

-(int)getInt:(NSDictionary*) dict forAttribute:(NSString*)attr {
    int ret = 0;
    NSString* s = [dict objectForKey:attr];
    if (s != nil)
        ret = [s intValue];
    
    return ret;
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    //abort the data load
    tmpCategories = categories;
    parseFailed = true;
    NSLog(@"parsing failed");
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    currentElement = elementName;
    if ([elementName isEqualToString:@"notes"]) {
        [SqlDb archiveAllCategories];
        LastNoteDownload = [attributeDict objectForKey:@"ts"];
        if (AppID == nil || ![AppID isEqualToString:[attributeDict objectForKey:@"app"]]) {
            AppID = [attributeDict objectForKey:@"app"];
            [Settings SaveSetting:SettingAppID withValue:AppID];
            //We changed the appid, so we need to re-register for push notifications
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate registerRemoteNotificationWithAzure];
        }
        [CurrentUser setExplorerPoints:[self getInt:attributeDict forAttribute:@"ep"]];
        [CurrentUser setSharerPoints:[self getInt:attributeDict forAttribute:@"sp"]];
        [CurrentUser setMusePoints:[self getInt:attributeDict forAttribute:@"mp"]];
        
        [Settings SaveSetting:SettingLastNoteDownload withValue:LastNoteDownload];
    }
    else if ([elementName isEqualToString:@"ns"]) {
        NotificationMsgs = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:@"skin"]) {
        Skin = [[SkinInfo alloc] init];
        
        [Skin setSkinID:[[attributeDict objectForKey:@"id"] integerValue]];
        [Skin setSkinName:[attributeDict objectForKey:@"name"]];
        [Skin setMasterName:[attributeDict objectForKey:@"master"]];
        [Skin setMasterBadgeURL:[attributeDict objectForKey:@"masterurl"]];
        /*
        [Skin setColor1:[attributeDict objectForKey:@"c1"]];
        [Skin setColor2:[attributeDict objectForKey:@"c2"]];
        [Skin setColor3:[attributeDict objectForKey:@"c3"]];
         */
        [Skin setColor1:[SkinInfo Color1TextMuse]];
        [Skin setColor2:[SkinInfo Color2TextMuse]];
        [Skin setColor3:[SkinInfo Color3TextMuse]];
        [Skin setHomeURL:[attributeDict objectForKey:@"home"]];
        [Skin setLaunchImageURL:[[NSMutableArray alloc] init]];
        [Skin setMainWindowTitle:[attributeDict objectForKey:@"title"]];
        [Skin setIconButtonURL:[attributeDict objectForKey:@"icon"]];

        [Settings SaveSkinData];
    }
    else if ([elementName isEqualToString:@"launch"]) {
        if ([[attributeDict objectForKey:@"width"] isEqualToString:@"320"]) {
            [[Skin LaunchImageURL] addObject:[attributeDict objectForKey:@"url"]];
            ImageDownloader* img =
                [[ImageDownloader alloc] initWithUrl:[attributeDict objectForKey:@"url"]];
            [img load];
        }
    }
    else if ([elementName isEqualToString:@"c"]) {
        categoryOrder = 0;
        NSString* name = [attributeDict objectForKey:@"name"];
        [SqlDb categoryExists:name];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        isBadge = [name isEqualToString:@"Badges"];

        currentCategory = [[MessageCategory alloc] initWithName:name];
        [currentCategory setOrder:[tmpCategories count]];
        [currentCategory setCatid:([[attributeDict allKeys] containsObject:@"id"] ?
                                   [[attributeDict objectForKey:@"id"] intValue] : 0)];
        [currentCategory setRequired:([[attributeDict allKeys] containsObject:@"required"] &&
                                      ![[attributeDict objectForKey:@"required"] isEqualToString:@"0"])];
        [currentCategory setNewCategory:([[attributeDict allKeys] containsObject:@"new"] &&
                                         ![[attributeDict objectForKey:@"new"] isEqualToString:@"0"])];
        [currentCategory setChosen:(CategoryList == nil ||
                                    [CategoryList objectForKey:[currentCategory name]] == nil ||
                                    ![[CategoryList objectForKey:[currentCategory name]] isEqualToString:@"0"])];
        [currentCategory setMessages:[[NSMutableArray alloc] init]];
        if ([currentCategory required]) {
            if (InitialCategory == nil || [InitialCategory length] == 0) {
                InitialCategory = [currentCategory name];
                [Settings SaveSetting:InitialCategory withValue:[currentCategory name]];
            }
            if (CategoryList != nil && [[CategoryList objectForKey:[currentCategory name]] isEqualToString:@"0"])
                [CategoryList setObject:@"1" forKey:[currentCategory name]];
        }
        [currentCategory setEventToggle:([attributeDict objectForKey:@"event"] != nil &&
                                         [[attributeDict objectForKey:@"event"] isEqualToString: @"1"])];
        if ([CategoryList objectForKey:name] == nil)
            [CategoryList setObject:([currentCategory eventToggle] ? @"1" : @"0") forKey:name];
        versionMsg = NO;
        if ([attributeDict objectForKey:@"version"] != nil)
            versionMsg = [[attributeDict objectForKey:@"version"] isEqualToString:@"1"];
        BOOL useIcon = false;
        if ([[attributeDict allKeys] containsObject:@"useicon"])
            useIcon = [[attributeDict objectForKey:@"useicon"] isEqualToString:@"1"];
        [currentCategory setUseIcon:useIcon];
        if ([[attributeDict allKeys] containsObject:@"url"] &&
                [[attributeDict allKeys] containsObject:@"icon"]) {
            NSString* url = [attributeDict objectForKey:@"url"];
            NSString* icon = [attributeDict objectForKey:@"icon"];
            if ([url length] > 0 && [icon length] > 0) {
                SponsorInfo* sponsor = [[SponsorInfo alloc] init];
                [sponsor setUrl:url];
                [sponsor setIcon:icon];
                [currentCategory setSponsor:sponsor];
            }
        }
        //if (CategoryList != nil && [currentCategory newCategory]) {
        if (CategoryList != nil && [currentCategory sponsor] != nil) {
            [CategoryList setObject:@"1" forKey:[currentCategory name]];
            [SqlDb addChosenCategory:[currentCategory name]];
        }

        [tmpCategories setValue:currentCategory forKey:name];
    }
    else if ([elementName isEqualToString:@"n"]) {
        if ([attributeDict objectForKey:@"id"] == nil)
            currentMsgId++;
        else
            currentMsgId = [[attributeDict objectForKey:@"id"] intValue];
        newMsg = NO;
        if ([attributeDict objectForKey:@"new"] != nil)
            newMsg = [[attributeDict objectForKey:@"new"] isEqualToString:@"1"];
        if ([attributeDict objectForKey:@"liked"] != nil)
            likedMsg = [[attributeDict objectForKey:@"liked"] isEqualToString:@"1"];
        likeCount = 0;
        if ([attributeDict objectForKey:@"likecount"] != nil)
            likeCount = [[attributeDict objectForKey:@"likecount"] intValue];
        discoverPoints = 0;
        if ([attributeDict objectForKey:@"dp"] != nil)
            discoverPoints = [[attributeDict objectForKey:@"dp"] intValue];
        sharePoints = 0;
        if ([attributeDict objectForKey:@"sp"] != nil)
            sharePoints = [[attributeDict objectForKey:@"sp"] intValue];
        goPoints = 0;
        if ([attributeDict objectForKey:@"gp"] != nil)
            goPoints = [[attributeDict objectForKey:@"gp"] intValue];
        currentEventLoc = [attributeDict objectForKey:@"loc"];
        currentEventDate = [attributeDict objectForKey:@"edate"];
        following = [attributeDict objectForKey:@"follow"] != nil ?
                        [[attributeDict objectForKey:@"follow"] intValue] != 0 : NO;
        sponsorID = [attributeDict objectForKey:@"notesponsor"] != nil &&
                        [[attributeDict objectForKey:@"notesponsor"] intValue] != 0 ?
            [attributeDict objectForKey:@"notesponsor"] : @"";
        xmldata = [[NSMutableString alloc] init];
        currentText = nil;
        currentMediaUrl = nil;
        currentUrl = nil;
        currentSponsorName = nil;
        currentSponsorLogo = nil;
        currentSendCount = nil;
        currentVisitCount = nil;
        currentBadgeURL = nil;
        currentWinnerText = nil;
        currentVisitWinnerText = nil;
        currentTextNo = nil;
        currentPhoneNo = nil;
    }
    else if ([elementName isEqualToString:@"t"])
        xmldata = [[NSMutableString alloc] init];
    else if ([elementName isEqualToString:@"p"])
        xmldata = [[NSMutableString alloc] init];
    else if ([elementName isEqualToString:@"i"])
        xmldata = [[NSMutableString alloc] init];
    else if ([elementName isEqualToString:@"text"] ||
             [elementName isEqualToString:@"media"] ||
             [elementName isEqualToString:@"url"] ||
             [elementName isEqualToString:@"sp_name"] ||
             [elementName isEqualToString:@"sp_logo"] ||
             [elementName isEqualToString:@"send"] ||
             [elementName isEqualToString:@"visit"] ||
             [elementName isEqualToString:@"winner"] ||
             [elementName isEqualToString:@"visitwinner"] ||
             [elementName isEqualToString:@"badge"] ||
             [elementName isEqualToString:@"phoneno"] ||
             [elementName isEqualToString:@"textno"])
        partsdata = [[NSMutableString alloc] init];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([currentElement isEqualToString:@"n"] ||
        [currentElement isEqualToString:@"t"] ||
        [currentElement isEqualToString:@"p"] ||
        [currentElement isEqualToString:@"i"])
        [xmldata appendString:string];
    else if ([currentElement isEqualToString:@"text"] ||
             [currentElement isEqualToString:@"media"] ||
             [currentElement isEqualToString:@"url"])
         [partsdata appendString:string];
    else if ([currentElement isEqualToString:@"sp_name"] ||
             [currentElement isEqualToString:@"sp_logo"] ||
             [currentElement isEqualToString:@"send"]  ||
             [currentElement isEqualToString:@"visit"] ||
             [currentElement isEqualToString:@"winner"] ||
             [currentElement isEqualToString:@"badge"] ||
             [currentElement isEqualToString:@"visitwinner"] ||
             [currentElement isEqualToString:@"phoneno"] ||
             [currentElement isEqualToString:@"textno"])
        [partsdata appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"n"]) {
        if (![SqlDb isFlaggedId:currentMsgId]) {
            NSString* m = (currentText==nil && currentMediaUrl==nil && currentUrl==nil) ? xmldata : currentText;
            Message* msg = [[Message alloc] initWithId:currentMsgId
                                                  text:m
                                              mediaUrl:currentMediaUrl
                                                   url:currentUrl
                                           forCategory:[currentCategory name]
                                                 isNew:newMsg];
            [msg setLiked:likedMsg];
            [msg setLikeCount:likeCount];
            [msg setDiscoverPoints:discoverPoints];
            [msg setSharePoints:sharePoints];
            [msg setGoPoints:goPoints];
            [msg setBadge:isBadge];
            [msg setVersion:versionMsg];
            [msg setOrder:categoryOrder];
            [msg setPinned:[self isPinned:msg]];
            [msg setEventDate:currentEventDate];
            [msg setEventLocation:currentEventLoc];
            [msg setEventToggle:[currentCategory eventToggle]];
            [msg setSponsorID:sponsorID];
            [msg setSponsorName:currentSponsorName];
            [msg setSponsorLogo:currentSponsorLogo];
            if (currentSendCount != nil)
                [msg setSendcount:[currentSendCount intValue]];
            if (currentVisitCount != nil)
                [msg setVisitcount:[currentVisitCount intValue]];
            [msg setBadgeURL:currentBadgeURL];
            [msg setWinnerText:currentWinnerText];
            [msg setVisitWinnerText:currentVisitWinnerText];
            [msg setPhoneno:currentPhoneNo];
            [msg setTextno:currentTextNo];
            [msg setFollowing:following];
            if (following)
                [SponsorFollows addObject:[NSString stringWithFormat:@"spon%@", sponsorID]];
            categoryOrder++;
            [[currentCategory messages] addObject:msg];
            if (versionMsg)
                [tmpVersionMessages addObject:msg];
            else
                [tmpRegMessages addObject:msg];
        }
    }
    else if ([elementName isEqualToString:@"t"]) {
        NSString* m = xmldata;
#ifdef OODLES
        m = [xmldata stringByReplacingOccurrencesOfString:@"TextMuse" withString:@"Oodles"];
#endif
#ifdef NRCC
        m = [xmldata stringByReplacingOccurrencesOfString:@"TextMuse" withString:@"NRCC"];
#endif
        [NotificationMsgs addObject:m];
    }
    else if ([elementName isEqualToString:@"p"]) {
        Preamble = xmldata;
        [Settings SaveSetting:SettingPreamble withValue:Preamble];
    }
    else if ([elementName isEqualToString:@"i"]) {
        Inquiry = xmldata;
        [Settings SaveSetting:SettingInquiry withValue:Inquiry];
    }
    else if ([elementName isEqualToString:@"notes"]) {
        if (!notificationOnly) {
            [Settings UpdateCategoryList];
        }

        [tmpVersionMessages sortUsingComparator:^NSComparisonResult(id m1, id m2) {
            int score1 = [self getMessageScore:(Message*)m1];
            int score2 = [self getMessageScore:(Message*)m2];
            
            return (score1 < score2) ? NSOrderedAscending : (score1 > score2) ? NSOrderedDescending : NSOrderedSame;
        }];
        [tmpRegMessages sortUsingComparator:^NSComparisonResult(id m1, id m2) {
            int score1 = [self getMessageScore:(Message*)m1];
            int score2 = [self getMessageScore:(Message*)m2];
            
            return (score1 < score2) ? NSOrderedAscending : (score1 > score2) ? NSOrderedDescending : NSOrderedSame;
        }];
        
    }
    else if ([elementName isEqualToString:@"text"] && [partsdata length] > 0)
        currentText = partsdata;
    else if ([elementName isEqualToString:@"media"] && [partsdata length] > 0)
        currentMediaUrl = partsdata;
    else if ([elementName isEqualToString:@"url"] && [partsdata length] > 0)
        currentUrl = partsdata;
    else if ([elementName isEqualToString:@"sp_name"] && [partsdata length] > 0)
        currentSponsorName = partsdata;
    else if ([elementName isEqualToString:@"sp_logo"] && [partsdata length] > 0) {
        currentSponsorLogo = partsdata;
        ImageDownloader* loader = [[ImageDownloader alloc] initWithUrl:currentSponsorLogo];
        [loader load];
    }
    else if ([elementName isEqualToString:@"send"] && [partsdata length] > 0)
        currentSendCount = partsdata;
    else if ([elementName isEqualToString:@"visit"] && [partsdata length] > 0)
        currentVisitCount = partsdata;
    else if ([elementName isEqualToString:@"winner"] && [partsdata length] > 0)
        currentWinnerText = partsdata;
    else if ([elementName isEqualToString:@"visitwinner"] && [partsdata length] > 0)
        currentVisitWinnerText = partsdata;
    else if ([elementName isEqualToString:@"badge"] && [partsdata length] > 0)
        currentBadgeURL = partsdata;
    else if ([elementName isEqualToString:@"phoneno"] && [partsdata length] > 0)
        currentPhoneNo = partsdata;
    else if ([elementName isEqualToString:@"textno"] && [partsdata length] > 0)
        currentTextNo = partsdata;
}

-(BOOL)isPinned:(Message*)msg {
    BOOL ret = false;
    for (int i=0; i<[pinnedMsgs count] && !ret; i++)
        ret = [msg msgId] == [[pinnedMsgs objectAtIndex:i] msgId];
    
    return ret;
}

@end
