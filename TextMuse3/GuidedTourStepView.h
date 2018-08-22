//
//  GuidedTourStepView.h
//  TextMuse
//
//  Created by Peter Tucker on 8/20/18.
//  Copyright © 2018 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuidedTour.h"
#import "GuidedTourStep.h"

@interface GuidedTourStepView : UIView

-(UIView*) initWithStep:(GuidedTourStep*)step forFrame:(CGRect)frame;

@end
