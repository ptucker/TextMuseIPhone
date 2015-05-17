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
#import <AddressBook/AddressBook.h>

NSString* urlNotes = @"http://www.textmuse.com/admin/notes.php";
NSString* localNotes = @"notes.xml";

@implementation DataAccess
@synthesize contactFilter;

-(id)init {
    timerLoad = nil;
    categoryCmp = ^NSComparisonResult(id c1, id c2) {
        MessageCategory* cat1 = [categories objectForKey:c1];
        MessageCategory* cat2 = [categories objectForKey:c2];
        if ([cat1 required] != [cat2 required]) {
            return ([cat1 required]) ? NSOrderedAscending : NSOrderedDescending;
        }
        
        return ([cat1 order] > [cat2 order]) ? NSOrderedDescending :
            (([cat1 order] < [cat2 order]) ? NSOrderedAscending : NSOrderedSame);
    };
    
    
    [self reloadData];
    
    return self;
}

-(void)reloadData {
    selectContacts = [[NSMutableArray alloc] init];
    
    notificationOnly = false;
    [self initCategories];
    
    [self initContacts];
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
    
    if (categories == nil || [categories count] == 0)
        [self loadFromFile];
    
    [self loadFromInternet];
    
    if (!notificationOnly)
        [self loadLocalImages];
}

-(void) loadFromFile {
    NSString* file = [NSTemporaryDirectory() stringByAppendingPathComponent:localNotes];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file])
        [self createFile];

    //Initialize Categories to an empty dictionary
    categoryOrder = [[NSMutableArray alloc] init];
    inetdata = [NSMutableData dataWithContentsOfFile:file];
    [self parseMessageData];
}

-(void)createFile {
    NSString* initialXML = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><notes><c name=\"Top 5                                             \" required=\"1\"><n>Hey, I was just thinking about you. Let's get together soon</n><n>Here is your Snapple Fact of the Day: The plastic things on the end of shoelaces are called aglets</n><n>The Mariners play Sunday at 1. We should go and watch Rodney cough one up!</n><n>Check out this cute dog! http://cuteemergency.com/wp-content/uploads/2013/10/3ffeab4938f390f47f61f384f5a5fbf5.jpg</n><n>\"A man can be destroyed but not defeated.\" - Ernest Hemmingway</n></c><c name=\"Inspiring Quotes                                  \" required=\"1\"><n>As we are liberated from our own fear, our presence automatically liberates others. - Nelson Mandela</n><n>Better to do something imperfectly than to do nothing flawlessly. - Robert Schuller</n><n>Courage is not the absence of fear, but rather the judgment that something else is more important than fear.</n><n>A coward gets scared and quits. A hero gets scared, but still goes on.</n><n>The hero is no braver than the ordinary man, but he is brave five minutes longer. - Ralph Waldo Emerson</n><n>The true measure of a man is how he treats someone who can do him absolutely no good. - Ann Landers</n><n>A person who is nice to you, but rude to the waiter, is not a nice person. - Dave Barry</n><n>No act of kindness, no matter how small is ever wasted. - Aesop</n><n>Do not wait for leaders. Do it alone, person to person. - Mother Teresa</n></c><c name=\"Fact of the Day                                   \" required=\"1\"><n>A Goldfish's attention span is three seconds</n><n>A honey bee can fly at 15 MPH</n><n>The state of Maine has 62 lighthouses</n><n>A duck's quack doesn't echo</n><n>You blink over 10,000,000 times a year</n><n>There is a town called \"Big Ugly\" in West Virginia</n><n>David Rice Atchison was President of the United States for only one day</n><n>The Statue of Liberty wears a size 879 sandal</n><n>Beavers can hold their breath for 45 minutes under water</n><n>The brain operates on the same amount of power as a 10-watt light bulb</n></c><c name=\"Cute Photos                                       \"><n>Look how fluffy he is! pic.twitter.com/tc1nx86NjH</n><n>Enjoying the sunshine. pic.twitter.com/w9FtANFAiq</n><n>Baby orangutang bath time. pic.twitter.com/gsbCYupfYr</n><n>baby lambs are the cutest! pic.twitter.com/ERt5icExxD</n><n>baby tiger bath time. pic.twitter.com/0eJKJwwZVw</n><n>polar bear baby saying hello! pic.twitter.com/ianPOXYBLP</n></c><c name=\"Friendship                                        \"><n>What are you doing tonight? Let's do something.</n><n>Just wanted to let you know that I'm glad to have you in my life.</n><n>When we kiss, I get weak in the knees. Fortunately, I'm usually able to fall on top of you.</n><n>My day is filled with thoughts of you.</n><n>Remember stressed spelled backwards is desserts</n><n>Sometimes the whole day just seems to be flipping you off. That's a good day to have friends. I'm here. (And I'm ready with my \"flip-off\" finger.)</n></c><c name=\"Upcoming Events                                   \"><n>Let's go see \"Transcendence\" this weekend! Johnny Depp is hella weird.</n><n>You want to see \"Draft Day\"? Kevin Costner is in it. It is like Bull Durham for football ... except, you know, it is football.</n><n>Want to go Friday? \"Let's talk tomatoes\", a class taught by Master Gardeners Wally Prestbo and Marcia Dillon, will go over the basics of tomato care</n><n>Here's something for the kids - Break out your night vision goggles, or at least your flashlights, for Friday Night Flashlight Eggstravaganza, 7-10pm April 18</n><n>How about a hike this Saturday? North Tiger Mountain Hike, moderate, 6-8 miles, 1,500-foot elevation gain, 9:30 a.m.</n></c></notes>";
    
    NSString* file = [NSTemporaryDirectory() stringByAppendingPathComponent:localNotes];
    [[NSFileManager defaultManager] createFileAtPath:file
                                            contents:[initialXML dataUsingEncoding:NSStringEncodingConversionAllowLossy]
                                          attributes:nil];
}

