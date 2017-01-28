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

NSString* urlUpdateNotes = @"http://www.textmuse.com/admin/notesend.php";
MFMessageComposeViewController* msgcontroller = nil;

@implementation SendMessage

-(void) sendMessageTo:(NSArray*) contactlist from:(UIViewController *)parent {
    _parent = parent;
    sendcount = (int)[contactlist count];
    if (msgcontroller == nil)
        msgcontroller = [[MFMessageComposeViewController alloc] init];

    if ([CurrentMessage msgId] > 0)
        [Settings AddRecentMessage:CurrentMessage];
    if (CurrentCategory != nil) {
        //Could be nil for Your Photos, Your Texts
        [RecentCategories setObject:[CurrentMessage description] forKey:CurrentCategory];
        [Settings SaveSetting:SettingRecentCategories withValue:RecentCategories];
    }
    
    if([MFMessageComposeViewController canSendText])
    {
        NSMutableArray* phones = [[NSMutableArray alloc] init];
        for (UserContact*c in contactlist) {
            [phones addObject:[c getPhone]];
            [Settings AddRecentContact:[c getPhone]];
        }
        [msgcontroller setRecipients: phones];
        [msgcontroller setMessageComposeDelegate: self];
        
        NSString* urlAdd = ([CurrentMessage url] == nil ? @"" :
                            [NSString stringWithFormat:@" (%@)", [CurrentMessage url]]);
        NSString* text = ([CurrentMessage getFullMessage] == nil ? @"" : [CurrentMessage getFullMessage]);
        NSString* message = [NSString stringWithFormat:@"%@%@", text, urlAdd];

        NSString* tagline = @"";
        //if (arc4random() % 10 == 0)
        message = [message stringByAppendingString:tagline];
        if ([Preamble length] > 0)
            message = [NSString stringWithFormat:@"%@ %@", Preamble, message];
        if ([Inquiry length] > 0)
            message = [NSString stringWithFormat:@"%@ (%@)", message, Inquiry];
        if (([CurrentMessage mediaUrl] == nil || [[CurrentMessage mediaUrl] length] == 0) &&
            [CurrentMessage img] == nil)
            [msgcontroller setBody: message];
        else {
            if ([CurrentMessage isVideo])
                message = [NSString stringWithFormat:@"%@%@%@", text, urlAdd, tagline];
            [msgcontroller setBody:message];
            if ([CurrentMessage assetURL] != nil) {
                ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
                [library assetForURL:[CurrentMessage assetURL] resultBlock:^(ALAsset* asset) {
                    CGImageRef ir = [[asset defaultRepresentation] fullScreenImage];
                    NSData* d = UIImagePNGRepresentation([UIImage imageWithCGImage:ir]);
                    [msgcontroller addAttachmentData:d
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
            else {
                [msgcontroller addAttachmentData:[loader inetdata]
                                  typeIdentifier:(NSString*)kUTTypeImage
                                        filename:@"test.png"];
            }
        }
        
        [parent presentViewController:msgcontroller animated:YES completion:^{ }];
    }
}

-(void)updateMessageCount:(int)msgId withCount:(unsigned int)c {
    NSURL* url = [NSURL URLWithString:urlUpdateNotes];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url
                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                   timeoutInterval:30];
    inetdata = [[NSMutableData alloc] init];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[[NSString stringWithFormat:@"id=%d&app=%@&cnt=%d", msgId, AppID, c]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    
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
        [msgcontroller dismissViewControllerAnimated:YES completion:nil];
    }
    else
        [self updateMessageCount:[CurrentMessage msgId] withCount:(unsigned int)sendcount];
        [msgcontroller dismissViewControllerAnimated:YES completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_parent dismissViewControllerAnimated:YES completion:nil];
                [[_parent navigationController] popToRootViewControllerAnimated:YES];
            });
        }];
    
    msgcontroller = nil;
}


@end
