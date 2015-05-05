//
//  UserContact.h
//  FriendlyNotes
//
//  Created by Peter Tucker on 4/26/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserContact : NSObject  {
    NSString* firstName;
    NSString* lastName;
    //NSString* phone;
    NSArray* phones;
    NSString* numberToUse;
    NSData* photo;
}

@property (atomic, copy) NSString* firstName;
@property (atomic, copy) NSString* lastName;
@property (atomic, copy) NSArray* phones;
@property (atomic, copy) NSData* photo;
@property (atomic, copy) NSString* numberToUse;

-(id)initWithFName:(NSString*)f LName:(NSString*)l Phones:(NSArray*)ps Photo:(NSData*) ph;
-(id)initWithGroupName:(NSString*)group;
-(NSString*) description;
-(NSComparisonResult)compareName:(id)obj;
-(NSString*)getSortValue;
-(NSString*)getPhone;
-(void)setPhoneToUse:(NSString*)p;
-(BOOL) hasPhone:(NSString*)phone;
-(BOOL) isEqual:(id)object;
@end
