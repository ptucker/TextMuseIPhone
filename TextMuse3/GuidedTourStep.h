//
//  GuidedTourStep.h
//  TextMuse
//
//  Created by Peter Tucker on 8/20/18.
//  Copyright © 2018 LaLoosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GuidedTourStep : NSObject

-(id)initWithMessage:(NSString*)msg;
-(id)initWithMessage:(NSString*)msg andImage:(NSString*)img;

@property (readwrite, atomic) NSString* message;
@property (readwrite, atomic) UIImage* image;

@end
