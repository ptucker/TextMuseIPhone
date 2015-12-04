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

NSString* urlUpdateNotes = @"http://www.textmuse.com/admin/notesend.php";
MFMessageComposeViewController* msgcontroller = nil;

@implementation SendMessage

-(void) sendMessageTo:(NSArray*) contactlist from:(UIViewController *)parent {
    _parent = parent;
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
        [self updateMessageCount:[CurrentMessage msgId]];
        NSMutableArray* phones = [[NSMutableArray alloc] init];
        for (UserContact*c in contactlist) {
            [phones addObject:[c getPhone]];
            [Settings AddRecentContact:[c getPhone]];
        }
        [msgcontroller setRecipients: phones];
        [msgcontroller setMessageComposeDelegate: self];
        
        NSString* urlAdd = ([CurrentMessage url] == nil ? @"" :
                            [NSString stringWithFormat:@" (%@)", [CurrentMessage url]]);
        NSString* text = ([CurrentMessage text] == nil ? @"" : [CurrentMessage text]);
        NSString* message = [NSString stringWithFormat:@"%@%@", text, urlAdd];
        NSString* sponsor = @"";
#ifdef WHITWORTH
        sponsor = @"Whitworth ";
#endif
#ifdef UOREGON
        sponsor = @"Oregon ";
#endif
        if (Skin != nil)
            sponsor = [[Skin SkinName] stringByAppendingString:@" "];
        
        //NSString* tagline = [NSString stringWithFormat: @"\n\nSent by %@TextMuse - http://bit.ly/1QDXyfj", sponsor];
        NSString* tagline = @"";
        //if (arc4random() % 10 == 0)
        message = [message stringByAppendingString:tagline];
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
                [msgcontroller addAttachmentData:[CurrentMessage img]
                                  typeIdentifier:(NSString*)kUTTypeImage
                                        filename:@"test.png"];
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

-(void)updateMessageCount:(int)msgId {
    NSURL* url = [NSURL URLWithString:urlUpdateNotes];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url
                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                   timeoutInterval:30];
    inetdata = [[NSMutableData alloc] init];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[[NSString stringWithFormat:@"id=%d&app=%@", msgId, AppID]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:self
                                                    startImmediately:YES];
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
        [msgcontroller dismissViewControllerAnimated:YES completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_parent dismissViewControllerAnimated:YES completion:nil];
                [[_parent navigationController] popToRootViewControllerAnimated:YES];
            });
        }];
    
    msgcontroller = nil;
}


@end
