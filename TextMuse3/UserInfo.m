//
//  UserInfo.m
//  TextMuse
//
//  Created by Peter Tucker on 7/28/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@implementation UserInfo
@synthesize ExplorerPoints = _ExplorerPoints, SharerPoints = _SharerPoints, MusePoints = _MusePoints;

-(id)init {
    self = [super init];
    
    _ExplorerPoints = -1;
    _SharerPoints = -1;
    _MusePoints = -1;
    
    return self;
}

-(int)ExplorerPoints {
    return _ExplorerPoints;
}

-(void)setExplorerPoints:(int)ep {
    if (ep > 0 && _ExplorerPoints == 0)
        [self showMessage:@"Explorer" withBadge:@"v4-1_Explorer"];
    
    _ExplorerPoints = ep;
}

-(int)SharerPoints {
    return _SharerPoints;
}

-(void)setSharerPoints:(int)sp {
    if (sp > 0 && _SharerPoints == 0)
        [self showMessage:@"Sharer" withBadge:@"v4-1_Sharer"];
    
    _SharerPoints = sp;
}

-(int)MusePoints {
    return _MusePoints;
}

-(void)setMusePoints:(int)mp {
    if (mp > 0 && _MusePoints == 0)
        [self showMessage:@"Muse" withBadge:@"v4-1_TextMuse"];
    
    _MusePoints = mp;
}

-(void)showMessage:(NSString*)msg withBadge:(NSString*)badge {
    msg = [NSString stringWithFormat:@"You got your first %@ points! Track your points by clicking on the Badge button toward your %@ badge!", msg, msg];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"First Points" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [img setContentMode:UIViewContentModeScaleAspectFit];
    [img setImage:[UIImage imageNamed:badge]];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [alert setValue:img forKey:@"accessoryView"];
    }
    else {
        [alert addSubview:img];
    }
    [alert show];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        CGRect frmAlert = [alert frame];
        [img setFrame:CGRectMake(10, frmAlert.size.height-70, 60, 60)];
    }
}

@end
