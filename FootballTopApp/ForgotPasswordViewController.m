//
//  ForgotPasswordViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 1/14/13.
//  Copyright (c) 2013 Alex Petrinich. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "NetworkTaskGenerator.h"
#import "LoadingView.h"
#import "FieldValidator.h"
#import "AlertModule.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) releaseOutlets
{
    [_emailField release];
    _emailField = nil;
    [_bgScrollView release];
    _bgScrollView = nil;
}

- (void) dealloc
{
    [self releaseOutlets];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidUnload
{
    [self releaseOutlets];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [self releaseOutlets];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard

- (void) hideKeyboard:(UITapGestureRecognizer *)recognizer
{
    [self.emailField resignFirstResponder];
    [self.bgScrollView removeGestureRecognizer:recognizer];
}

- (void) keyboardWillBeHidden:(NSNotification *) notif
{
    [self.bgScrollView setContentOffset:CGPointZero animated:YES];
}


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.bgScrollView.contentInset = contentInsets;
    self.bgScrollView.scrollIndicatorInsets = contentInsets;
    
    CGPoint scrollPoint = CGPointMake(0.0, kbSize.height/2);//
    [self.bgScrollView setContentOffset:scrollPoint animated:YES];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.bgScrollView addGestureRecognizer:recognizer];
    [recognizer release];
    
}

#pragma mark - Buttons

- (IBAction) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) reestablishPassword:(id)sender
{
    if ([FieldValidator isEmailValid:self.emailField.text])
    {
        [LoadingView show];
        NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForPasswordReestablishingWithEmail:self.emailField.text completeBlock:^(DispatchTask *item) {
            if (((NetworkTaskGenerator *)item).isSuccessful)
            {
                [[AlertModule instance] createAlertWithType:ForgotPasswordSuccess
                                                    buttons:1
                                            withCancelBlock:^(UIAlertView *_alert) {
                                                [self.navigationController popViewControllerAnimated:YES];

                                            } completeBlock:^(UIAlertView *_alert) {
                                            }];
                [[AlertModule instance] showAlert];
            }
            else
            {
                if (((NetworkTaskGenerator *)item).statusCode == 404)
                {
                    [[AlertModule instance] createAlertWithType:ForgotPasswordError buttons:1 withCancelBlock:^(UIAlertView *_alert) {
                        
                    } completeBlock:^(UIAlertView *_alert) {
                        
                    }];
                    [[AlertModule instance] showAlert];

                }
                else
                {
//                NSString *response = [(NetworkTaskGenerator *)item objectFromString];
//                [[AlertModule instance] createAlertWithMessage:response withCancelBlock:^(UIAlertView *_alert) {
//                    
//                } completeBlock:^(UIAlertView *_alert) {
//                    
//                }];
//                [[AlertModule instance] showAlert];
                }
            }
            [LoadingView hide];
        }];
    
        [[DispatchTools Instance] addTask:task];
    }
    else
    {
        [[AlertModule instance] createAlertWithType:ValidError buttons:1 withCancelBlock:^(UIAlertView *_alert) {
            
        } completeBlock:^(UIAlertView *_alert) {
            
        }];
        [[AlertModule instance] showAlert];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
