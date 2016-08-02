//
//  BadgeTreeTableViewCell.m
//  TextMuse
//
//  Created by Peter Tucker on 7/29/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import "BadgeTreeTableViewCell.h"
#import "Settings.h"

@implementation BadgeTreeTableViewCell
@synthesize descLabel;

-(id)initWithFrame:(CGRect) frame forBadge:(BadgeEnum)badgetype {
    self = [super init];
    
    NSString* title;
    NSString* desc;
    UIImage* badge;
    BOOL dimimage = YES;
    int dim;
    switch (badgetype) {
        case Explorer:
            title = [NSString stringWithFormat:@"(%d/10) Explorer Badge", [CurrentUser ExplorerPoints]];
            desc = @"You are great at discovering events and getting out there.\n\t1pt: Open the app daily\n\t1pt: Open an event category\n\t2pts: Remit a deal";
            badge = [UIImage imageNamed:@"bandcamp"];
            dimimage = [CurrentUser ExplorerPoints] < 10;
            break;
        case Sharer:
            title = [NSString stringWithFormat:@"(%d/10) Sharer Badge", [CurrentUser SharerPoints]];
            badge = [UIImage imageNamed:@"bandcamp"];
            desc = @"You are the information source for great things. Your friends rely on you to know what’s happening.\n\t1pt: Text a deal or event to friends\n\t2pts: Create an event";
            dimimage = [CurrentUser SharerPoints] < 10;
            break;
        case Muse:
            title = [NSString stringWithFormat:@"(%d/10) Muse Badge", [CurrentUser MusePoints]];
            badge = [UIImage imageNamed:@"bandcamp"];
            desc = @"You are the social leader. You get the group together and find great things to do.\n\t1pt: Open the app daily\n\t1pt: Open an event category\n\t2pts: Remit a deal";
            dimimage = [CurrentUser MusePoints] < 10;
            break;
        case Master:
            dim = [CurrentUser ExplorerPoints] >= 10 ? 1 : 0;
            dim += [CurrentUser SharerPoints] >= 10 ? 1 : 0;
            dim += [CurrentUser MusePoints] >= 10 ? 1 : 0;
            title = [NSString stringWithFormat:@"(%d/2) %@ Badge", dim, [Skin MasterName]];
            desc = @"You are great at discovering events and getting out there.\n\t2pts: Remit a deal in a group";
            badge = [UIImage imageNamed:@"bandcamp"];
            dimimage = dim < 2;
            break;
    }
    
    badgeView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, frame.size.height-8, frame.size.height-8)];
    [badgeView setImage:badge];
    if (dimimage)
        [badgeView setAlpha:0.40];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.height, 4,
                                                           frame.size.width - frame.size.height,
                                                           frame.size.height-8)];
    [titleLabel setText:title];
    [titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:22]];
    descLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.height, frame.size.height,
                                                          frame.size.width-frame.size.height, 140)];
    [descLabel setNumberOfLines:0];
    [descLabel setText:desc];
    [descLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:16]];
    [descLabel sizeToFit];
    [self addSubview:badgeView];
    [self addSubview:titleLabel];
    [self addSubview:descLabel];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
