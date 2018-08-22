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
    NSArray* steps;
    int step;
}

-(void)reset;
-(GuidedTourStep*)getFirstStep;
-(GuidedTourStep*) getNextStep;

@end
