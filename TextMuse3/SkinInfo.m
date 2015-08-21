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
 @property NSString* LaunchImageURL;
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

-(UIColor*)createColor1 {
    return [SkinInfo createColor:[self Color1]];
}

-(UIColor*)createColor2 {
    return [SkinInfo createColor:[self Color2]];
}

-(UIColor*)createColor3 {
    return [SkinInfo createColor:[self Color3]];
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
