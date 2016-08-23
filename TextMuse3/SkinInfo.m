//
//  SkinInfo.m
//  TextMuse
//
//  Created by Peter Tucker on 8/17/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "SkinInfo.h"

@implementation SkinInfo

/*
 @property long SkinID;
 @property NSString* SkinName;
 @property NSArray* LaunchImageURL;
 @property NSString* Color1;
 @property NSString* Color2;
 @property NSString* Color3;
 @property NSString* MainWindowTitle;
 @property NSString* IconButtonURL;
 @property NSString* HomeURL;
 */

- (id)initWithCoder:(NSCoder *)decoder {
    
    
    if (self = [super init]) {
        [self setSkinID:[[decoder decodeObjectForKey:@"id"] integerValue]];
        [self setSkinName:[decoder decodeObjectForKey:@"name"]];
        [self setLaunchImageURL:[decoder decodeObjectForKey:@"launch"]];
        [self setColor1:[decoder decodeObjectForKey:@"c1"]];
        [self setColor2:[decoder decodeObjectForKey:@"c2"]];
        [self setColor3:[decoder decodeObjectForKey:@"c3"]];
        [self setMainWindowTitle:[decoder decodeObjectForKey:@"main"]];
        [self setIconButtonURL:[decoder decodeObjectForKey:@"icon"]];
        [self setHomeURL:[decoder decodeObjectForKey:@"home"]];
        [self setMasterName:[decoder decodeObjectForKey:@"master"]];
        [self setMasterBadgeURL:[decoder decodeObjectForKey:@"masterbadge"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[NSString stringWithFormat:@"%ld", [self SkinID]] forKey:@"id"];
    [encoder encodeObject:[self SkinName] forKey:@"name"];
    [encoder encodeObject:[self  LaunchImageURL] forKey:@"launch"];
    [encoder encodeObject:[self Color1] forKey:@"c1"];
    [encoder encodeObject:[self Color2] forKey:@"c2"];
    [encoder encodeObject:[self Color3] forKey:@"c3"];
    [encoder encodeObject:[self MainWindowTitle] forKey:@"main"];
    [encoder encodeObject:[self IconButtonURL] forKey:@"icon"];
    [encoder encodeObject:[self HomeURL] forKey:@"home"];
    [encoder encodeObject:[self MasterName] forKey:@"master"];
    [encoder encodeObject:[self MasterBadgeURL] forKey:@"masterbadge"];
}

+(long) getHexDigit:(unichar) c {
    long ret = 0;
    if (c >= '0' && c <= '9')
        ret = (long)(c - '0');
    else if (c >= 'a' && c <= 'f')
        ret = (long)(c - 'a') + 10;
    
    return ret;
}

+(long) getHexValue:(NSString*)h {
    long tens = 16 * [self getHexDigit:[h characterAtIndex:0]];
    long ones = [self getHexDigit:[h characterAtIndex:1]];
    return tens + ones;
}

+(UIColor*)createColor:(NSString*)color {
    long r = [self getHexValue:[color substringWithRange:NSMakeRange(0, 2)]];
    long g = [self getHexValue:[color substringWithRange:NSMakeRange(2, 2)]];
    long b = [self getHexValue:[color substringWithRange:NSMakeRange(4, 2)]];
    
    return [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:1.0];
}

-(NSString*)MasterBadgeURL {
    return masterBadgeUrl;
}

-(void)setMasterBadgeURL:(NSString *)MasterBadgeURL {
    if (MasterBadgeURL != nil) {
        masterBadgeUrl = MasterBadgeURL;
        loader = [[ImageDownloader alloc] initWithUrl:masterBadgeUrl];
        [loader load];
    }
}

-(NSData*)getBadgeImage {
    return [loader inetdata];
}

-(UIColor*)getDarkestColor {
    UIColor* ret = [self createColor1];
    CGFloat r, g, b;
    [[self createColor1] getRed:&r green:&g blue:&b alpha:nil];
    CGFloat min = (r + g + b) / 3;
    
    [[self createColor2] getRed:&r green:&g blue:&b alpha:nil];
    if ((r+g+b)/3 < min) {
        min = (r+g+b)/3;
        ret = [self createColor2];
    }
    [[self createColor3] getRed:&r green:&g blue:&b alpha:nil];
    if ((r+g+b)/3 < min) {
        min = (r+g+b)/3;
        ret = [self createColor3];
    }
    
    return ret;
}

-(UIColor*)createColor1 {
    if (_color1 == nil)
        _color1 = [SkinInfo createColor:[self Color1]];
    return _color1;
}

-(UIColor*)createColor2 {
    if (_color2 == nil)
        _color2 = [SkinInfo createColor:[self Color2]];
    return _color2;
}

-(UIColor*)createColor3 {
    if (_color3 == nil)
        _color3 = [SkinInfo createColor:[self Color3]];
    return _color3;
}

-(UIColor*)createTextColor:(NSString*)color {
    long r = [SkinInfo getHexValue:[color substringWithRange:NSMakeRange(0, 2)]];
    long g = [SkinInfo getHexValue:[color substringWithRange:NSMakeRange(2, 2)]];
    long b = [SkinInfo getHexValue:[color substringWithRange:NSMakeRange(4, 2)]];
    
    double avg = (r+g+b) / 3.0;
    
    return (avg > 127) ? [UIColor blackColor] : [UIColor whiteColor];
}

-(UIColor*)createTextColor1 {
    return [self createTextColor:[self Color1]];
}

-(UIColor*)createTextColor2 {
    return [self createTextColor:[self Color2]];
}

-(UIColor*)createTextColor3 {
    return [self createTextColor:[self Color3]];
}

@end
