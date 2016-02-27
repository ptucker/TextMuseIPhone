//
//  Category.h
//  TextMuse
//
//  Created by Peter Tucker on 3/5/15.
//  Copyright (c) 2015 WhitworthCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SponsorInfo.h"

@interface MessageCategory : NSObject

@property (atomic, retain) NSString* name;
@property (atomic) BOOL newCategory;
@property (atomic) BOOL required;
@property (atomic) BOOL chosen;
@property (atomic, retain) SponsorInfo* sponsor;
@property (atomic) BOOL useIcon;
@property (atomic) NSUInteger order;
@property (atomic, retain) NSMutableArray* messages;

-(id)initWithName:(NSString*)n;

@end
