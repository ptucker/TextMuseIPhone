//
//  SkinInfo.h
//  TextMuse
//
//  Created by Peter Tucker on 8/17/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SkinInfo : NSObject <NSCoding> {
    UIColor* _color1;
    UIColor* _color2;
    UIColor* _color3;
}

@property long SkinID;
@property NSString* SkinName;
@property NSString* MasterName;
@property NSMutableArray* LaunchImageURL;
@property NSString* Color1;
@property NSString* Color2;
@property NSString* Color3;
@property NSString* MainWindowTitle;
@property NSString* IconButtonURL;
@property NSString* HomeURL;

+(UIColor*)createColor:(NSString*)color;

-(UIColor*) createColor1;
-(UIColor*) createColor2;
-(UIColor*) createColor3;
-(UIColor*) createTextColor1;
-(UIColor*) createTextColor2;
-(UIColor*) createTextColor3;

-(UIColor*) getDarkestColor;

@end
