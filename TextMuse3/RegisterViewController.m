//
//  RegisterViewController.m
//  TextMuse3
//
//  Created by Peter Tucker on 5/16/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import "RegisterViewController.h"
#import "Settings.h"
#import "EmailValidator.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController
@synthesize singleTapRecognizer = _singleTapRecognizer;

NSString* urlRegistration = @"https://www.textmuse.com/admin/adduser.php";

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Register"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(registerUser:)];
    [[self navigationItem] setRightBarButtonItem: rightButton];

    birthPicker = [[BirthPickerView alloc] init];
    CGRect frm;
    frm.origin.x = 8;
    frm.size.width = [[self view] frame].size.width-16;
    frm.origin.y = [lblBirth frame].origin.y + [lblBirth frame].size.height + 8;
    frm.size.height = 162;// [btnPrivacy frame].origin.y - (frm.origin.y + frm.size.height + 16);
    [birthPicker setFrame:frm];
    if ([[CurrentUser UserBirthMonth] length] > 0 && [[CurrentUser UserBirthYear] length] > 0) {
        ;
    }
    [[self view] addSubview:birthPicker];
    
    if ([[CurrentUser UserName] length] > 0)
        [txtName setText:[CurrentUser UserName]];
    if ([[CurrentUser UserEmail] length] > 0)
        [txtEmail setText:[CurrentUser UserEmail]];
    if ([[CurrentUser UserBirthMonth] length] > 0 && [[CurrentUser UserBirthYear] length] > 0) {
        
    }
    
    [[self view] addGestureRecognizer:[self singleTapRecognizer]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITapGestureRecognizer *)singleTapRecognizer
{
    if (nil == _singleTapRecognizer) {
        _singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapToDismissKeyboard:)];
        _singleTapRecognizer.cancelsTouchesInView = NO; // absolutely required, otherwise "tap" eats events.
    }
    return _singleTapRecognizer;
}

// Something inside this VC's view was tapped (except the navbar/toolbar)
- (void)singleTapToDismissKeyboard:(UITapGestureRecognizer *)sender
{
    [self hideKeyboard:sender];
}

// When the "Return" key is pressed on the on-screen keyboard, hide the keyboard.
// for protocol UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [self hideKeyboard:textField];
    return YES;
}

- (IBAction)hideKeyboard:(id)sender
{
    // Just call resignFirstResponder on all UITextFields and UITextViews in this VC
    // Why? Because it works and checking which one was last active gets messy.
    [txtEmail resignFirstResponder];
    [txtName resignFirstResponder];
}

-(IBAction)btnPrivacy:(id)sender {
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:@"https://www.textmuse.com/privacy.html"]];
}

-(IBAction)registerUser:(id)sender {
    if ([[txtName text] length] > 0 && [[txtEmail text] length] > 0 &&
            [EmailValidator IsValidEmail:[txtEmail text] Strict:YES]) {
        if ([self checkAge]) {
            [Settings SaveSetting:SettingUserName withValue:[txtName text]];
            [CurrentUser setUserName: [txtName text]];
            [Settings SaveSetting:SettingUserEmail withValue:[txtEmail text]];
            [CurrentUser setUserEmail: [txtEmail text]];
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM"];
            NSString* m = [formatter stringFromDate:[birthPicker date]];
            [formatter setDateFormat:@"YYYY"];
            NSString* y = [formatter stringFromDate:[birthPicker date]];
            if ([m length] > 0 && [y length] > 0) {
                NSInteger mo = [m integerValue];
                NSInteger yr = [y integerValue];
                if (mo >=1 && mo <= 12 && yr >=1900 && yr <= 2100) {
                    NSString* smo = [NSString stringWithFormat:@"%ld", (long)mo];
                    NSString* syr = [NSString stringWithFormat:@"%ld", (long)yr];
                    [Settings SaveSetting:SettingUserBirthMonth withValue:smo];
                    [CurrentUser setUserBirthMonth: smo];
                    [Settings SaveSetting:SettingUserBirthYear withValue:syr];
                    [CurrentUser setUserBirthYear: syr];
                }
            }
            
            [self submitRegistration];
        }
    }
    
    [[self navigationController] popViewControllerAnimated:YES];
}

-(BOOL) checkAge {
    BOOL ret = true;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM"];
    NSString* m = [formatter stringFromDate:[birthPicker date]];
    [formatter setDateFormat:@"YYYY"];
    NSString* y = [formatter stringFromDate:[birthPicker date]];
    NSInteger mo = [m integerValue];
    NSInteger yr = [y integerValue];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger currYear = [components year];
    NSInteger currMonth = [components month];
    
    if (currYear - yr < 13 || (currYear - yr == 13 && currMonth <= mo)) {
        UIAlertView * alert =
        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Too Young Title", nil)
                                   message:NSLocalizedString(@"Too Young Description", nil)
                                  delegate:self
                         cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                         otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        
        //Don't ask for registration anymore
        AskRegistration = false;
        [Settings SaveSetting:SettingAskRegistration withValue:@"0"];
        
        ret = false;
    }
    
    return ret;
}

-(void)submitRegistration {
    NSURL* url = [NSURL URLWithString:urlRegistration];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url
                                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                   timeoutInterval:30];
    [req setHTTPMethod:@"POST"];
    NSString* urlStr;
    long app = [Skin SkinID];
#ifdef OODLES
    app = 91;
#endif
#ifdef OODLES
    app = 115;
#endif
    if ([[CurrentUser UserBirthMonth] length] > 0 && [[CurrentUser UserBirthYear] length] > 0)
        urlStr = [NSString stringWithFormat:@"name=%@&email=%@&bmonth=%@&byear=%@&appid=%@&app=%ld",
                  [CurrentUser UserName], [CurrentUser UserEmail], [CurrentUser UserBirthMonth],
                  [CurrentUser UserBirthYear], AppID, app];
    else
        urlStr = [NSString stringWithFormat:@"name=%@&email=%@&appid=%@&app=%@",
                  [CurrentUser UserName], [CurrentUser UserEmail], AppID, app];
    NSData* urlData = [urlStr dataUsingEncoding:NSUTF8StringEncoding];
    [req setHTTPBody:urlData];
    NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:req
                                                            delegate:self
                                                    startImmediately:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
