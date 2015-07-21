//
//  Message.m
//  FriendlyNotes
//
//  Created by Peter Tucker on 6/7/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import "Message.h"
#import "ImageDownloader.h"
#import "Settings.h"

@implementation Message
@synthesize msgId, newMsg, img, assetURL, imgType, msgUrl, category, text, mediaUrl, url, liked;

-(id)initWithId:(int)i message:(NSString *)m forCategory:(NSString*)c isNew:(BOOL)n {
    //msg = m;
    msgId = i;
    newMsg = n;
    category = c;
    
    NSArray* parts = [Message FindUrlInString:m];
    if (parts != nil) {
        msgUrl = [parts objectAtIndex:0];
        ImageDownloader* loader = [[ImageDownloader alloc] initWithUrl:[parts objectAtIndex:0]
                                                            forMessage:self];
        [loader load];
    }
    
    return self;
}

-(id)initWithId:(int)i text:(NSString *)t mediaUrl:(NSString*)murl url:(NSString*)u
        forCategory:(NSString*)c isNew:(BOOL)n {
    //msg = t;
    text = t;
    mediaUrl = murl;
    url = u;
    msgId = i;
    newMsg = n;
    category = c;
    
    if (mediaUrl != nil) {
        ImageDownloader* loader = [[ImageDownloader alloc] initWithUrl:mediaUrl forMessage:self];
        [loader load];
    }
    
    return self;
}

-(id)initFromStorage:(NSString *)stored {
    int ich = -1;
    for (int i=0; ich == -1 && i < [stored length]; i++) {
        if ([stored characterAtIndex:i] == '@')
            ich = i;
    }
    
    if (ich != -1) {
        msgId = [[stored substringToIndex:ich] intValue];
        text = [stored substringFromIndex:(ich+1)];
    }
    else {
        msgId = 0;
        text = stored;
    }
    
    return self;
}

-(id)initFromUserPhoto:(ALAsset *)a {
    msgId = -2;
    newMsg = NO;
    category = NSLocalizedString(@"Your Photos Title", nil);
    mediaUrl = @"userphoto://";
    assetURL = [a valueForProperty:ALAssetPropertyAssetURL];
    
    return self;
}

-(id)initFromUserText:(NSString *)msg atIndex:(int)i {
    msgId = -3;
    newMsg = NO;
    yourtextIndex = i;
    category = NSLocalizedString(@"Your Messages Title", nil);
    mediaUrl = @"usertext://";
    text = msg;
    
    return self;
}

-(void)loadUserImage {
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:assetURL resultBlock:^(ALAsset* asset) {
        CGImageRef ir = [[asset defaultRepresentation] fullScreenImage];
        img = UIImagePNGRepresentation([UIImage imageWithCGImage:ir]);
    } failureBlock:^(NSError*err) { }];
}

-(NSString*)stringForStorage {
    return [NSString stringWithFormat:@"%d@%@", msgId, text];
}

-(BOOL)containsImage {
    NSString* typePrefix = [imgType substringToIndex:6];
    return [mediaUrl isEqualToString:@"userphoto://"] || [typePrefix isEqualToString:@"image/"];
}

-(BOOL)containsVideo {
    return [[imgType substringToIndex:6] isEqualToString:@"video/"];
}

-(BOOL)isVideo {
    return [ImageDownloader GetYoutubeId:mediaUrl] != nil;
}

