//
//  Message.m
//  FriendlyNotes
//
//  Created by Peter Tucker on 6/7/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import "Message.h"
#import "Settings.h"
#import "YTPlayerView.h"
#import "SuccessParser.h"
#import "TextUtil.h"

YTPlayerView* globalYTPlayer = nil;
NSString* urlNoteSeeIt = @"https://www.textmuse.com/admin/noteseeit.php";
NSString* urlPrayFor = @"https://www.textmuse.com/admin/praying.php";

@implementation Message
@synthesize msgId, order, newMsg, version, loader, assetURL, img, imgType, msgUrl, category, text, mediaUrl, url, eventLocation, eventDate, eventToggle, sponsorID, sponsorName, sponsorLogo, following, liked, likeCount, pinned, badge, discoverPoints, sharePoints, goPoints, phoneno, address, textno;

-(id)initWithId:(int)i message:(NSString *)m forCategory:(NSString*)c isNew:(BOOL)n {
    self = [super init];
    
    //msg = m;
    msgId = i;
    newMsg = n;
    category = c;
    imgLock = [[NSObject alloc] init];
    [self setQuicksend:NO];
    
    NSArray* parts = [Message FindUrlInString:m];
    if (parts != nil) {
        msgUrl = [parts objectAtIndex:0];
        loader = [[ImageDownloader alloc] initWithUrl:[parts objectAtIndex:0]
                                           forMessage:self];
    }
    
    return self;
}

-(id)initWithId:(int)i text:(NSString *)t mediaUrl:(NSString*)murl url:(NSString*)u
        forCategory:(NSString*)c isNew:(BOOL)n {
    self = [super init];
    
    //msg = t;
    text = t;
    mediaUrl = murl;
    url = u;
    msgId = i;
    newMsg = n;
    category = c;
    imgLock = [[NSObject alloc] init];
    [self setQuicksend:NO];
    [self setAddress:@"11605 N. Ashley Lane, Spokane, WA 99218"];

    if (mediaUrl != nil) {
        loader = [[ImageDownloader alloc] initWithUrl:mediaUrl forMessage:self];
    }
    
    return self;
}

-(id)initFromStorage:(NSString *)stored {
    self = [super init];
    
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
    imgLock = [[NSObject alloc] init];
    [self setQuicksend:NO];

    return self;
}

-(id)initFromUserPhoto:(ALAsset *)a {
    self = [super init];
    msgId = -2;
    newMsg = NO;
    category = NSLocalizedString(@"Your Photos Title", nil);
    mediaUrl = @"userphoto://";
    assetURL = [a valueForProperty:ALAssetPropertyAssetURL];
    imgLock = [[NSObject alloc] init];
    [self setQuicksend:NO];

    return self;
}

-(id)initFromUserText:(NSString *)msg atIndex:(int)i {
    self = [super init];
    msgId = -3;
    newMsg = NO;
    yourtextIndex = i;
    category = NSLocalizedString(@"Your Messages Title", nil);
    mediaUrl = @"usertext://";
    text = msg;
    imgLock = [[NSObject alloc] init];
    [self setQuicksend:NO];

    return self;
}

-(NSData*)img {
    @synchronized(imgLock) {
        if (img == nil && loader != nil) {
            [loader load];
        }
    }
    return img;
}

-(void)setImg:(NSData *)imgNew {
    @synchronized(imgLock) {
        img = imgNew;
    }
}

-(BOOL)isImgNull {
    return (img == nil);
}

