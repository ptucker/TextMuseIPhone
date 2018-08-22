//
//  GuidedTour.m
//  TextMuse
//
//  Created by Peter Tucker on 8/20/18.
//  Copyright © 2018 LaLoosh. All rights reserved.
//

#import "GuidedTour.h"

@implementation GuidedTour

-(id)init {
    self = [super init];
    
    step = 0;
    
    steps = [NSArray arrayWithObjects:
             [[GuidedTourStep alloc] initWithMessage:@"Welcome to the Guided Tour for TextMuse. You'll find a lot of great content here that you'll want to share with friends. When you complete this tour you'll be entered into a drawing.\n\nFirst, choose your version, so you can get the most relevant content."],
             [[GuidedTourStep alloc] initWithMessage:@"Now, check out the great content we already have for you. Scroll through and find something you're interested in and tap on it to see details."],
             [[GuidedTourStep alloc] initWithMessage:@"Great! Now, tap on Text It to share with your friends."],
             [[GuidedTourStep alloc] initWithMessage:@"You're almost there! Pick one or more friends that you'd like to share this content with. Then send the message!"],
             [[GuidedTourStep alloc] initWithMessage:@"You're done! You've been entered in our drawing. Keep coming back to TextMuse to see more great content, and to find out if you've won!"],
             nil];
    
    return self;
}

-(void)reset {
    step = 0;
}

-(GuidedTourStep*)getFirstStep {
    step = 0;
    return [steps objectAtIndex:step];
}

-(GuidedTourStep*)getNextStep {
    if (step+1 >= [steps count])
        return nil;
    return [steps objectAtIndex:(++step)];
}

@end
