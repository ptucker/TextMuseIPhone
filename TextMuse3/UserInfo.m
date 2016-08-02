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
        [self showMessage:@"Explorer"];
    
    _ExplorerPoints = ep;
}

-(int)SharerPoints {
    return _SharerPoints;
}

-(void)setSharerPoints:(int)sp {
    if (sp > 0 && _SharerPoints == 0)
        [self showMessage:@"Sharer"];
    
    _SharerPoints = sp;
}

-(int)MusePoints {
    return _MusePoints;
}

-(void)setMusePoints:(int)mp {
    if (mp > 0 && _MusePoints == 0)
        [self showMessage:@"Muse"];
    
    _MusePoints = mp;
}

-(void)showMessage:(NSString*)msg {
    msg = [NSString stringWithFormat:@"You got your first %@ points! Track your points by clicking on the Badge button toward your %@ badge!", msg, msg];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"First Points" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