-(void)loadFromInternet {
    if (timerLoad != nil)
        [timerLoad invalidate];
    timerLoad = nil;
    
    NSDateFormatter *dateformat=[[NSDateFormatter alloc]init];
    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // Date formatter
    NSString *lastDownload = [dateformat stringFromDate:[NSDate date]];
    //NSString* lastDownload = @"2015-4-6 12:00:00";
    if (LastNoteDownload != nil)
        lastDownload = LastNoteDownload;
    lastDownload = [lastDownload stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString* appid = (AppID != nil) ? [NSString stringWithFormat:@"&app=%@", AppID] : @"";
    NSString* notif = (notificationOnly) ? @"&notifyonly=1" : @"";
    NSString* surl = [NSString stringWithFormat:@"%@?ts=%@%@%@&highlight=1", urlNotes, lastDownload, appid, notif];
    if (!notificationOnly)
        LastNoteDownload = [dateformat stringFromDate:[NSDate date]];
    NSURL* url = [NSURL URLWithString:surl];
    NSURLRequest* req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    inetdata = [[NSMutableData alloc] init];
    categoryOrder = [[NSMutableArray alloc] init];
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
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
    NSMutableArray* dates = [[NSMutableArray alloc] init];
    localImages = [[NSMutableArray alloc] init];
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop){
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
            }];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"error enumerating AssetLibrary groups %@\n", error);
    }];
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
}

-(void)connectionDidFinishLoading:(NSURLConnection*) conn {
    NSString* file = [NSTemporaryDirectory() stringByAppendingPathComponent:localNotes];
    [[NSFileManager defaultManager] createFileAtPath:file
                                            contents:inetdata
                                          attributes:nil];
    
    //Now that we have data from the server, re-initialize Categories to an empty dictionary
    [self parseMessageData];
    
    for (NSObject* l in listeners) {
        if ([l respondsToSelector:@selector(dataRefresh)])
            [l performSelector:@selector(dataRefresh)];
    }
}

-(void)parseMessageData {
    tmpCategories = [[NSMutableDictionary alloc] init];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:inetdata];
    [parser setDelegate:self];
    [parser parse];

    if (!notificationOnly)
        categories = tmpCategories;
}

-(void)initContacts {
    loadingContacts = YES;
    CFErrorRef* error = NULL;
    DataAccess* __weak weakSelf = self;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);

    //if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf loadContacts:addressBook];
            });
        });
    //}
    //else { // we're on iOS 5 or older
    //    [self loadContacts:addressBook];
    //}
    loadingContacts = NO;
}

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