-(void)action:(id)sender {
    if (mediaUrl != nil) {
        //Check if this is a youtube URL
        NSString* ytid = [ImageDownloader GetYoutubeId:mediaUrl];
        NSString* appUrl = mediaUrl;
        if (ytid != nil)
            appUrl = [NSString stringWithFormat:@"youtube://%@", ytid];
        
        if (ytid != nil) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appUrl]])
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appUrl]];
            else
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:msgUrl]];
        }
        else {
            //pop up the image within this app, rather than in safari
            UIButton* btn = (UIButton*)sender;
            UIView* parent = [btn superview];
            while ([parent superview] != nil)
                parent = [parent superview];
            CGRect endFrame = [parent frame];
            CGRect bfrm = [parent frame];
            int x = bfrm.origin.x + bfrm.size.width/2;
            int y = bfrm.origin.y + bfrm.size.height/2;
            UIButton* imgview = [[UIButton alloc] initWithFrame:CGRectMake(x, y, 0, 0)];
            [imgview setContentMode:UIViewContentModeScaleToFill];
            [imgview setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8]];
            [[imgview imageView] setContentMode:UIViewContentModeScaleAspectFit];
            [imgview addTarget:self
                        action:@selector(closeImage:)
              forControlEvents:UIControlEventTouchUpInside];
            [parent addSubview:imgview];
            if (assetURL == nil) {
                ImageDownloader* loader = [[ImageDownloader alloc] initWithUrl:mediaUrl forButton:imgview];
                [loader load];
                [UIView animateWithDuration:0.5 animations:^{
                    [imgview setFrame:endFrame];
                } completion: ^(BOOL f) {
                }];
            }
            else {
                //[imgview setImage:[UIImage imageWithData:img] forState:UIControlStateNormal];
                ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
                [library assetForURL:assetURL resultBlock:^(ALAsset* asset) {
                    CGImageRef ir = [[asset defaultRepresentation] fullScreenImage];
                    NSData* d = UIImagePNGRepresentation([UIImage imageWithCGImage:ir]);
                    [imgview setImage:[UIImage imageWithData:d] forState:UIControlStateNormal];
                    [UIView animateWithDuration:0.5 animations:^{
                        [imgview setFrame:endFrame];
                    } completion: ^(BOOL f) {
                    }];
                } failureBlock:^(NSError*err) {
                    [imgview setImage:[UIImage imageWithData:img] forState:UIControlStateNormal];
                }];
            }
        }
    }
}

-(void)closeImage:(id)sender {
    UIView* v = (UIView*)sender;
    CGRect endFrame = CGRectMake([v frame].origin.x + [v frame].size.width/2,
                                 [v frame].origin.y + [v frame].size.height/2, 0, 0);
    [UIView animateWithDuration:0.5 animations:^{
        [v setFrame:endFrame];
    } completion: ^(BOOL f) {
        [v removeFromSuperview];
    }];
}

-(void)follow:(id)sender {
    if (url != nil) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

-(void)updateText:(id)sender {
    UITextView* txt = (UITextView*) sender;
    text = [txt text];
    [YourMessages setObject:self atIndexedSubscript:yourtextIndex];
    [Settings SaveUserMessages];
}

-(NSString*)description {
    if (text != nil && [text length] > 0)
        return text;
    else if (url != nil && [url length] > 0)
        return url;
    else if (mediaUrl != nil && [mediaUrl length] > 0)
        return mediaUrl;
    else
        return @"empty";
}

+(NSArray*)FindUrlInString:(NSString*)str {
    if (str == nil)
        return nil;
    
    NSArray* ret = nil;
    NSString* expr = @"(http(s)?|assets-library)://([\\w+?\\.\\w+])+([a-zA-Z0-9\\~\\!\\@\\#\\$\\%\\^\\&amp;\\*\\(\\)_\\-\\=\\+\\\\\\/\\?\\.\\:\\;\\'\\,]*)?";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSUInteger matches = [regex numberOfMatchesInString:str
                                                options:0
                                                  range:NSMakeRange(0, [str length])];
    if (matches != 0) {
        NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:str
                                                             options:0
                                                               range:NSMakeRange(0, [str length])];
        NSString* url = [str substringWithRange:rangeOfFirstMatch];
        unsigned long remainStart = rangeOfFirstMatch.location+rangeOfFirstMatch.length;
        NSMutableString* remaining = [NSMutableString stringWithString:[str substringWithRange:NSMakeRange(0, rangeOfFirstMatch.location)]];
        [remaining appendString:[str substringWithRange:NSMakeRange(remainStart, [str length] - remainStart)]];
        
        ret = [NSArray arrayWithObjects:url, remaining, nil];
    }
    
    return ret;
}

+(BOOL)ContainsImage:(NSString*)str {
    NSString* ext = [[str pathExtension] lowercaseString];
    return ([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"png"] ||
            [ext isEqualToString:@"gif"] || [ext isEqualToString:@"bmp"]);
}

@end
