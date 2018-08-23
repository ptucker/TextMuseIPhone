//
//  GuidedTour.h
//  TextMuse
//
//  Created by Peter Tucker on 8/20/18.
//  Copyright © 2018 LaLoosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuidedTourStep.h"

@interface GuidedTour : NSObject {
    NSDictionary* _steps;
}

@property (readonly) NSString* Intro;
@property (readonly) NSString* ChooseContent;
@property (readonly) NSString* TextIt;
@property (readonly) NSString* ChooseContact;
@property (readonly) NSString* Done;

-(GuidedTourStep*)getStepForKey:(NSString*)step;
@end
