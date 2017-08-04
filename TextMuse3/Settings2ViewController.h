//
//  Settings2ViewController.h
//  TextMuse
//
//  Created by Peter Tucker on 8/4/17.
//  Copyright © 2017 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Settings2ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    NSMutableDictionary* tmpCategoryList;
    
    IBOutlet UITableView* chosenCategories;
    IBOutlet UISwitch* sortContacts;
    IBOutlet UISwitch* notifications;
    IBOutlet UISwitch* contacts;
    IBOutlet UISlider* contactCount;
    IBOutlet UISwitch* notes;
    IBOutlet UISlider* notesCount;
    IBOutlet UIView* viewBottomContainer;
    IBOutlet UIButton* btnVersions;
}

-(IBAction)skins:(id)sender;
-(IBAction)switchContacts:(id)sender;
-(IBAction)switchNotes:(id)sender;

@end
