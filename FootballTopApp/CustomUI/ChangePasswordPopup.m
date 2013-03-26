//
//  ChangePasswordPopup.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/29/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "ChangePasswordPopup.h"

@implementation ChangePasswordPopup

+ (ChangePasswordPopup *) loadView
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"ChangePasswordPopup" owner:self options:NULL];
    ChangePasswordPopup *view = [objects objectAtIndex:0];
    return view;
}

- (void) dealloc
{
    [_scrollView release];
    _scrollView = nil;
    [_oldPasswordField release];
    _oldPasswordField = nil;
    [_newPasswordField release];
    _newPasswordField = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void) hideKeyboard:(UITapGestureRecognizer *)r
{
    [self.oldPasswordField resignFirstResponder];
    [self.newPasswordField resignFirstResponder];
    [self.scrollView removeGestureRecognizer:r];
}

- (void) keyboardWillBeHidden:(NSNotification *) notif
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGPoint scrollPoint = CGPointMake(0.0, kbSize.height/2);//
    [self.scrollView setContentOffset:scrollPoint animated:YES];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.scrollView addGestureRecognizer:recognizer];
    [recognizer release];
    
}


- (void) addNotificationsObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

- (void) showInView:(UIView *)view
{
    if (!self.isShowing)
    {
        self.isShowing = YES;
        
        self.alpha = 0.f;
        [view addSubview:self];

        [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseIn  animations:^{
            self.alpha = 1.f;
        } completion:^(BOOL finished) {
            [self addNotificationsObserver];
        }];
    }
}

- (void) hide
{
    if (self.isShowing)
    {
        self.isShowing = NO;
        
        self.alpha = 1.f;
        
        [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseOut  animations:^{
            self.alpha = 0.f;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }];
    }
}

- (NSString *) oldPassword
{
    return self.oldPasswordField.text;
}

- (NSString *) newPassword
{
    return self.newPasswordField.text;
}

- (IBAction) done:(id)sender
{
    [self hide];
    [self.delegate changePasswordPopup:self didClickToButtonWithIndex:kOKButton];
}

- (IBAction) cancel:(id)sender
{
    [self hide];
    [self.delegate changePasswordPopup:self didClickToButtonWithIndex:kCancelButton];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
