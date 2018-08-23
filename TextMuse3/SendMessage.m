//
//  SendMessage.m
//  TextMuse
//
//  Created by Peter Tucker on 12/3/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import "SendMessage.h"
#import "GlobalState.h"
#import "UserContact.h"
#import "UICheckButton.h"
#import "Settings.h"
#import "ChoosePhoneView.h"
#import "SuccessParser.h"
#import "GuidedTourStepView.h"

NSString* urlUpdateNotes = @"http://www.textmuse.com/admin/notesend.php";
NSString* urlUpdateQuickNotes = @"http://www.textmuse.com/admin/quicksend.php";
NSString* urlFirstTimeSender = @"http://www.textmuse.com/admin/firsttimesender.php";
//MFMessageComposeViewController* msgcontroller = nil;

@implementation SendMessage
@synthesize msgcontroller;

-(id)init {
    if([MFMessageComposeViewController canSendText]) {
        [self setMsgcontroller:[[MFMessageComposeViewController alloc] init]];
    }
    
    return self;
}

-(void) sendMessageTo:(NSArray*) contactlist from:(UIViewController *)parent {
    _parent = parent;
    contacts = (contactlist != nil) ? [NSMutableArray arrayWithCapacity:[contactlist count]] : nil;
    sendcount = 0;

    if ([CurrentMessage msgId] > 0)
        [Settings AddRecentMessage:CurrentMessage];
    if (CurrentCategory != nil) {
        //Could be nil for Your Photos, Your Texts
        [RecentCategories setObject:[CurrentMessage description] forKey:CurrentCategory];
        [Settings SaveSetting:SettingRecentCategories withValue:RecentCategories];
    }
    
    if([MFMessageComposeViewController canSendText]) {
        if (contactlist != nil) {
            for (NSObject* o in contactlist) {
                if ([o isKindOfClass:[UserContact class]]) {
                    UserContact* c = (UserContact*)o;
                    [contacts addObject:[c getPhone]];
                    [Settings AddRecentContact:[c getPhone]];
                }
                else
                    [contacts addObject:(NSString*)o];
            }
        }
        
        NSMutableArray* phones = [[NSMutableArray alloc] init];
        if (contacts != nil) {
            if (GroupMessages) {
                for (NSString*c in contacts) {
                    [phones addObject:c];
                }
            }
            else {
                NSString* c = [contacts objectAtIndex:0];
                [phones addObject:c];
            }
        }
        [self sendMessages:phones];
    }
}

-(void)sendMessages:(NSArray*)phones {
#ifdef OODLES
    NSString* urlAdd = @" (http://apple.co/2pekrPf)";
#else
    NSString* urlAdd = ([CurrentMessage url] == nil ? @"" :
                        [NSString stringWithFormat:@" (%@)", [CurrentMessage url]]);
#endif
    NSString* text = ([CurrentMessage getFullMessage] == nil ? @"" : [CurrentMessage getFullMessage]);
    NSString* message = [NSString stringWithFormat:@"%@%@", text, urlAdd];
    
    NSString* tagline = @"";
    //if (arc4random() % 10 == 0)
    message = [message stringByAppendingString:tagline];
    if ([Preamble length] > 0)
        message = [NSString stringWithFormat:@"%@ %@", Preamble, message];
    if ([Inquiry length] > 0)
        message = [NSString stringWithFormat:@"%@ (%@)", message, Inquiry];
    
    if (!(([CurrentMessage mediaUrl] == nil || [[CurrentMessage mediaUrl] length] == 0) &&
        [CurrentMessage img] == nil))
        if ([CurrentMessage isVideo])
            message = [NSString stringWithFormat:@"%@%@%@", text, urlAdd, tagline];

    [self sendMessages:phones withMessage:message];
}

