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

//extern MFMessageComposeViewController* msgcontroller;

@interface SendMessage : NSObject<MFMessageComposeViewControllerDelegate> {
    UIViewController* _parent;
    //ImageDownloader* loader;
    NSMutableData* inetdata;
    NSMutableArray* contacts;
    int sendcount;
}

@property (nonatomic, strong) MFMessageComposeViewController* msgcontroller;

-(void)sendMessageTo:(NSArray*) contactlist from:(UIViewController*)parent;
-(void)updateMessageCount:(int)msgId withCount:(unsigned int)c;
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;

@end
