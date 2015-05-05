//
//  ImageDownloader.h
//  TextMate
//
//  Created by Peter Tucker on 7/9/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "Message.h"

@interface ImageDownloader : NSObject<NSURLConnectionDelegate> {
    NSString* _url;
    UIButton* _btn;
    UIImageView* _view;
    Message* _msg;
    NSString* mimeType;
    
    NSMutableData* inetdata;
    NSURLConnection* connection;
}

@property (readonly, retain) NSMutableData* inetdata;
@property (readonly, retain) NSString* mimeType;
@property (readonly) BOOL isVideo;

-(id)initWithUrl:(NSString*)url forMessage:(Message*)msg forImgView:(UIImageView*)view;
-(id)initWithUrl:(NSString*)url forMessage:(Message*)msg;
-(id)initWithUrl:(NSString*)url forButton:(UIButton*)btn;
-(void)load;

+(NSString*)GetYoutubeId:(NSString*)youtubeUrl;

@end
