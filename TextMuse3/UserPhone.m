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
    self.number = n; self.label = l;
    
    return self;
}

@end