-(void)loadUserImage {
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:assetURL resultBlock:^(ALAsset* asset) {
        CGImageRef ir = [[asset defaultRepresentation] fullScreenImage];
        self->img = UIImagePNGRepresentation([UIImage imageWithCGImage:ir]);
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

-(BOOL)isPrayer {
    return [[[self category] lowercaseString] containsString:@"prayer"];
}

-(NSString*)getFullMessage {
    NSString* txt = [self text];
    if ([[self eventDate] length] > 0)
        txt = [NSString stringWithFormat:@"%@\nWhen: %@", txt, [self eventDate]];
    if ([[self eventLocation] length] > 0)
        txt = [NSString stringWithFormat:@"%@\nWhere: %@", txt, [self eventLocation]];
    
    return txt;
}

-(void)action:(id)sender {
    if (mediaUrl != nil) {
        //Check if this is a youtube URL
        NSString* ytid = [ImageDownloader GetYoutubeId:mediaUrl];
        //NSString* appUrl = mediaUrl;
        //if (ytid != nil)
        //    appUrl = [NSString stringWithFormat:@"youtube://%@", ytid];
        
        if (ytid != nil) {
            UIButton* btn = (UIButton*)sender;
            CGRect ytframe = CGRectMake(0, 0, [btn frame].size.width, [btn frame].size.height);
            if (globalYTPlayer != nil)
                [globalYTPlayer removeFromSuperview];
            else
                globalYTPlayer = [[YTPlayerView alloc] init];
            [globalYTPlayer setFrame:ytframe];
            [btn addSubview:globalYTPlayer];
            
            NSDictionary *playerVars = @{
                                         @"playsinline" : @1,
                                         @"autoplay" : @1,
                                         };
            [globalYTPlayer loadWithVideoId:ytid playerVars:playerVars];
        }
    }
}

-(void)closeImage:(id)sender {
    UIView* v = (UIView*)sender;
    UIView* vImg = [v viewWithTag:100];
    CGRect endFrame = CGRectMake([v frame].origin.x + [v frame].size.width/2,
                                 [v frame].origin.y + [v frame].size.height/2, 0, 0);
    [UIView animateWithDuration:0.5 animations:^{
        [v setFrame:endFrame];
        [vImg setFrame:CGRectMake(0, 0, 0, 0)];
    } completion: ^(BOOL f) {
        [v removeFromSuperview];
    }];
}

-(void)follow:(id)sender {
    if (url != nil) {
        if ([[url lowercaseString] hasPrefix:@"https://www.textmuse.com"] && [url containsString:@"%appid%"])
            url = [url stringByReplacingOccurrencesOfString:@"%appid%" withString:AppID];
        
        UIButton* btn = (UIButton*)sender;
        UIView* parent = [btn superview];
        while ([parent superview] != nil)
            parent = [parent superview];

        [self showWebViewInParent:parent withUrl:url withAnimation:YES];
    }
}

-(void)showMap:(id)sender {
    if ([self address] != nil && [[self address] length] > 0) {
        UIButton* btn = (UIButton*)sender;
        UIView* parent = [btn superview];
        while ([parent superview] != nil)
            parent = [parent superview];
        
        //https://developers.google.com/maps/documentation/urls/guide
        //https://www.google.com/maps/search/?api=1&parameters
        NSString* url = [NSString stringWithFormat:@"https://www.google.com/maps/search/?api=1&query=%@",
                         [[self address] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        [self showWebViewInParent:parent withUrl:url withAnimation:YES];
    }
}

-(void)showWebViewInParent:(UIView*) parent withUrl:(NSString*)u withAnimation:(BOOL)close {
    CGRect frmView = CGRectMake(0, [parent frame].size.height, [parent frame].size.width, [parent frame].size.height);
    UIView* viewWeb = [[UIView alloc] initWithFrame:frmView];
    [viewWeb setBackgroundColor:[UIColor whiteColor]];
    CGFloat closeHeight = close ? 50 : 0;
    if (close) {
        if ([self text] != nil && [[self text] length] > 0) {
            CGRect frmTitle = CGRectMake(20, 20, frmView.size.width - 60, 30);
            UILabel* lblTitle = [[UILabel alloc] initWithFrame:frmTitle];
            [lblTitle setFont:[TextUtil GetDefaultFontForSize:18.0]];
            [lblTitle setTextColor:[UIColor blackColor]];
            [lblTitle setText:[self text]];
            [viewWeb addSubview:lblTitle];
        }
        
        CGRect frmButton = CGRectMake(frmView.size.width - 40, 20, 30, 30);
        UIButton* btnClose = [[UIButton alloc] initWithFrame:frmButton];
        [btnClose setTitle:@"X" forState:UIControlStateNormal];
        [[btnClose titleLabel] setFont:[TextUtil GetDefaultFontForSize:36.0]];
        [btnClose setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnClose addTarget:self action:@selector(closeWeb:) forControlEvents:UIControlEventTouchUpInside];
        [viewWeb addSubview:btnClose];
    }

    CGRect frmWeb = CGRectMake(0, closeHeight, frmView.size.width, frmView.size.height-closeHeight);
    if (web == nil) {
        web = [[UIWebView alloc] init];
        [web setDelegate:self];
    }
    [web setFrame:frmWeb];
    [viewWeb addSubview:web];
    [parent addSubview:viewWeb];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:u]];
    [web loadRequest:req];
    
    [self sendSeeItRequest];
    
    if (close) {
        CGRect endFrame = frmView;
        endFrame.origin.y = 0;
        [UIView animateWithDuration:0.5 animations:^{
            [viewWeb setFrame:endFrame];
        } completion: ^(BOOL f) {
        }];
    }
}

-(void)sendSeeItRequest {
    NSURL* urlS = [NSURL URLWithString:urlNoteSeeIt];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:urlS
                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                   timeoutInterval:30];
    inetdata = [[NSMutableData alloc] init];
    [req setHTTPMethod:@"POST"];
    NSString* post = [NSString stringWithFormat:@"app=%@&note=%d", AppID, msgId];
    [req setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:self
                                                    startImmediately:YES];
}

-(void)submitPrayFor {
    NSString* url = [NSString stringWithFormat:@"%@?app=%@&prayer=%d", urlPrayFor, AppID, [self msgId]];
    
    NSMutableURLRequest* req = [NSMutableURLRequest
                                requestWithURL:[NSURL URLWithString:url]
                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                timeoutInterval:30];
    
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:nil
                                                    startImmediately:YES];
    
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Prayed for"
                                                    message:@"Thank you for your prayer"
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    //Append the newly arrived data to whatever we’ve seen so far
    [inetdata appendData:data];
}

