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
int HighlightedMessageID;
int HighlightedCategoryID = -1;
NSString* CurrentGroup;
SqlData* SqlDb;
GuidedTour* Tour;
long AddEvent = 1;
long AddPrayer = 2;
long AddContent;

@implementation GlobalState

+(void)init {
    SqlDb = [[SqlData alloc] init];
    Data = [[DataAccess alloc] init];
    CurrentCategory = @"Trending";
    CurrentColorIndex = 0;
    HighlightedMessageID = 0;
    AddContent = AddPrayer;
}

@end
