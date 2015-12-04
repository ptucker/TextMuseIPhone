//
//  SendMessage.h
//  TextMuse
//
//  Created by Peter Tucker on 12/3/15.
//  Copyright © 2015 LaLoosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MessageUI/MessageUI.h>
#import "ImageDownloader.h"

extern MFMessageComposeViewController* msgcontroller;

@interface SendMessage : NSObject<MFMessageComposeViewControllerDelegate> {
    UIViewController* _parent;
    ImageDownloader* loader;
    NSMutableData* inetdata;
}

-(void) sendMessageTo:(NSArray*) contactlist from:(UIViewController*)parent;
-(void)updateMessageCount:(int)msgId;
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;

@end
