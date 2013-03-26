//
//  ViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 8/29/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "LoginViewController.h"
#import "NetworkTaskGenerator.h"
#import "DataSource.h"
#import "UnderlinedButton.h"
#import "ForgotPasswordViewController.h"
#import "AppDelegate.h"
#import "AlertModule.h"

#import "FTPlotView.h"

#define USERNAME_LBL @"Логин или e-mail"
#define PASSWORD_LBL @"Пароль"

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark - Keyboard

- (void) hideKeyboard:(UITapGestureRecognizer *)recognizer
{
    [TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_LOGIN) resignFirstResponder];
    [TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_PASS) resignFirstResponder];
    [self.scrollView removeGestureRecognizer:recognizer];
}

- (void) keyboardWillBeHidden:(NSNotification *) notif
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
//    if ([TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_LOGIN).text length] == 0)
//        TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_LOGIN).text = USERNAME_LBL;
//    if ([TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_PASS).text length] == 0)
//        TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_PASS).text = PASSWORD_LBL;
}


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect passRect = TextFieldWithID(ID_TXTFIELD_PASS).frame;
    CGPoint scrollPoint = CGPointMake(0.0, [UIScreen mainScreen].bounds.size.height - passRect.origin.y - passRect.size.height-110);//
    [self.scrollView setContentOffset:scrollPoint animated:YES];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.scrollView addGestureRecognizer:recognizer];
    [recognizer release];
    
//    if ([TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_LOGIN).text isEqualToString:USERNAME_LBL])
//        TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_LOGIN).text = @"";
//    if ([TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_PASS).text isEqualToString:PASSWORD_LBL])
//        TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_PASS).text = @"";
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Localization localizeView:self.view];
    [Localization localizeView:self.scrollView];

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) releaseOutlets
{
    [_scrollView release];
    _scrollView = nil;
}

- (void) didReceiveMemoryWarning
{
    [self releaseOutlets];
    [super didReceiveMemoryWarning];
}

- (void) viewDidUnload
{
    [self releaseOutlets];
    [super viewDidUnload];
}

- (void) dealloc
{
    [self releaseOutlets];
    [super dealloc];
}

- (IBAction) login:(id)sender
{
    NSString *user = TextFieldWithID(ID_TXTFIELD_LOGIN).text;
    NSString *pass = TextFieldWithID(ID_TXTFIELD_PASS).text;
    [LoadingView showInView:self.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForLanguage:@"ru" Login:user password:pass completeBlock:^(DispatchTask *item) {
        [LoadingView hide];
        if (((NetworkTaskGenerator *)item).isSuccessful || ((NetworkTaskGenerator *)item).statusCode == 406)
        {
            NSDictionary *response = [(NetworkTaskGenerator *)item objectFromString];
            @try {
                NSString *uid = [response objectForKey:@"uid"];
                if (uid)
                {
                    [[DataSource data] setObject:uid forKey:USER_ID];
                    [[DataSource data] setObject:user forKey:USER];
                    [[DataSource data] setObject:pass forKey:PASSWORD];
                    [[DataSource source] saveData];
                    
                    TextFieldWithID(ID_TXTFIELD_LOGIN).text = @"";
                    TextFieldWithID(ID_TXTFIELD_PASS).text = @"";
                }
            }
            @catch (NSException *exception) {
                dbgLog(@"login error %@", exception);
            }
            [APPDelegate getUserWithBlock:^{
                
            }];
            [APPDelegate pushMainPagesWithMode:User];
        }
        else
        {
            [[AlertModule instance] createAlertWithType:LoginError buttons:1 withCancelBlock:^(UIAlertView *_alert) {
                
            } completeBlock:^(UIAlertView *_alert) {
                
            }];
            [[AlertModule instance] showAlert];
        }
    }];
    [[DispatchTools Instance] addTask:task];
    
    [TextFieldWithID(ID_TXTFIELD_LOGIN) resignFirstResponder];
    [TextFieldWithID(ID_TXTFIELD_PASS) resignFirstResponder];

}

- (IBAction) logout:(id)sender
{
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForLogoutWithCompleteBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            dbgLog(@"Success logout");
        }
    }];
    [[DispatchTools Instance] addTask:task];
}

- (IBAction) registration:(id)sender
{
    [self.navigationController pushViewController:[Tools loadViewControllerNamed:@"RegistrationViewController"] animated:YES];
}

- (IBAction) goHowGuest:(id)sender
{
    [(AppDelegate *)[UIApplication sharedApplication].delegate pushMainPagesWithMode:Guest];
}

- (IBAction) forgotPassword:(id)sender
{
    ForgotPasswordViewController *vc = [[ForgotPasswordViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
