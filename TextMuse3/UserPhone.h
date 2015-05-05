//
//  UserPhone.h
//  FriendlyNotes
//
//  Created by Peter Tucker on 2/10/2015.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPhone : NSObject  {
    NSString* number;
    NSString* label;
}

@property (atomic, copy) NSString* number;
@property (atomic, copy) NSString* label;

-(id)initWithNumber:(NSString*)n Label:(NSString*)l;
@end