-(void)sendMessages:(NSArray*)phones withMessage:(NSString*)message {
    if([MFMessageComposeViewController canSendText]) {
        [msgcontroller setMessageComposeDelegate: self];
        if (phones != nil && [phones count] > 0)
            [msgcontroller setRecipients:phones];
        [msgcontroller setBody:message];
        if ([CurrentMessage assetURL] != nil) {
            ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:[CurrentMessage assetURL] resultBlock:^(ALAsset* asset) {
                CGImageRef ir = [[asset defaultRepresentation] fullScreenImage];
                NSData* d = UIImagePNGRepresentation([UIImage imageWithCGImage:ir]);
                [self->msgcontroller addAttachmentData:d
                                  typeIdentifier:(NSString*)kUTTypeImage
                                        filename:@"test.png"];
            } failureBlock:^(NSError*err) {}];
        }
        else if ([CurrentMessage img] != nil) {
            NSString* type = [[CurrentMessage imgType] isEqualToString: @"image/gif"] ?
            (NSString*)kUTTypeGIF : (NSString*)kUTTypeImage;
            NSString* tmpfile = [[CurrentMessage imgType] isEqualToString: @"image/gif"] ?
            @"test.gif" : @"test.png";
            [msgcontroller addAttachmentData:[CurrentMessage img]
                              typeIdentifier:type
                                    filename:tmpfile];
        }
        /*
        else {
            [msgcontroller addAttachmentData:[loader inetdata]
                              typeIdentifier:(NSString*)kUTTypeImage
                                    filename:@"test.png"];
        }
        */
     
        [_parent presentViewController:msgcontroller animated:YES completion:nil];
    }
}

-(void)updateMessageCount:(int)msgId withCount:(unsigned int)c {
    if (CurrentMessage == nil)
        return;
    
    NSURL* url = ([CurrentMessage quicksend]) ? [NSURL URLWithString:urlUpdateQuickNotes] :
                                                [NSURL URLWithString:urlUpdateNotes];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url
                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                   timeoutInterval:30];
    inetdata = [[NSMutableData alloc] init];
    [req setHTTPMethod:@"POST"];
    NSString* post = ([CurrentMessage quicksend]) ?
            [NSString stringWithFormat:@"id=%d&app=%@&cnt=%d&phone=0", msgId, AppID, c] :
            [NSString stringWithFormat:@"id=%d&app=%@&cnt=%d", msgId, AppID, c];
    [req setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:self
                                                    startImmediately:YES];
}

-(void)firstTimeSender:(int)msgId {
    if (CurrentMessage == nil)
        return;
    
    NSURL* url = [NSURL URLWithString:urlFirstTimeSender];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url
                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                   timeoutInterval:30];
    inetdata = [[NSMutableData alloc] init];
    [req setHTTPMethod:@"POST"];
    NSString* post = [NSString stringWithFormat:@"id=%d&app=%@&version=%ld", msgId, AppID, [Skin SkinID]];
    [req setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:self
                                                    startImmediately:YES];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    //Append the newly arrived data to whatever we’ve seen so far
    [inetdata appendData:data];
}

-(void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error {
    //NSLog([error localizedDescription]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)_connection{
    SuccessParser* sp = [[SuccessParser alloc] initWithXml:inetdata];
    
    [CurrentUser setExplorerPoints:[sp ExplorerPoints]];
    [CurrentUser setSharerPoints:[sp SharerPoints]];
    [CurrentUser setMusePoints:[sp MusePoints]];
    //NSString* data = [[NSString alloc] initWithData:inetdata encoding:NSUTF8StringEncoding];
    //NSLog(data);
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result != MessageComposeResultSent) {
        if (result == MessageComposeResultFailed) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Send Failed Title", nil)
                                  message:NSLocalizedString(@"Send Failed Text", nil)
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                                  otherButtonTitles:nil];
            [alert show];
        }
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        if (Tour != nil) {
            GuidedTourStepView* gv = [[GuidedTourStepView alloc] initWithStep:[Tour getStepForKey:[Tour Done]] forFrame:[[_parent view] frame]];
            [[_parent view] addSubview:gv];
            [[_parent view] bringSubviewToFront:gv];
            
            [self firstTimeSender:[CurrentMessage msgId]];
        }

        [self updateMessageCount:[CurrentMessage msgId]
                       withCount:[contacts count] == 0 ? 1 : (unsigned int)[contacts count]];
        [contacts removeAllObjects];
        [controller dismissViewControllerAnimated:YES completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_parent dismissViewControllerAnimated:YES completion:nil];
                [[self->_parent navigationController] popToRootViewControllerAnimated:YES];
            });
        }];
    }
}


@end
