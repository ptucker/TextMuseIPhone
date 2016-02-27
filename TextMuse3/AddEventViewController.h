//
//  AddEventViewController.h
//  TextMuse
//
//  Created by Peter Tucker on 2/26/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddEventViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    UITapGestureRecognizer* _singleTapRecognizer;
    NSMutableData* inetdata;
    
    IBOutlet UITextView* tvDesc;
    IBOutlet UITextField* txtLocation;
    IBOutlet UITextField* txtDate;
    IBOutlet UITextField* txtEmail;
    IBOutlet UIButton* btnSubmit;
}

@property (nonatomic, strong, readonly) UITapGestureRecognizer* singleTapRecognizer;

-(IBAction)submitEvent:(id)sender;

@end