-(void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error {
    NSLog([error localizedDescription]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)_connection{
    SuccessParser* sp = [[SuccessParser alloc] initWithXml:inetdata];
    
    [CurrentUser setExplorerPoints:[sp ExplorerPoints]];
    [CurrentUser setSharerPoints:[sp SharerPoints]];
    [CurrentUser setMusePoints:[sp MusePoints]];
    NSString* data = [[NSString alloc] initWithData:inetdata encoding:NSUTF8StringEncoding];
    NSLog(data);
}

-(void)closeWeb:(id)sender {
    UIButton* btn = (UIButton*)sender;
    UIView* v = [btn superview];
    CGRect endFrame = [v frame];
    endFrame.origin.y = [v frame].size.height;
    [UIView animateWithDuration:0.5 animations:^{
        [v setFrame:endFrame];
    } completion: ^(BOOL f) {
        if (f) {
            [self->web removeFromSuperview];
            [self->web loadHTMLString:@"" baseURL:nil];
            [v removeFromSuperview];
        }
    }];
}

-(void)webViewDidStartLoad:(UIWebView*)webView {
    if (activityView == nil)
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setCenter:CGPointMake([webView frame].size.width/2, [webView frame].size.height/2)];
    [activityView setHidesWhenStopped:YES];
    [activityView startAnimating];
    [webView addSubview:activityView];
}

-(void)webViewDidFinishLoad:(UIWebView*)webView {
    [activityView stopAnimating];
    [activityView removeFromSuperview];
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
