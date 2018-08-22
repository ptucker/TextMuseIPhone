//
//  ChooseSkinView.h
//  TextMuse
//
//  Created by Peter Tucker on 8/18/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseSkinView : UIView<UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate> {
    NSMutableArray* skinNames;
    NSMutableArray* skinIDs;
    NSMutableArray* skinIcons;
    NSMutableArray* skinColors;
    
    NSMutableData* inetdata;
    NSMutableString* xmldata;
    
    UIActivityIndicatorView* activityView;
    UITableView* skins;
}

@property (nonatomic) SEL done;

@end
