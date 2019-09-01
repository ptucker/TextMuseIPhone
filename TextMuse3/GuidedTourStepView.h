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

@interface GuidedTourStepView : UIView {
    void (^completion)(void);
}

-(UIView*) initWithStep:(GuidedTourStep*)step forFrame:(CGRect)frame;
-(UIView*) initWithStep:(GuidedTourStep*)step
               forFrame:(CGRect)frame
      completionHandler:(void(^)(void)) completionHandler;
-(UIView*) initWithStep:(GuidedTourStep*)step
               forFrame:(CGRect)frame
             withParams:(NSArray*)params;

-(UIView*) initWithStep:(GuidedTourStep*)step
               forFrame:(CGRect)frame
             withParams:(NSArray*)params
      completionHandler:(void(^)(void)) completionHandler;

@end
