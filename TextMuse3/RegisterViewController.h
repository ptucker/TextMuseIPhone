//
//  RegisterViewController.h
//  TextMuse3
//
//  Created by Peter Tucker on 5/16/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BirthPickerView.h"

@interface RegisterViewController : UIViewController {
    IBOutlet UITextField* txtName;
    IBOutlet UITextField* txtEmail;
    IBOutlet UILabel* lblBirth;
    IBOutlet UIButton* btnPrivacy;
    
    BirthPickerView* birthPicker;
}

@end
