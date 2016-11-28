//
//  EmailValidator.h
//  TextMuse
//
//  Created by Peter Tucker on 11/27/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmailValidator : NSObject

+(BOOL) IsValidEmail:(NSString *)emailString Strict:(BOOL)strictFilter;

@end
