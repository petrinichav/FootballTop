//
//  ChangePasswordPopup.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/29/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChangePasswordPopup;

@protocol ChangePasswordPopupDelegate <NSObject>

- (void) changePasswordPopup:(ChangePasswordPopup *)popup didClickToButtonWithIndex:(int)index;

@end

enum
{
    kOKButton,
    kCancelButton,
};

@interface ChangePasswordPopup : UIView

@property (nonatomic) BOOL isShowing;
@property (nonatomic, assign) id<ChangePasswordPopupDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextField  *oldPasswordField;
@property (nonatomic, retain) IBOutlet UITextField  *newPasswordField;

+ (ChangePasswordPopup *) loadView;

- (void) showInView:(UIView *)view;
- (void) hide;

- (NSString *) oldPassword;
- (NSString *) newPassword;

@end
