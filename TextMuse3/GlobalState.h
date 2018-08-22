//
//  GlobalState.h
//  TextMuse2
//
//  Created by Peter Tucker on 4/18/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataAccess.h"
#import "SqlData.h"
#import "Message.h"
#import "GuidedTour.h"

@interface GlobalState : NSObject

extern DataAccess* Data;
extern NSString* CurrentCategory;
extern long CurrentColorIndex;
extern Message* CurrentMessage;
extern int HighlightedMessageID;
extern NSString* CurrentGroup;
extern SqlData* SqlDb;
extern GuidedTour* Tour;

+(void)init;

@end
