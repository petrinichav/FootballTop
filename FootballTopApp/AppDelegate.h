//
//  AppDelegate.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 8/29/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegateBase.h"

@class LoginViewController, FTUser;

@interface AppDelegate : AppDelegateBase

@property (nonatomic, retain) FTUser *user;

- (void) getUserWithBlock:(dispatch_block_t) block;
- (BOOL) createdUser;
- (void) popToLoginScreen;

- (void) pushMainPagesWithMode:(int)mode;
- (void) showSearchControllerInNavController:(UINavigationController *) navVC;

@end
