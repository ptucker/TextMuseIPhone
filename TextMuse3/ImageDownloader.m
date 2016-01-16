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
        NSLog([NSString stringWithFormat:@"%lu downloads queued", (unsigned long)[downloadQueue count]]);
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
    
    NSString* cachedFile = nil;
    @synchronized(CachedMediaMapping) {
        if (CachedMediaMapping != nil && [CachedMediaMapping objectForKey:u] != nil)
            cachedFile = [CachedMediaMapping objectForKey:u];
    }
    
    if (cachedFile != nil) {
        inetdata = [NSMutableData dataWithContentsOfFile:cachedFile];
        if (inetdata != nil) {
            mimeType = [ImageDownloader mimeTypeByGuessingFromData:inetdata];
            if (mimeType != nil)
                [self useImageData];
            else {
                @synchronized(CachedMediaMapping) {
                    [CachedMediaMapping removeObjectForKey:u];
                }
                inetdata = nil;
            }
        }
    }
}

+ (NSString *)mimeTypeByGuessingFromData:(NSData *)data {
    
    char bytes[12] = {0};
    [data getBytes:&bytes length:12];
    
    const char bmp[2] = {'B', 'M'};
    const char gif[3] = {'G', 'I', 'F'};
    const char jpg[3] = {0xff, 0xd8, 0xff};
    const char png[8] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a};
    
    
    if (!memcmp(bytes, bmp, 2)) {
        return @"image/x-ms-bmp";
    } else if (!memcmp(bytes, gif, 3)) {
        return @"image/gif";
    } else if (!memcmp(bytes, jpg, 3)) {
        return @"image/jpeg";
    } else if (!memcmp(bytes, png, 8)) {
        return @"image/png";
    }
    
    return nil;
    
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

-(void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error {
    if (retryCount < MAXRETRY) {
        retryCount++;
        
        inetdata = nil;
        [self startDownload];
        NSLog([NSString stringWithFormat:@"retrying: %@", [[[_connection currentRequest] URL] absoluteString]]);
    }
    else
        NSLog([NSString stringWithFormat:@"download failed: %@", [error localizedDescription]]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)_connection{
    OSAtomicAdd32(-1, &downloading);
    ImageDownloader* waiting = [ImageDownloader dequeueDownload];
    if (waiting != nil)
        [waiting startDownload];
    
    [self useImageData];

    NSString* u = [[[connection currentRequest] URL] description];
    BOOL saveFile = false;
    @synchronized(CachedMediaMapping) {
        saveFile = ([CachedMediaMapping objectForKey:u] == nil ||
                    ![[NSFileManager defaultManager] fileExistsAtPath:[CachedMediaMapping objectForKey:u]]);
    }
    if (saveFile) {
        NSString *prefixString = @"media";
        NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
        NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
        NSString* tmpfile = [NSTemporaryDirectory() stringByAppendingPathComponent:uniqueFileName];
        BOOL writeSucceeded = [inetdata writeToFile:tmpfile atomically:YES];

        if (writeSucceeded) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            NSString* mapfile = [cachesDirectory stringByAppendingPathComponent:uniqueFileName];
            [[NSFileManager defaultManager] moveItemAtPath:tmpfile toPath:mapfile error:nil];
            
            @synchronized(CachedMediaMapping) {
                [CachedMediaMapping setValue:mapfile forKey:u];
                [Settings SaveCachedMapFile];
            }
        }
    }
}

-(void)useImageData {
    //Download complete. Write to view and/or message
    NSData* copy = [inetdata copy];
    if (_view != nil) {
        if ([[mimeType substringToIndex:6] isEqualToString:@"image/"])
            [_view setImage:[UIImage imageWithData:copy]];
    }
    if (_msg != nil) {
        [_msg setImg:copy];
        [_msg setImgType:mimeType];
    }
    if (_btn != nil) {
        if ([[mimeType substringToIndex:6] isEqualToString:@"image/"]) {
            [_btn setImage:[UIImage imageWithData:copy] forState:UIControlStateNormal];
            [_btn setContentMode:UIViewContentModeScaleAspectFit];
            [_btn setHidden:NO];
        }
    }
    if (_navigationItem != nil) {
        UIImage* o = [UIImage imageWithData:copy];
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
