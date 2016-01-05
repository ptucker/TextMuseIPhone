//
//  SqlData.h
//  TextMuse
//
//  Created by Peter Tucker on 1/5/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Message.h"
@interface SqlData : NSObject

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;

-(id)init;
-(void)pinMessage:(Message*)msg;
-(void)unpinMessage:(Message*)msg;
-(NSArray*)getPinnedMessages;

@end
