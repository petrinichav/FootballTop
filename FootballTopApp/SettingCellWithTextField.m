//
//  SettingCellWithTextField.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/11/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "SettingCellWithTextField.h"

@implementation SettingCellWithTextField

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        editField = [[UITextField alloc] initWithFrame:CGRectMake(50, 0, 100, 44)];
        editField.textAlignment = UITextAlignmentLeft;
        editField.borderStyle = UITextBorderStyleNone;
        editField.delegate = (id)self;
        editField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        editField.textColor = [UIColor colorWithRed:8.f/255 green:102.f/255 blue:166.f/255 alpha:1.f];
        editField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
    }
    return self;
}

- (void) dealloc
{
    [editField release];
    [super dealloc];
}


- (void) setEditableTextField:(BOOL)editable
{
    CGRect rect = self.textLabel.frame;
    CGRect tfRect = editField.frame;
    tfRect.origin.x = rect.origin.x + rect.size.width + 5;
    tfRect.size.height = self.bounds.size.height;
    tfRect.size.width = self.bounds.size.width - rect.size.width - 50;
    editField.frame = tfRect;
    [self.contentView addSubview:editField];
    isEditTextField = editable;
}

- (void) setValueForTextField:(NSString *)text
{
    editField.text = text;
}

- (void) becomeFirstResponderTextField
{
    [editField becomeFirstResponder];
}

- (void) resignFirstResponderTextField
{
    [editField resignFirstResponder];
    [editField removeFromSuperview];
}

- (NSString *) value
{
    return editField.text;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return isEditTextField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    isEditTextField = NO;
    [editField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ValueForCell" object:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
