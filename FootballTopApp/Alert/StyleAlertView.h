//
//  StyleAlertView.h
//  iPhoneScriptIT
//
//  Created by Alex Petrinich on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomAlertView.h"
#import "TextFieldForAlert.h"


enum
{
    EmailStyle    = 0,
    PasswordStyle = 1,
};

@interface StyleAlertView : CustomAlertView
{
    int styleAlert;
    int txtFieldsInAlert;    
}

@property int styleAlert;
@property int txtFieldsInAlert;

+ (StyleAlertView *) alertViewWithStyle:(int)style withFields:(int)fields deleagte:(id)delegate;

- (void) createTextFields;

@end
