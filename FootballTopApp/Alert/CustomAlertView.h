//
//  CustomAlertView.h
//  T3Lockey
//
//  Created by Alex Petrinich on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

enum
{
    LoginError           = 1,
    RegistrationError    = 2,
    UploadError          = 3,
    ConfirmPassword      = 4,
    ValidError           = 5,
    SettingsError        = 6,
    SearchError          = 7,
    ForgotPasswordError  = 8,
    ForgotPasswordSuccess= 9,
    InternetError        = 11,
    NoDataForRegister    = 12,
    
    
    PasswordError        = 20,
    SuccessfullChangePassword  = 21,
    SuccessfullChangeAvatar    = 22,
    LoginRequest               = 23,
    SaveUserInfo         = 24,
    VoteError            = 25,
    PostCommentError     = 26,
    SearchValidKeyWord   = 27,
};

typedef void(^AlertBlock)(UIAlertView *_alert);

@interface CustomAlertView : UIAlertView
{
    AlertBlock             cancelBlock, completeBlock;
    int                    type;
}

@property (nonatomic, copy) AlertBlock cancelBlock;
@property (nonatomic, copy) AlertBlock completeBlock;
@property (nonatomic) int type;

@end
