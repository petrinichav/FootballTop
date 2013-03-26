//
//  ViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 8/29/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

- (IBAction) login:(id)sender;
- (IBAction) logout:(id)sender;
- (IBAction) registration:(id)sender;
- (IBAction) goHowGuest:(id)sender;
- (IBAction) forgotPassword:(id)sender;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@end