-(void)sortContacts {
    contacts = [contacts sortedArrayUsingSelector:@selector(compareName:)];
}

-(NSArray*)getCategories {
    NSArray* sorted = [[[categories keyEnumerator] allObjects] sortedArrayUsingComparator:categoryCmp];
    NSMutableArray* cs = [[NSMutableArray alloc] init];
    for (NSString* m in sorted)
        [cs addObject:m];
    //int i=0;
    //if (localImages != nil && [localImages count] > 0)
    //    [cs insertObject:NSLocalizedString(@"Your Photos Title", nil) atIndex:i++];
    //[cs insertObject:NSLocalizedString(@"Your Messages Title", nil) atIndex:i];
    if (localImages != nil && [localImages count] > 0)
        [cs addObject:NSLocalizedString(@"Your Photos Title", nil)];
    [cs addObject:NSLocalizedString(@"Your Messages Title", nil)];
    if (SaveRecentMessages && [RecentMessages count] > 0)
        [cs addObject:NSLocalizedString(@"Recent Messages Title", nil)];
    return cs;
}

-(NSArray*)getChosenCategories {
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    NSArray* sorted = [[[categories keyEnumerator] allObjects] sortedArrayUsingComparator:categoryCmp];
    for (NSString* c in sorted) {
        if (![[categories objectForKey:c] required] && [[categories objectForKey:c] chosen])
            [ret addObject:c];
    }
    return ret;
}

-(NSArray*)getOptionalCategories {
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    NSArray* sorted = [[[categories keyEnumerator] allObjects] sortedArrayUsingComparator:categoryCmp];
    for (NSString* c in sorted) {
        if (![[categories objectForKey:c] required])
            [ret addObject:c];
    }
    return ret;
}

