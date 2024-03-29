//
//  ChooseSkinView.m
//  TextMuse
//
//  Created by Peter Tucker on 8/18/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "ChooseSkinView.h"
#import "SkinInfo.h"
#import "ImageDownloader.h"
#import "DataAccess.h"
#import "GlobalState.h"
#import "Settings.h"
#import "AppDelegate.h"
#import "TextUtil.h"
#import "GuidedTourStepView.h"

@implementation ChooseSkinView

NSString* urlGetSkins = @"https://www.textmuse.com/admin/getskins.php";

-(id) initWithFrame:(CGRect)frame complete:(void (^)(void))completionHandler {
    self = [super initWithFrame:frame];
    
    completion = completionHandler;
    [self setBackgroundColor:[UIColor whiteColor]];
    
    CGRect frmTitle = CGRectMake(10, frame.origin.y, frame.size.width-20, 32);
    UILabel* lblTitle = [[UILabel alloc] initWithFrame:frmTitle];
    [lblTitle setText:@"Choose Version"];
    [lblTitle setFont:[TextUtil GetDefaultFontForSize:20.0]];
    [lblTitle setTextColor:[UIColor blackColor]];
    [self addSubview:lblTitle];
    
    /*
    CGRect frmClose = CGRectMake(frame.size.width-32, frame.origin.y, 32, 32);
    UIButton* btnClose = [[UIButton alloc] initWithFrame:frmClose];
    [btnClose setTitle:@"X" forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnClose];
    */
    
    CGRect frmTable = frame;
    frmTable.origin.y += 32;
    frmTable.size.height -= 32;
    skins = [[UITableView alloc] initWithFrame:frmTable];
    [self addSubview:skins];
    [skins setDelegate:self];
    [skins setDataSource:self];
    
    inetdata = [[NSMutableData alloc] init];
    NSString* getskins = urlGetSkins;
#ifdef OODLES
    getskins = [NSString stringWithFormat:@"%@?edition=91", urlGetSkins];
#endif
#ifdef NRCC
    getskins = [NSString stringWithFormat:@"%@?edition=115", urlGetSkins];
#endif
    NSURL* url = [NSURL URLWithString:getskins];
    NSURLRequest* req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    if (activityView == nil)
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
    [activityView setHidesWhenStopped:YES];
    [activityView startAnimating];
    [self addSubview:activityView];
    
    if (Tour != nil) {
        GuidedTourStepView* gv = [[GuidedTourStepView alloc] initWithStep:[Tour getStepForKey:[Tour Intro]] forFrame:[self frame]];
        [self addSubview:gv];
        [self bringSubviewToFront:gv];
    }

    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:self
                                                    startImmediately:YES];

    return self;
}

-(void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [inetdata appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

-(void)connectionDidFinishLoading:(NSURLConnection*) connection {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:inetdata];
    [parser setDelegate:self];
    [parser parse];
    
    [activityView stopAnimating];
    [activityView removeFromSuperview];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    long c = 0;
    if (skinNames != nil)
        c = [skinNames count];

    return c;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"skin"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] init];
    
    UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 4, 36, 36)];
    [img setContentMode:UIViewContentModeScaleAspectFit];
    NSString* iconurl = [skinIcons objectAtIndex:[indexPath row]];
    if ([iconurl hasPrefix:@"http"]) {
        ImageDownloader* loader = [[ImageDownloader alloc] initWithUrl:iconurl
                                                            forImgView:img
                                                      chooseBackground:skinColors];
        [loader load];
    }
    else
        [img setImage:[UIImage imageNamed:iconurl]];
    [cell addSubview:img];
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(70, 4, [self frame].size.width-74, 40)];
    [lbl setFont:[TextUtil GetDefaultFontForSize:24]];
    [lbl setText:[skinNames objectAtIndex:[indexPath row]]];
    [lbl setTextColor:[SkinInfo createColor:[skinColors objectAtIndex:[indexPath row]]]];
    [cell addSubview:lbl];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    long skinid = [[skinIDs objectAtIndex:[indexPath row]] integerValue];
    if (skinid != -1) {
        if (Skin == nil)
            Skin = [[SkinInfo alloc] init];
        [Skin setSkinID:skinid];
    }
    else {
        Skin = nil;
        [Settings ClearSkinData];
    }
    [Data reloadData];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate registerRemoteNotificationWithAzure];

    if (Tour != nil) {
        GuidedTourStepView* gv = [[GuidedTourStepView alloc] initWithStep:[Tour getStepForKey:[Tour ChooseContent]] forFrame:[self frame]];
        [[self superview] addSubview:gv];
        [[self superview] bringSubviewToFront:gv];
    }

    [self removeFromSuperview];
    if (completion)
        completion();
}


-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Error parsing skins");
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (skinNames == nil) {
        skinNames = [[NSMutableArray alloc] init];
        skinIcons = [[NSMutableArray alloc] init];
        skinIDs = [[NSMutableArray alloc] init];
        skinColors = [[NSMutableArray alloc] init];
#ifdef UNIVERSITY
        /*
        [skinNames addObject:@"Main"];
        [skinIcons addObject:@"TransparentButterfly.png"];
        [skinIDs addObject:@"-1"];
        [skinColors addObject:@"000000"];
         */
#endif
    }
    
    if ([elementName isEqualToString:@"s"]) {
        xmldata = [[NSMutableString alloc] init];
        
        [skinIDs addObject:[attributeDict objectForKey:@"id"]];
        [skinIcons addObject:[attributeDict objectForKey:@"icon"]];
        [skinColors addObject:[attributeDict objectForKey:@"color"]];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [xmldata appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"s"])
        [skinNames addObject:xmldata];
    else if ([elementName isEqualToString:@"ss"])
        [skins reloadData];
}

@end

