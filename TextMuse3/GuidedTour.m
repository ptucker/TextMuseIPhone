//
//  GuidedTour.m
//  TextMuse
//
//  Created by Peter Tucker on 8/20/18.
//  Copyright © 2018 LaLoosh. All rights reserved.
//

#import "GuidedTour.h"

@implementation GuidedTour
@synthesize Intro, ChooseContent, TextIt, ChooseContact, Done;

-(id)init {
    self = [super init];
    
    Intro = @"Intro";
    ChooseContent = @"Content";
    TextIt = @"TextIt";
    ChooseContact = @"Contact";
    Done = @"Done";
    
    _steps = [NSDictionary dictionaryWithObjectsAndKeys:
              [[GuidedTourStep alloc] initWithMessage:@"Welcome to the Guided Tour for TextMuse. You'll find a lot of great content here that you'll want to share with friends. When you complete this tour you'll be entered into a drawing.\n\nFirst, choose your version, so you can get the most relevant content."], Intro,
              [[GuidedTourStep alloc] initWithMessage:@"Now, check out the great content we already have for you. Scroll through and find something you're interested in and tap on it to see details." andImage:@"choosecontent"], ChooseContent,
              [[GuidedTourStep alloc] initWithMessage:@"Great. Tap on Text It so you can send this to your friends." andImage:@"textit"], TextIt,
              [[GuidedTourStep alloc] initWithMessage:@"You're almost there! Pick one or more friends that you'd like to share this content with. Then send the message!" andImage:@"students"], ChooseContact,
              [[GuidedTourStep alloc] initWithMessage:@"Done! You're entered in our drawing. Come back to TextMuse to see more great content, and to find out if you've won!"], Done,
              nil];

    return self;
}

-(GuidedTourStep*)getStepForKey:(NSString*)step {
    GuidedTourStep* ret = [_steps objectForKey:step];
    return ret;
}

@end
