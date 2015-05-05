//
//  MemberTableData.h
//  TextMuse3
//
//  Created by Peter Tucker on 4/30/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Settings.h"
#import "GlobalState.h"
#import "DataAccess.h"

@interface MemberTableData : NSObject<UITableViewDataSource, UITableViewDelegate> {
    NSArray* contactsSorted;
}

@property NSMutableArray* adds;
@property NSMutableArray* removes;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
