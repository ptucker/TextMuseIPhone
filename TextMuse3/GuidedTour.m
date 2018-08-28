//
//  GuidedTour.m
//  TextMuse
//
//  Created by Peter Tucker on 8/20/18.
//  Copyright © 2018 LaLoosh. All rights reserved.
//

#import "GuidedTour.h"

@implementation GuidedTour
@synthesize Intro, ChooseContent, TextIt, ChooseContact, Done, Sponsor, Badge;

-(id)init {
    self = [super init];
    
    Intro = @"Intro";
    ChooseContent = @"Content";
    TextIt = @"TextIt";
    ChooseContact = @"Contact";
    Done = @"Done";
    Sponsor = @"Sponsor";
    Badge = @"Badge";
    
    _steps = [NSDictionary dictionaryWithObjectsAndKeys:
              [[GuidedTourStep alloc] initWithMessage:@"Find fun events, great deals, and other stuff you can easily share with friends\n\nComplete this tour and you'll be entered into a drawing for a prize!"], Intro,
              [[GuidedTourStep alloc] initWithMessage:@"Now, see what secrets we already have for you.\n\nScroll down and tap on what you discover to share with a friend... a deal, a happy thought, or something fun to do!" andImage:@"choosecontent"], ChooseContent,
              [[GuidedTourStep alloc] initWithMessage:@"Great. Tap on Text It so you can send this to your friends." andImage:@"textit"], TextIt,
              [[GuidedTourStep alloc] initWithMessage:@"You're almost there! Pick one or more friends that you'd like to share this content with. Then send the message!" andImage:@"students"], ChooseContact,
              [[GuidedTourStep alloc] initWithMessage:@"Done! You're entered in our drawing for a gift certificate at the end of the month. Come back to TextMuse to see more great content, and to find out if you've won!"], Done,
              [[GuidedTourStep alloc] initWithMessage:@"Follow your favorite content sources! Click FOLLOW to get notified when %% adds new content. Content from %% will also appear in the Follows category." andImage:@"follow"], Sponsor,
              [[GuidedTourStep alloc] initWithMessage:@"%% has a better deal for you. Share this with %% people and you'll get a badge that can be redeemed next time you visit %%."], Badge,
              nil];

    return self;
}

-(GuidedTourStep*)getStepForKey:(NSString*)step {
    GuidedTourStep* ret = [_steps objectForKey:step];
    return ret;
}

@end
