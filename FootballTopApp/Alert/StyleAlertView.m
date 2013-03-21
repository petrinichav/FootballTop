//
//  StyleAlertView.m
//  iPhoneScriptIT
//
//  Created by Alex Petrinich on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StyleAlertView.h"

@implementation StyleAlertView
@synthesize styleAlert;
@synthesize txtFieldsInAlert;

- (void) dealloc
{
    [super dealloc];
}

+ (NSMutableDictionary *) createDictionaryForStyle:(int)style withField:(int)fields
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableString *message = [NSMutableString string];
    for (int i = 0; i < fields; i++)
    {
        [message appendString:@"\n\n"];
    }
    [dict setObject:message forKey:@"Message"];
    
    if (style == EmailStyle)
    {
        [dict setObject:@"" forKey:@"Title"];
       
    }
    else if (style == PasswordStyle)
    {
        [dict setObject:@"" forKey:@"Title"];
    }
    return dict;
}

+ (StyleAlertView *) alertViewWithStyle:(int)style withFields:(int)fields deleagte:(id)delegate
{
    NSDictionary *dict = [StyleAlertView createDictionaryForStyle:style withField:fields];
    StyleAlertView *alert = [[StyleAlertView alloc] initWithTitle:[dict objectForKey:@"Title"]
                                                                             message:[dict objectForKey:@"Message"]
                                                                            delegate:delegate
                                                                   cancelButtonTitle:Loc(@"_Loc_Alert_Cancel1")
                                                                   otherButtonTitles:Loc(@"_Loc_Alert_Ok1"), nil  ];
    alert.styleAlert = style;
    alert.txtFieldsInAlert = fields;
    return [alert autorelease];
}

- (NSMutableDictionary *) createDictionaryForTextFields
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.styleAlert == EmailStyle)
    {
        [dict setObject:@"Email" forKey:@"Placeholder1"];
        [dict setObject:@"Password" forKey:@"Placeholder2"];
        [dict setObject:[NSNumber numberWithInt:2] forKey:@"IndexSpecialField"];
        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"SecureField"];
    }else if (self.styleAlert == PasswordStyle){
        [dict setObject:@"Старый пароль" forKey:@"Placeholder1"];
        [dict setObject:@"Новый пароль" forKey:@"Placeholder2"];
        [dict setObject:@"Retype New Password" forKey:@"Placeholder3"];
        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"SecureField"];
    }
    return dict;
}

- (void) createTextFieldsForEmailAlert
{
    float y = 20;
    NSMutableDictionary *dict = [self createDictionaryForTextFields];
    NSString *email = [dict objectForKey:@"Placeholder1"];
    NSString *pass = [dict objectForKey:@"Placeholder2"];
    int indexSpecial = [[dict objectForKey:@"IndexSpecialField"] intValue];
    BOOL isSecure = [[dict objectForKey:@"SecureField"] boolValue];
    for (int i = 0; i < txtFieldsInAlert; i++)
    {
        TextFieldForAlert *txtField = [[TextFieldForAlert alloc] initWithFrame:CGRectMake(17, y, 250, 40)];
        y+=45;
        txtField.backgroundColor = [UIColor whiteColor];
        txtField.borderStyle = UITextBorderStyleRoundedRect;
        txtField.font = [UIFont fontWithName:@"Helvetica" size:17];
        txtField.minimumFontSize = 13;
        txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        txtField.delegate = (id)self;
        
        if (email != nil && i == 0)
        {
            txtField.placeholder = email;
            txtField.typeField = Email;
            txtField.tag = Email;
        }
        if (pass != nil && i == indexSpecial - 1)
        {
            txtField.placeholder = pass;
            if (isSecure)
                txtField.secureTextEntry = isSecure;
            txtField.typeField = Password;
            txtField.tag = Password;
        }
        
        [self addSubview:txtField];
        [txtField release];
    }
}

- (void) createTextFieldsForPasswordAlert
{
    float y = 20;
    NSMutableDictionary *dict = [self createDictionaryForTextFields];
    NSString *oldPass = [dict objectForKey:@"Placeholder1"];
    NSString *newPass = [dict objectForKey:@"Placeholder2"];
    NSString *retypePass = [dict objectForKey:@"Placeholder3"];
    BOOL isSecure = [[dict objectForKey:@"SecureField"] boolValue];
    for (int i = 0; i < txtFieldsInAlert; i++)
    {
        TextFieldForAlert *txtField = [[TextFieldForAlert alloc] initWithFrame:CGRectMake(17, y, 250, 40)];
        y+=45;
        txtField.backgroundColor = [UIColor whiteColor];
        txtField.borderStyle = UITextBorderStyleRoundedRect;
        txtField.font = [UIFont fontWithName:@"Helvetica" size:17];
        txtField.minimumFontSize = 13;
        txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        txtField.delegate = (id)self;
        txtField.secureTextEntry = isSecure;
        if (oldPass != nil && i == 0)
        {
            txtField.placeholder = oldPass;
            txtField.typeField = Password;
            txtField.tag = Password;
        }
        if (newPass != nil && i == 1)
        {
            txtField.placeholder = newPass;
            txtField.typeField = NewPassword;
            txtField.tag = NewPassword;
        }
        if (retypePass != nil && i == 2)
        {
            txtField.placeholder = retypePass;
            txtField.typeField = ConfirmNewPassword;
            txtField.tag = ConfirmNewPassword;
        }

        [self addSubview:txtField];
        [txtField release];
    }
   
}


- (void) createTextFields
{
    if (styleAlert == EmailStyle)
    {
        [self createTextFieldsForEmailAlert];
    }else if (styleAlert == PasswordStyle){
        [self createTextFieldsForPasswordAlert];
    }
}

#pragma mark textfield

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end

