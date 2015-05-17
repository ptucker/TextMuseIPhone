//
//  ContactUsViewController.h
//  TextMuse3
//
//  Created by Peter Tucker on 5/16/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactUsViewController : UIViewController <UITextViewDelegate>

@property (retain) IBOutlet UITextView* feedback;
@property (retain) IBOutlet UITextField* name;
@property (retain) IBOutlet UITextField* email;

@end
