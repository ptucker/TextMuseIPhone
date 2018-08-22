//
//  BadgeTreeTableViewCell.m
//  TextMuse
//
//  Created by Peter Tucker on 7/29/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import "BadgeTreeTableViewCell.h"
#import "Settings.h"
#import "TextUtil.h"

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
            desc = @"You are great at discovering cool activities on or around campus\n\t1pt: Open the app daily\n\t1pt: Open a deal or event\n\t2pts: Remit an activity";
            badge = [UIImage imageNamed:@"v4-1_Explorer"];
            dimimage = [CurrentUser ExplorerPoints] < 10;
            break;
        case Sharer:
            title = [NSString stringWithFormat:@"(%d/10) Sharer Badge", [CurrentUser SharerPoints]];
            badge = [UIImage imageNamed:@"v4-1_Sharer"];
            desc = @"You are the go-to person for an awesome social life. Your friends rely on you to know what's goin' on\n\t1pt: Text a deal or event to friends\n\t2pts: Create and share an event";
            dimimage = [CurrentUser SharerPoints] < 10;
            break;
        case Muse:
            title = [NSString stringWithFormat:@"(%d/10) Muse Badge", [CurrentUser MusePoints]];
            badge = [UIImage imageNamed:@"v4-1_TextMuse"];
            desc = @"You are the social leader. You get the group together to have a rockin' good time.\n\t2pts: Remit an activity as a group";
            dimimage = [CurrentUser MusePoints] < 10;
            break;
        case Master:
            dim = [CurrentUser ExplorerPoints] >= 10 ? 1 : 0;
            dim += [CurrentUser SharerPoints] >= 10 ? 1 : 0;
            dim += [CurrentUser MusePoints] >= 10 ? 1 : 0;
            title = [NSString stringWithFormat:@"%@ Badge", [Skin MasterName]];
            desc = @"You've achieved \"Master\" status at discovering cool activities on or around campus\n\tReceive 25 or more points.\n\tHave two or more badges.";
            badge = [UIImage imageWithData:[Skin getBadgeImage]];
            dimimage = dim < 2 ||
                ([CurrentUser ExplorerPoints] + [CurrentUser SharerPoints] + [CurrentUser MusePoints] < 25);
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
    [titleLabel setFont:[TextUtil GetDefaultFontForSize:22.0]];
    descLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.height, frame.size.height,
                                                          frame.size.width-frame.size.height, 140)];
    [descLabel setNumberOfLines:0];
    [descLabel setText:desc];
    [descLabel setFont:[TextUtil GetDefaultFontForSize:16.0]];
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
