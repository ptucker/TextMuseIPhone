//
//  UserPhone.m
//  TextMuse
//
//  Created by Peter Tucker on 2/11/15.
//  Copyright (c) 2015 WhitworthCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserPhone.h"

@implementation UserPhone
@synthesize number, label;

-(id)initWithNumber:(NSString *)n Label:(NSString *)l {
    self.number = n;
    
    //Remove decorations from label (e.g. _$!<Mobile>!$_)
    NSArray* l1 = [l componentsSeparatedByString:@"<"];
    if ([l1 count] > 1)
        l1 = [[l1 objectAtIndex:1] componentsSeparatedByString:@">"];
    if ([l1 count] > 0)
        self.label = [[l1 objectAtIndex:0] lowercaseString];
    else
        self.label = [l lowercaseString];
    
    return self;
}

@end
