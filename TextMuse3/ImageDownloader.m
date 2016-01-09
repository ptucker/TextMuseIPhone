//
//  ImageDownloader.m
//  TextMate
//
//  Created by Peter Tucker on 7/9/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import "ImageDownloader.h"
#import "Settings.h"
#include <libkern/OSAtomic.h>

int downloading = 0;
const int MAXDOWNLOAD = 48;
const int MAXRETRY = 5;
NSMutableArray* downloadQueue = nil;

@implementation ImageDownloader
@synthesize inetdata, mimeType, isVideo;

-(id)initWithUrl:(NSString*)url forMessage:(Message *)msg forImgView:(UIImageView*)view {
    _url = url;
    _view = view;
    _msg = msg;
    
    [ImageDownloader initQueue];
    [self checkCache];
    
    return self;
}

-(id)initWithUrl:(NSString*)url forImgView:(UIImageView*)view {
    _url = url;
    _view = view;
    
    [ImageDownloader initQueue];
    [self checkCache];

    return self;
}

-(id)initWithUrl:(NSString*)url forNavigationItemLeftButton:(UINavigationItem*)navigationItem
      withTarget:(id)target withSelector:(SEL)selector {
    _url = url;
    _navigationItem = navigationItem;
    _target = target;
    _selector = selector;
    
    [ImageDownloader initQueue];
    [self checkCache];

    return self;
}

-(id)initWithUrl:(NSString*)url {
    _url = url;
    
    [ImageDownloader initQueue];
    [self checkCache];

    return self;
}

-(id)initWithUrl:(NSString*)url forMessage:(Message *)msg {
    _url = url;
    _msg = msg;
    
    [ImageDownloader initQueue];
    [self checkCache];

    return self;
}

-(id)initWithUrl:(NSString *)url forButton:(UIButton *)btn {
    _url = url;
    _btn = btn;
    
    [ImageDownloader initQueue];
    [self checkCache];

    return self;
}

+(void)initQueue {
    @synchronized(downloadQueue) {
        if (downloadQueue == nil)
            downloadQueue = [[NSMutableArray alloc] init];
    }
}

+(void)enqueueDownload:(ImageDownloader*)loader {
    @synchronized(downloadQueue) {
        [downloadQueue addObject:loader];
    }
}

+(ImageDownloader*)dequeueDownload {
    ImageDownloader* ret;
    @synchronized(downloadQueue) {
        if (downloadQueue != nil && [downloadQueue count] > 0) {
            ret = [downloadQueue objectAtIndex:0];
            [downloadQueue removeObjectAtIndex:0];
        }
        else
            ret = nil;
    }
    return ret;
}

+(void)CancelDownloads {
    @synchronized(downloadQueue) {
        if (downloadQueue != nil)
            [downloadQueue removeAllObjects];
    }
}

-(void)checkCache {
    retryCount = 0;
    NSString* u = _url;
    NSString* ytid = [ImageDownloader GetYoutubeId:_url];
    
    if (ytid != nil)
        u = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg", ytid];
    [ActiveURLs setValue:@"" forKey:u];
    
    if (CachedMediaMapping != nil && [CachedMediaMapping objectForKey:u] != nil) {
        NSString* cachedFile = [CachedMediaMapping objectForKey:u];
        inetdata = [NSMutableData dataWithContentsOfFile:cachedFile];
        if (inetdata != nil) {
            mimeType = @"image/png";
            [self useImageData];
        }
    }
}

-(BOOL)load {
    BOOL ret = false;
    if (_url == nil)
        return ret;
    
    [self checkCache];
    if (inetdata == nil) {
        if (downloading < MAXDOWNLOAD)
            [self startDownload];
        else
            [ImageDownloader enqueueDownload:self];
    }
    return ret;
}

-(void)startDownload {
    NSString* u = _url;
    NSString* ytid = [ImageDownloader GetYoutubeId:_url];
    
    if (ytid != nil)
        u = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg", ytid];
    [ActiveURLs setValue:@"" forKey:u];
    
    NSURL* url = [NSURL URLWithString:u];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    
    inetdata = [[NSMutableData alloc] init];
    connection = [[NSURLConnection alloc] initWithRequest:request
                                                 delegate:self
                                         startImmediately:YES];
    
    OSAtomicAdd32(1, &downloading);
    //NSLog([NSString stringWithFormat:@"download count: %d", downloading]);
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

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (retryCount < MAXRETRY) {
        retryCount++;
        
        inetdata = nil;
        [self load];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)_connection{
    OSAtomicAdd32(-1, &downloading);
    ImageDownloader* waiting = [ImageDownloader dequeueDownload];
    if (waiting != nil)
        [waiting startDownload];
    
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
    if (_navigationItem != nil) {
        UIImage* o = [UIImage imageWithData:inetdata];
        UIImage *scaledO = [UIImage imageWithCGImage:[o CGImage]
                                               scale:o.size.width/30
                                         orientation:(o.imageOrientation)];
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:scaledO
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:_target
                                                                      action:_selector];
        [_navigationItem setLeftBarButtonItem:leftButton];
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
