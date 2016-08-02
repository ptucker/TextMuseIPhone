//
//  UserInfo.h
//  TextMuse
//
//  Created by Peter Tucker on 7/28/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject {
    int _ExplorerPoints;
    int _SharerPoints;
    int _MusePoints;
}

@property (readwrite) NSString* UserName;
@property (readwrite) NSString* UserEmail;
@property (readwrite) NSString* UserAge;
@property (readwrite) NSString* UserBirthMonth;
@property (readwrite) NSString* UserBirthYear;
@property (readwrite) int ExplorerPoints;
@property (readwrite) int SharerPoints;
@property (readwrite) int MusePoints;

@end
