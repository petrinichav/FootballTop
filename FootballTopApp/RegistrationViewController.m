//
//  RegistrationViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/11/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "RegistrationViewController.h"
#import "NetworkTaskGenerator.h"
#import "FieldValidator.h"
#import "AppDelegate.h"
#import "DataSource.h"
#import "AlertModule.h"
#import "DataPickerView.h"

#define USERNAME_LBL @"Логин"
#define EMAIL_LBL    @"E-mail"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Notifications

- (void) hideKeyboard:(UITapGestureRecognizer *)recognizer
{
    [TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_LOGIN) resignFirstResponder];
    [TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_EMAIL) resignFirstResponder];
    [self.scrollView removeGestureRecognizer:recognizer];
}

- (void) keyboardWillBeHidden:(NSNotification *) notif
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
//    if ([TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_LOGIN).text length] == 0)
//    {
//        TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_LOGIN).text = USERNAME_LBL;
//    }
//    if ([TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_EMAIL).text length] == 0)
//    {
//        TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_EMAIL).text = EMAIL_LBL;
//    }
}


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect passRect = TextFieldWithID(ID_TXTFIELD_EMAIL).frame;
    CGPoint scrollPoint = CGPointMake(0.0, [UIScreen mainScreen].bounds.size.height - passRect.origin.y - passRect.size.height-110);//
    [self.scrollView setContentOffset:scrollPoint animated:YES];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.scrollView addGestureRecognizer:recognizer];
    [recognizer release];
    
//    if ([TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_LOGIN).text isEqualToString:USERNAME_LBL])
//        TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_LOGIN).text = @"";
//    if ([TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_EMAIL).text isEqualToString:EMAIL_LBL])
//        TextFieldInViewWithID(self.scrollView, ID_TXTFIELD_EMAIL).text = @"";
}

- (void) getCountry:(id)object
{
    NSDictionary *value = object;
    [self.countryButton setTitle:[value objectForKey:@"Country"] forState:UIControlStateNormal];
    
    countryID = [[value objectForKey:@"ID"] intValue];
}

#pragma mark - UI logic

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Localization localizeView:self.view];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseOutlets];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self releaseOutlets];
}

- (void) releaseOutlets
{
    [_scrollView release];
    _scrollView = nil;
    [_countryButton release];
    _countryButton = nil;
}

- (void) dealloc
{
    [self releaseOutlets];
    [super dealloc];
}

- (void) hideDataPicker:(UITapGestureRecognizer *)recognizer
{
    DataPickerView *picker = (DataPickerView *)ViewWithID(ID_PICKER_VIEW);
    [picker hide];
    
    [self.view removeGestureRecognizer:recognizer];
}

- (void) addDataPickerWithType:(FTPickerType)type
{
    [TextFieldWithID(ID_TXTFIELD_EMAIL) resignFirstResponder];
    [TextFieldWithID(ID_TXTFIELD_LOGIN) resignFirstResponder];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDataPicker:)];
    [self.view addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
    
    DataPickerView *dataPicker = [DataPickerView loadPickerWithType:type];
    dataPicker.block = ^(id object)
    {
        [self getCountry:object];
    };
    [dataPicker showInView:self.view withOffset:20];
    dataPicker.tag = ID_PICKER_VIEW;
}

- (void) loginWithUserName:(NSString *)username password:(NSString *)password
{
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForLanguage:@"ru" Login:username password:password completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful || ((NetworkTaskGenerator *)item).statusCode == 406)
        {
            NSDictionary *response = [(NetworkTaskGenerator *)item objectFromString];
            @try {
                NSString *uid = [response objectForKey:@"uid"];
                if (uid)
                {
                    [[DataSource data] setObject:uid forKey:USER_ID];
                    [[DataSource data] setObject:username forKey:USER];
                    [[DataSource data] setObject:password forKey:PASSWORD];
                    [[DataSource source] saveData];
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
            [LoadingView hide];
        }
    }];
    [[DispatchTools Instance] addTask:task];
}

- (IBAction) registration:(id)sender
{
    NSString *user = TextFieldWithID(ID_TXTFIELD_LOGIN).text;
    NSString *email = TextFieldWithID(ID_TXTFIELD_EMAIL).text;
    if (![FieldValidator isEmailValid:email])
    {
        [[AlertModule instance] createAlertWithType:NoDataForRegister
                                            buttons:1
                                    withCancelBlock:^(UIAlertView *_alert) {
                                        
                                    } completeBlock:^(UIAlertView *_alert) {
                                        
                                    }];
        [[AlertModule instance] showAlert];
        return;
    }
    [LoadingView showInView:self.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForRegistrationWithUser:user email:email country:countryID language:@"ru" completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSDictionary *response = [(NetworkTaskGenerator *)item objectFromString];
            dbgLog(@"%@", response);
            NSString *userName = [response objectForKey:@"name"];
            NSString *pass = [response objectForKey:@"password"];
            
            [self loginWithUserName:userName password:pass];
            
        }
        else if (((NetworkTaskGenerator *)item).statusCode == EmailOrUsernameError)
        {
            [[AlertModule instance] createAlertWithType:RegistrationError buttons:1 withCancelBlock:^(UIAlertView *_alert) {
                
            } completeBlock:^(UIAlertView *_alert) {
                
            }];
            [[AlertModule instance] showAlert];
        }
        [LoadingView hide];
    }];
    [[DispatchTools Instance] addTask:task];

}

- (IBAction) showCountryList:(id)sender
{
    [self addDataPickerWithType:FTPickerTypeData];
}

- (IBAction) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
