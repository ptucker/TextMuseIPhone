//
//  ImageDownloader.h
//  TextMate
//
//  Created by Peter Tucker on 7/9/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

typedef void(*callback)(void);

@class Message;

@interface ImageDownloader : NSObject<NSURLConnectionDelegate> {
    NSString* _url;
    UIButton* _btn;
    UIImageView* _view;
    UITableView* _tableView;
    UINavigationItem* _navigationItem;
    id _target;
    SEL _selector;
    Message* _msg;
    NSString* mimeType;
    int retryCount;
    NSArray* _backgroundColors;
    callback _cback;
    
    NSMutableData* inetdata;
    NSURLConnection* connection;
}

@property (readonly, retain) NSMutableData* inetdata;
@property (readonly, retain) NSString* mimeType;
@property (readonly) BOOL isVideo;

-(id)initWithUrl:(NSString*)url forMessage:(Message*)msg forImgView:(UIImageView*)view;
-(id)initWithUrl:(NSString*)url forImgView:(UIImageView*)view;
-(id)initWithUrl:(NSString*)url forImgView:(UIImageView*)view chooseBackground:(NSArray*)colors;
-(id)initWithUrl:(NSString*)url forMessage:(Message*)msg;
-(id)initWithUrl:(NSString*)url forButton:(UIButton*)btn;
-(id)initWithUrl:(NSString*)url forNavigationItemLeftButton:(UINavigationItem*)navigationItem
      withTarget:(id)target withSelector:(SEL)selector;
-(id)initWithUrl:(NSString*)url;
-(BOOL)load;
-(void)addImageView:(UIImageView*)view;
-(void)addCallback:(callback)cb;
-(void)addTableView:(UITableView*)tableView;

+(NSString*)GetYoutubeId:(NSString*)youtubeUrl;
+(NSString *)mimeTypeByGuessingFromData:(NSData *)data;
+(void)CancelDownloads;

@end
