//
//  ImageDownloader.m
//  TextMate
//
//  Created by Peter Tucker on 7/9/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import "ImageDownloader.h"
#import "Settings.h"

@implementation ImageDownloader
@synthesize inetdata, mimeType, isVideo;

-(id)initWithUrl:(NSString*)url forMessage:(Message *)msg forImgView:(UIImageView*)view {
    _url = url;
    _view = view;
    _msg = msg;
    
    return self;
}

-(id)initWithUrl:(NSString*)url forMessage:(Message *)msg {
    _url = url;
    _msg = msg;
    
    return self;
}

-(id)initWithUrl:(NSString *)url forButton:(UIButton *)btn {
    _url = url;
    _btn = btn;
    
    return self;
}

-(void)load {
    NSString* u = _url;
    NSString* ytid = [ImageDownloader GetYoutubeId:_url];
    
    if (ytid != nil)
        u = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg", ytid];
    [ActiveURLs setValue:@"" forKey:u];
    
    if (CachedMediaMapping != nil && [CachedMediaMapping objectForKey:u] != nil) {
        NSString* cachedFile = [CachedMediaMapping objectForKey:u];
        if ([[NSFileManager defaultManager] fileExistsAtPath:cachedFile]) {
            inetdata = [NSMutableData dataWithContentsOfFile:cachedFile];
            mimeType = @"image/png";
            [self useImageData];
        }
    }
    if (inetdata == nil) {
        NSURL* url = [NSURL URLWithString:u];
    
        NSURLRequest* request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
                                             timeoutInterval:30];
    
        inetdata = [[NSMutableData alloc] init];
        connection = [[NSURLConnection alloc] initWithRequest:request
                                                     delegate:self
                                             startImmediately:YES];
    }
}

-(BOOL) mimeTypeSupported:(NSString*)mtype {
    return [[mtype substringToIndex:6] isEqualToString:@"image/"];
}

-(void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
    mimeType = [response MIMEType];
    
    if (![self mimeTypeSupported:mimeType])
        [connection cancel];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    //Append the newly arrived data to whatever we’ve seen so far
    [inetdata appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)_connection{
    [self useImageData];

    NSString* u = [[[connection currentRequest] URL] description];
    if ([CachedMediaMapping objectForKey:u] == nil ||
            ![[NSFileManager defaultManager] fileExistsAtPath:[CachedMediaMapping objectForKey:u]]) {
        NSString *prefixString = @"media";
        NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
        NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
        NSString* mapfile = [NSTemporaryDirectory() stringByAppendingPathComponent:uniqueFileName];

        [inetdata writeToFile:mapfile atomically:YES];
        
        @synchronized(CachedMediaMapping) {
            [CachedMediaMapping setValue:mapfile forKey:u];
        }
    }
}

-(void)useImageData {
    //Download complete. Write to view and/or message
    if (_view != nil) {
        if ([[mimeType substringToIndex:6] isEqualToString:@"image/"])
            [_view setImage:[UIImage imageWithData:inetdata]];
    }
    if (_msg != nil) {
        [_msg setImg:[inetdata copy]];
        [_msg setImgType:mimeType];
    }
    if (_btn != nil) {
        if ([[mimeType substringToIndex:6] isEqualToString:@"image/"]) {
            [_btn setImage:[UIImage imageWithData:inetdata] forState:UIControlStateNormal];
            [_btn setContentMode:UIViewContentModeScaleAspectFit];
            [_btn setHidden:NO];
        }
    }
}

+(NSString*)GetYoutubeId:(NSString *)youtubeUrl {
    NSString* ret = nil;
    NSArray* yturls = [NSArray arrayWithObjects:@"http://youtu.be/",
                       @"http://www.youtube.com/", @"https://youtu.be/", @"https://www.youtube.com/", nil];
    
    for (int i=0; i<[yturls count] && ret == nil; i++) {
        NSString* test = [yturls objectAtIndex:i];
        if ([youtubeUrl length] >= [test length] &&
                    [[youtubeUrl substringToIndex:[test length]] isEqualToString:test])
            ret = [youtubeUrl substringFromIndex:[test length]];
    }

    return ret;
}

@end
