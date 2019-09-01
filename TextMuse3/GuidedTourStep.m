//
//  GuidedTourStep.m
//  TextMuse
//
//  Created by Peter Tucker on 8/20/18.
//  Copyright © 2018 LaLoosh. All rights reserved.
//

#import "GuidedTourStep.h"

@implementation GuidedTourStep

-(id)initWithMessage:(NSString *)msg {
    self = [super init];

    return [self initWithMessage:msg andImage:@"banner2.png"];
}

-(id)initWithMessage:(NSString*)msg andImage:(NSString*)img {
    self = [super init];
    
    [self setMessage:msg];
    if (img != nil)
        [self setImage:[UIImage imageNamed:img]];

    return self;
}

@end
