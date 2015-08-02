//
//  UISuggestionButton.m
//  TextMuse
//
//  Created by Peter Tucker on 8/2/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "UISuggestionButton.h"

@implementation UISuggestionButton
@synthesize message;

-(id)initWithMessage:(Message *)msg {
    self = [super init];
    message = msg;
    
    return self;
}

@end
