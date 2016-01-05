//
//  GlobalState.m
//  TextMuse2
//
//  Created by Peter Tucker on 4/18/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "GlobalState.h"

DataAccess* Data;
NSString* CurrentCategory;
long CurrentColorIndex;
Message* CurrentMessage;
NSString* CurrentGroup;
SqlData* SqlDb;

@implementation GlobalState

+(void)init {
    SqlDb = [[SqlData alloc] init];
    Data = [[DataAccess alloc] init];
    CurrentCategory = @"Trending";
    CurrentColorIndex = 0;
}

@end
