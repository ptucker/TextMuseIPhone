//
//  UserContact.m
//  FriendlyNotes
//
//  Created by Peter Tucker on 4/26/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import "UserContact.h"
#import "UserPhone.h"
#import "Settings.h"

@implementation UserContact
@synthesize firstName, lastName, phones, photo, numberToUse;

-(id)initWithFName:(NSString *)f LName:(NSString *)l Phones:(NSArray *)ps Photo:(NSData*)ph {
    self.firstName = f; self.lastName = l; self.phones = ps; self.photo = ph;

    int ilabel = 6;
    for (int i=0; i<[ps count]; i++) {
        UserPhone* up = [ps objectAtIndex:i];
        
        if ([[up label] containsString:@"iphone"]) {
            numberToUse = [up number];
            ilabel = 1;
        }
        if ([[up label] containsString:@"mobile"] && (numberToUse == nil || ilabel > 2)) {
            numberToUse = [up number];
            ilabel = 2;
        }
        if ([[up label] containsString:@"main"] && (numberToUse == nil || ilabel > 3)) {
            numberToUse = [up number];
            ilabel = 3;
        }
        if ([[up label] containsString:@"home"] && (numberToUse == nil || ilabel > 4)) {
            numberToUse = [up number];
            ilabel = 4;
        }
        if ([[up label] containsString:@"work"] && (numberToUse == nil || ilabel > 5)) {
            numberToUse = [up number];
            ilabel = 5;
        }
    }
    if (ilabel > 5 && [ps count] > 0)
        numberToUse = [[ps objectAtIndex:0] number];
    
    return ((numberToUse != nil) ? self : nil);
}

-(id)initWithGroupName:(NSString*)group {
    self.lastName = group;
    
    return self;
}

-(NSString*)description {
    if (firstName == nil || [firstName length] == 0)
        return lastName;
    else if (lastName == nil || [lastName length] == 0)
        return firstName;
    else
        return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
}

-(NSComparisonResult)compareName:(id)obj {
    UserContact* u = (UserContact*)obj;
    
    NSString* person1 = [self getSortValue];
    NSString* person2 = [u getSortValue];

    return [person1 caseInsensitiveCompare:person2];
}

-(NSString*)getSortValue {
    NSString* lname = lastName == nil ? @"" : lastName;
    NSString* fname = firstName == nil ? @"" : firstName;
    NSString* n = SortLastName ? [NSString stringWithFormat:@"%@%@", lname, fname] :
                                    [NSString stringWithFormat:@"%@%@", fname, lname];
    return n;
}

-(NSString*)getPhone {
    return numberToUse;
}

-(void)setPhoneToUse:(NSString*)p {
    numberToUse = p;
}

-(BOOL) hasPhone:(id)phone {
    BOOL ret = false;
    NSString* pn = [phone isKindOfClass:[UserPhone class]] ? [phone number] : (NSString*)phone;
    for (int i=0; !ret && i<[phones count] && !ret; i++)
        ret = [[[phones objectAtIndex:i] number] isEqualToString:pn];
    
    return ret;
}

-(BOOL)isEqual:(id)object  {
    UserContact* uc = (UserContact*)object;
    BOOL ret = false;
    if (uc != nil) {
        ret = [firstName isEqual:[uc firstName]] && [lastName isEqual:[uc lastName]];
        
        for (int i=0; i<[phones count] && ret; i++)
            ret = [[[phones objectAtIndex:i] number] isEqualToString:[[[uc phones] objectAtIndex:i] number]];
    }
    return ret;
}

@end