-(NSArray*)getRequiredCategories {
    NSArray* sorted = [[[categories keyEnumerator] allObjects] sortedArrayUsingComparator:categoryCmp];
    NSMutableArray* cs = [[NSMutableArray alloc] init];
    for (NSString*c in sorted) {
        if ([[categories objectForKey:c] required])
            [cs addObject:c];
    }
    int i=0;
    if (localImages != nil && [localImages count] > 0)
        [cs insertObject:NSLocalizedString(@"Your Photos Title", nil) atIndex:i++];
    [cs insertObject:NSLocalizedString(@"Your Messages Title", nil) atIndex:i++];
    if (SaveRecentMessages && [RecentMessages count] > 0)
        [cs insertObject:NSLocalizedString(@"Recent Messages Title", nil) atIndex:i];
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

-(NSArray*)getMessagesForCategory:(NSString*)category {
    if ([category isEqualToString:NSLocalizedString(@"Your Photos Title", nil)])
        return localImages;
    else if ([category isEqualToString:NSLocalizedString(@"Your Messages Title", nil)])
        return YourMessages;
    else if ([category isEqualToString:NSLocalizedString(@"Recent Messages Title", nil)])
        return RecentMessages;
    else
        return [[categories objectForKey:category] messages];
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

-(Message*)chooseRandomMessage {
    BOOL chooseRecent = ([RecentCategories count] > 0 && arc4random() % 3) != 0;
    NSInteger m = -1;
    MessageCategory* cat;
    
    while (m < 0) {
        NSMutableDictionary* cs = (chooseRecent) ? RecentCategories : categories;
        NSInteger c = arc4random() % [cs count];
        for (MessageCategory* ms in cs) {
            if (c == 0)
                cat = ms;
            c--;
        }
        if ([categories objectForKey:cat] == nil || [[[categories objectForKey:cat] messages] count] == 0) {
            [RecentCategories removeObjectForKey:cat];
            chooseRecent = ([RecentCategories count] > 0 && arc4random() % 3) != 0;
            [Settings SaveSetting:SettingRecentCategories withValue:RecentCategories];
        }
        else {
            m = arc4random() % [[[categories objectForKey:cat] messages] count];
        }
    }
    return [[[categories objectForKey:cat] messages] objectAtIndex:m];
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

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    currentElement = elementName;
    if ([elementName isEqualToString:@"notes"]) {
        LastNoteDownload = [attributeDict objectForKey:@"ts"];
        if (AppID == nil || ![AppID isEqualToString:[attributeDict objectForKey:@"app"]]) {
            AppID = [attributeDict objectForKey:@"app"];
            [Settings SaveSetting:SettingAppID withValue:AppID];
        }
        
        [Settings SaveSetting:SettingLastNoteDownload withValue:LastNoteDownload];
    }
    else if ([elementName isEqualToString:@"ns"]) {
        NotificationMsgs = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:@"c"]) {
        NSString* name = [attributeDict objectForKey:@"name"];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        currentCategory = [[MessageCategory alloc] initWithName:name];
        [currentCategory setOrder:[tmpCategories count]];
        [currentCategory setRequired:([[attributeDict allKeys] containsObject:@"required"] &&
                                      [[attributeDict objectForKey:@"required"] isEqualToString:@"1"])];
        [currentCategory setNewCategory:([[attributeDict allKeys] containsObject:@"new"] &&
                                         [[attributeDict objectForKey:@"new"] isEqualToString:@"1"])];
        [currentCategory setChosen:(ChosenCategories == nil ||
                                    [ChosenCategories containsObject:[currentCategory name]] ||
                                    [currentCategory newCategory])];
        [currentCategory setMessages:[[NSMutableArray alloc] init]];
        if ([currentCategory required]) {
            if (InitialCategory == nil || [InitialCategory length] == 0) {
                InitialCategory = [currentCategory name];
                //CurrentCategory = [currentCategory name];
                [Settings SaveSetting:InitialCategory withValue:[currentCategory name]];
            }

        }
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
        if (ChosenCategories != nil && [currentCategory newCategory]) {
            [ChosenCategories addObject:[currentCategory name]];
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
        xmldata = [[NSMutableString alloc] init];
        currentText = nil;
        currentMediaUrl = nil;
        currentUrl = nil;
    }
    else if ([elementName isEqualToString:@"t"])
        xmldata = [[NSMutableString alloc] init];
    else if ([elementName isEqualToString:@"text"] || [elementName isEqualToString:@"media"] ||
                                                      [elementName isEqualToString:@"url"])
        partsdata = [[NSMutableString alloc] init];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([currentElement isEqualToString:@"n"] || [currentElement isEqualToString:@"t"])
        [xmldata appendString:string];
    else if ([currentElement isEqualToString:@"text"] || [currentElement isEqualToString:@"media"] ||
             [currentElement isEqualToString:@"url"])
         [partsdata appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"n"]) {
        NSString* m = (currentText==nil && currentMediaUrl==nil && currentUrl==nil) ? xmldata : currentText;
        Message* msg = [[Message alloc] initWithId:currentMsgId
                                              text:m
                                          mediaUrl:currentMediaUrl
                                               url:currentUrl
                                       forCategory:[currentCategory name]
                                             isNew:newMsg];
        [msg setLiked:likedMsg];
        [[currentCategory messages] addObject:msg];
    }
    else if ([elementName isEqualToString:@"t"]) {
        [NotificationMsgs addObject:xmldata];
    }
    else if ([elementName isEqualToString:@"notes"]) {
        if (!notificationOnly) {
            for (NSString* c in [tmpCategories keyEnumerator]) {
                [KnownCategories setObject:@"" forKey:c];
            }
            [Settings SaveSetting:SettingKnownCategories withValue:KnownCategories];
            [Settings SaveSetting:SettingNotificationMsgs withValue:NotificationMsgs];
            
            for (NSString* c in ChosenCategories) {
                //Need to make sure the chosen categories are in the content
                if ([tmpCategories objectForKey:c] == nil && ![c isEqualToString:@"Your Photos"] &&
                    ![c isEqualToString:@"Your Messages"])
                    [ChosenCategories removeObject:c];
            }
            [Settings SaveSetting:SettingChosenCategories withValue:ChosenCategories];
        }
    }
    else if ([elementName isEqualToString:@"text"] && [partsdata length] > 0)
        currentText = partsdata;
    else if ([elementName isEqualToString:@"media"] && [partsdata length] > 0)
        currentMediaUrl = partsdata;
    else if ([elementName isEqualToString:@"url"] && [partsdata length] > 0)
        currentUrl = partsdata;
}

@end
