//
//  TextFieldForAlert.h
//  iPhoneScriptIT
//
//  Created by Alex Petrinich on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum TypeTextField
{
    Email              = 100,
    Password           = 101,
    ConfirmNewPassword = 102,
    NewPassword        = 103,
}TypeTextField;

@interface TextFieldForAlert : UITextField
{
    TypeTextField typeField;
}

@property TypeTextField typeField;

@end
