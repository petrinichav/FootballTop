//
//  SettingCellWithTextField.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/11/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "SettingsCell.h"

@interface SettingCellWithTextField : SettingsCell
{
    UITextField         *editField;
    
    BOOL isEditTextField;
}

- (void) setEditableTextField:(BOOL)editable;
- (void) becomeFirstResponderTextField;
- (void) resignFirstResponderTextField;

- (void) setValueForTextField:(NSString *)text;

@end
