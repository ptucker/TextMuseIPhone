//
//  BirthPickerView.h
//  TextMuse3
//
//  Created by Peter Tucker on 5/16/15.
//  Copyright (c) 2015 LaLoosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BirthPickerView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong, readonly) NSDate* date;

@end
