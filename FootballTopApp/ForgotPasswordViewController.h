//
//  ForgotPasswordViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 1/14/13.
//  Copyright (c) 2013 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextField *emailField;
@property (nonatomic, retain) IBOutlet UIScrollView *bgScrollView;

- (IBAction) back:(id)sender;
- (IBAction) reestablishPassword:(id)sender;

@end
