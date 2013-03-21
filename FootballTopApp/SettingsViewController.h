//
//  SettingsViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/5/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChangePasswordPopup.h"

@interface SettingsViewController : UIViewController<ChangePasswordPopupDelegate, UIImagePickerControllerDelegate>
{
    NSMutableArray                *categoriesMenu;
    UITapGestureRecognizer        *tapRecognizer;
    
    NSMutableDictionary           *userInfo;    
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UIButton    *cancelBtn;
@property (nonatomic, retain) IBOutlet UIButton    *saveBtn;

@end
