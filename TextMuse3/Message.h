//
//  Message.h
//  FriendlyNotes
//
//  Created by Peter Tucker on 6/7/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageDownloader.h"
#import "FLAnimatedImage.h"

@interface Message : NSObject <UIWebViewDelegate> {
    int msgId;
    int order;
    int yourtextIndex;
    BOOL newMsg;
    BOOL pinned;
    BOOL liked;
    BOOL badge;
    
    int likeCount;
    BOOL version;
    ImageDownloader* loader;
    NSObject* imgLock;
    NSData* img;
    NSURL *assetURL;
    NSString* imgType;
    NSString* msgUrl;
    NSString* category;
    
    NSString* text;
    NSString* mediaUrl;
    NSString* url;
    NSString* eventLocation;
    NSString* eventDate;
    
    UIActivityIndicatorView* activityView;
    UIWebView* web;
}

@property (readwrite) int msgId;
@property (readwrite) int order;
@property (readwrite) BOOL newMsg;
@property (readwrite) BOOL pinned;
@property (readwrite) BOOL liked;
@property (readwrite) BOOL badge;
@property (readwrite) int likeCount;
@property (readwrite) BOOL version;
@property (readonly) ImageDownloader* loader;
@property (nonatomic, readwrite, copy) NSData* img;
@property (nonatomic, readonly, retain) NSURL* assetURL;
@property (nonatomic, readwrite, copy) NSString* imgType;
@property (nonatomic, readwrite, copy) NSString* msgUrl;
@property (nonatomic, readonly, copy) NSString* category;

@property (nonatomic, readonly, copy) NSString* text;
@property (nonatomic, readonly, copy) NSString* mediaUrl;
@property (nonatomic, readonly, copy) NSString* url;
@property (nonatomic, readwrite, copy) NSString* eventLocation;
@property (nonatomic, readwrite, copy) NSString* eventDate;
@property (nonatomic, readonly, copy) NSString* sponsorUrl;
@property (nonatomic, readonly, copy) NSString* sponsorIcon;

-(id)initWithId:(int)i text:(NSString *)t mediaUrl:(NSString*)murl url:(NSString*)u
    forCategory:(NSString*)c isNew:(BOOL)n;
//-(id)initWithId:(int)i message:(NSString*)m forCategory:(NSString*)c isNew:(BOOL)n;
-(id)initFromStorage:(NSString*)stored;
-(id)initFromUserPhoto:(ALAsset*)imgfile;
-(void)loadUserImage;
-(BOOL)isImgNull;
-(id)initFromUserText:(NSString*)msg atIndex:(int)i;

-(NSString*)stringForStorage;

-(BOOL)containsImage;
-(BOOL)containsVideo;
-(BOOL)isVideo;

-(NSString*)getFullMessage;

-(void)action:(id)sender;
-(void)follow:(id)sender;
-(void)updateText:(id)sender;

-(NSString*)description;

+(NSArray*)FindUrlInString:(NSString*)str;
+(BOOL)ContainsImage:(NSString*)str;
@end
