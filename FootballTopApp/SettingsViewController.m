//
//  SettingsViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/5/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingSource.h"
#import "SettingsCell.h"
#import "SettingCellWithTextField.h"
#import "NetworkTaskGenerator.h"
#import "DataSource.h"
#import "AlertModule.h"
#import "LoadingView.h"
#import "DataPickerView.h"
#import "AppDelegate.h"
#import "FTUser.h"
#import "UIImage-Extensions.h"

enum
{
    kCamera,
    kLibrary,
    kCancel,
};

enum
{
    kIndexName,
    kIndexBdate,
    kIndexCountry,
};

@interface SettingsViewController ()

@property (nonatomic, retain)  NSIndexPath   *currentIndexPath;
@property (nonatomic, retain)  UITableViewCell *editableCell;
@property (nonatomic) BOOL isChangeSettings;
@property (nonatomic) BOOL resetPassword;
@property (nonatomic) int  selectedCountryRow;

@end

@implementation SettingsViewController
@synthesize table = _table;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = Loc(@"_Loc_Settings" );
        [self.tabBarItem setFinishedSelectedImage:[Tools hiresImageNamed:@"btn_settings_s.png"] withFinishedUnselectedImage:[Tools hiresImageNamed:@"btn_settings.png"]];
        
        categoriesMenu = [[NSMutableArray alloc] initWithCapacity:4];
        [categoriesMenu addObject:[NSArray arrayWithObjects:@"editAvatar", nil]];
        [categoriesMenu addObject:[NSArray arrayWithObjects:@"editName",
                                   @"editBDate",
                                   nil]];
        [categoriesMenu addObject:[NSArray arrayWithObjects:@"editCountry",
                                   nil]];
        [categoriesMenu addObject:[NSArray arrayWithObjects:@"editAbout",
                                   nil]];
        [categoriesMenu addObject:[NSArray arrayWithObjects:@"editPassword",
                                   @"logout", nil]];
        
        userInfo = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}

- (void) hideDataPicker:(UITapGestureRecognizer *)reconizer
{
    DataPickerView *picker = (DataPickerView *)ViewWithID(ID_PICKER_VIEW);
    [picker hide];
    
    [self.view removeGestureRecognizer:reconizer];
    
    [tapRecognizer release];
    tapRecognizer = nil;
}

- (void) addDataPickerWithType:(FTPickerType)type
{
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDataPicker:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    DataPickerView *dataPicker = [DataPickerView loadPickerWithType:type];
    dataPicker.block = ^(id object)
    {
        [self pickerValue:object];
    };
    [dataPicker showInView:self.view];
    dataPicker.tag = ID_PICKER_VIEW;
}

#pragma mark - Selectors

- (void) editName
{
    
}

- (void) editAbout
{
    
}

- (void) editBDate
{
    [self addDataPickerWithType:FTPickerTypeDate];
}

- (void) editCountry
{
    [self addDataPickerWithType:FTPickerTypeData];
}

- (void) uploadPhotoForProfile:(UIImage *)image
{
    NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
    [LoadingView showInView:self.tabBarController.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForUploadProfileImage:imgData completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSDictionary *response = [(NetworkTaskGenerator *)item objectFromString];
            dbgLog(@"susscces response = %@", response);
            [APPDelegate getUserWithBlock:^{
                
            }];
            [[AlertModule instance] createAlertWithType:SuccessfullChangeAvatar buttons:1
                                        withCancelBlock:^(UIAlertView *_alert) {
                                            
                                        } completeBlock:^(UIAlertView *_alert) {
                                            
                                        }];
            [[AlertModule instance] showAlert];
            [self.table reloadData];

        }
        [LoadingView hide];
    }];
    
    [[DispatchTools Instance] addTask:task];
}

- (void) logout
{
    [LoadingView showInView:self.tabBarController.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForLogoutWithCompleteBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            dbgLog(@"Success logout");
            [[DataSource data] removeObjectForKey:USER];
            [[DataSource data] removeObjectForKey:USER_ID];
            [[DataSource data] removeObjectForKey:PASSWORD];
            [[DataSource source] saveData];
            APPDelegate.user = nil;
            [APPDelegate popToLoginScreen];            
        }
        [LoadingView hide];
    }];
    [[DispatchTools Instance] addTask:task];
}

- (void) showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:Loc(@"_Loc_Take_Photo")
                                                             delegate:(id)self
                                                    cancelButtonTitle:Loc(@"_Loc_Cancel")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:Loc(@"_Loc_Photo_Camera"), Loc(@"_Loc_Photo_Library"), nil];
   
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    [actionSheet release];
}

- (void) editAvatar
{
    [self showActionSheet];
}

- (void) changeOldPassword:(NSString *) oldPass toNewPassword:(NSString *) newPass
{
    dbgLog(@"old = %@",[[DataSource data] objectForKey:PASSWORD]);
    if (![oldPass isEqualToString:[[DataSource data] objectForKey:PASSWORD]])
    {
        //show alert;
        [[AlertModule instance] createAlertWithType:PasswordError buttons:1
                                    withCancelBlock:^(UIAlertView *_alert) {
                                        
                                    } completeBlock:^(UIAlertView *_alert) {
                                        
                                    }];
        [[AlertModule instance] showAlert];
        return;
    }
    
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForChangePassword:newPass oldPassword:oldPass completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSDictionary *response = [(NetworkTaskGenerator *)item objectFromString];
            dbgLog(@"change pass = %@", response);
            [[DataSource data] setObject:newPass forKey:PASSWORD];
            [[DataSource source] saveData];
            
            [[AlertModule instance] createAlertWithType:SuccessfullChangePassword buttons:1
                                        withCancelBlock:^(UIAlertView *_alert) {
                                            
                                        } completeBlock:^(UIAlertView *_alert) {
                                            
                                        }];
            [[AlertModule instance] showAlert];
        }
        [LoadingView hide];
        self.resetPassword = NO;
    }];
    
    [[DispatchTools Instance] addTask:task];

}

- (void) editPassword
{
    self.resetPassword = YES;
    
    [[AlertModule instance] createAlertWithStyle:PasswordStyle withCancelBlock:^(UIAlertView *_alert) {
        self.resetPassword = NO;
    } completeBlock:^(UIAlertView *_alert) {
        UITextField *oldPass = (UITextField *)[_alert viewWithTag:Password];
        UITextField *newPass = (UITextField *)[_alert viewWithTag:NewPassword];
        [self changeOldPassword:oldPass.text
                  toNewPassword:newPass.text];
    }];
    [[AlertModule instance] showAlert];
}


#pragma mark - Logic

- (void)  setUserInfoValue:(id)value
{
    NSString *jsonName = [[SettingSource source] jsonKeyForRow:self.currentIndexPath.row inSection:self.currentIndexPath.section];
    NSDate *date = [AppHelper dateFromString:value forFormat:@"dd/MM/yyyy"];
    if (date)
    {
        NSTimeInterval time = [date timeIntervalSince1970];
        value = [NSNumber numberWithInt:time];
    }
    [userInfo setObject:value forKey:jsonName];
}

- (void) saveValueForCell:(NSNotification *)notif
{
    SettingsCell *cell = [notif object];
    cell.detailTextLabel.alpha = 1;
    NSIndexPath *indexPath = [_table indexPathForCell:cell];
    [[SettingSource source] saveValue:[cell value] toSourceForRow:indexPath.row section:indexPath.section];
    
    cell.detailTextLabel.text = [cell value];
    
    if ([cell respondsToSelector:@selector(setEditableTextField:)])
    {
        [(SettingCellWithTextField *)cell setEditableTextField:NO];
        [(SettingCellWithTextField *)cell resignFirstResponderTextField];
    }
    
    [self setUserInfoValue:cell.detailTextLabel.text];
    
    [self.table setContentOffset:CGPointZero animated:NO];
    [self.table reloadData];
    
    self.isChangeSettings = YES;
}

- (void) pickerValue:(id) object
{
    NSString *value = nil;
    if ([object isKindOfClass:[NSDictionary class]])
    {
        value = [object objectForKey:@"Country"];
        self.selectedCountryRow = [[object objectForKey:@"Row"] intValue];
    }
    else
        value = object;
    
    UITableViewCell *cell = [self.table cellForRowAtIndexPath:self.currentIndexPath];
    cell.detailTextLabel.alpha = 1;
    cell.detailTextLabel.text = value;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    [self setUserInfoValue:value];
    
    self.isChangeSettings = YES;
}

- (void) setIsChangeSettings:(BOOL)isChangeSettings
{
    _isChangeSettings = isChangeSettings;
    if (isChangeSettings)
    {
        self.cancelBtn.enabled = YES;
        self.saveBtn.enabled = YES;
    }
    else
    {
        self.cancelBtn.enabled = NO;
        self.saveBtn.enabled = NO;
    }
}

- (void) keyboardWillBeHidden:(NSNotification *) notif
{
    if (self.resetPassword)
        return;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.table.contentInset = contentInsets;
    self.table.scrollIndicatorInsets = contentInsets;

    [self.table setContentOffset:CGPointZero animated:YES];
}


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (self.resetPassword)
        return;
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    SettingsCell* cell = (SettingsCell* )self.editableCell;
    float dilige = 2;
    if ([UIScreen mainScreen].bounds.size.height > 480)
        dilige = 4;
        
    if (cell.frame.origin.y > [UIScreen mainScreen].bounds.size.height/dilige)
    {    
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.table.contentInset = contentInsets;
        self.table.scrollIndicatorInsets = contentInsets;
    
        CGPoint scrollPoint = CGPointMake(0.0, cell.frame.origin.y + cell.frame.size.height/2-20);//
        [self.table setContentOffset:scrollPoint animated:YES];
    }
    
}

- (void) changeProfileImage:(NSNotification *) notif
{
    SettingsCell *cell = (SettingsCell *)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    __block UIImage *image = nil;
    DispatchTask *task = [DispatchTask taskWithExecuteBlock:^(DispatchTask *newTask) {
        image =     [[DataSource source] cashedImageWithoutRequestForURL:[NSURL URLWithString:APPDelegate.user.avatar]];
    } andCompletitionBlock:^(DispatchTask *item)
                          {
                              [cell  setImage:image];
                          }];
    [[DispatchTools Instance] addTask:task];
    
    [self.table reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Localization localizeView:self.view];    
   
    self.isChangeSettings = NO;
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveValueForCell:) name:@"ValueForCell" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeProfileImage:) name:SAVE_USER object:nil];
    
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
    [self hideDataPicker:tapRecognizer];
}

- (void) releaseOutlets
{
    [_table release];
    _table = nil;
    [_cancelBtn release];
    _cancelBtn = nil;
    [_saveBtn release];
    _saveBtn = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [self releaseOutlets];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    [self releaseOutlets];
    [categoriesMenu release];
    [tapRecognizer release];
    [_currentIndexPath release];
    [_editableCell release];
    [userInfo release];
    [super dealloc];
}

#pragma mark - Buttons

- (IBAction) cancel:(id)sender
{
    self.isChangeSettings = NO;
    [userInfo removeAllObjects];
    [self.table reloadData];
}

- (IBAction) save:(id)sender
{
    [LoadingView showInView:self.tabBarController.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForUpdateUserInfo:userInfo completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            [APPDelegate getUserWithBlock:^{
                
            }];
            NSDictionary *response = [(NetworkTaskGenerator *)item objectFromString];
            dbgLog(@"change pass = %@", response);
            self.isChangeSettings = NO;
            
            [[AlertModule instance] createAlertWithType:SaveUserInfo buttons:1 withCancelBlock:^(UIAlertView *_alert) {
                
            } completeBlock:^(UIAlertView *_alert) {
                
            }];
            [[AlertModule instance] showAlert];
            
        }
        [LoadingView hide];
        
    }];
    
    [[DispatchTools Instance] addTask:task];
}

#pragma mark - Tbl

- (NSString *) detailValueForIndex:(NSIndexPath *)index
{
    NSString *jsonName = [[SettingSource source] jsonKeyForRow:index.row inSection:index.section];
    NSString *value = [userInfo objectForKey:jsonName];
    if (value != nil)
    {
        if (index.section == 1 && index.row == kIndexBdate)
        {
            return [AppHelper date:[NSDate dateWithTimeIntervalSince1970:[value doubleValue]] withFormat:@"dd/MM/yyyy"];
        }
        return value;
    }
    
    if (index.section == 1)
    {
        switch (index.row) {
            case kIndexName:
            {
                return APPDelegate.user.name;
            }
                break;
            case kIndexBdate:
            {
                return APPDelegate.user.bDate;
            }
                break;
            default:
                break;
        }
    }
    else if (index.section == 2)
    {
        return APPDelegate.user.country;
    }
    else if (index.section == 3)
    {
        return APPDelegate.user.about;
    }
    
    return @"";
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[SettingSource source] rowsForSection:section];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[SettingSource source] sections];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    identifier = [[SettingSource source] identifierForCellInRow:indexPath.row inSection:indexPath.section];
    SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        Class cellClass = [[SettingSource source] classForCellInRow:indexPath.row inSection:indexPath.section];
        cell = [[[cellClass alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
        
        if (indexPath.section == 0)
        {
            NSString *_loc_titile = [[SettingSource source] nameRow:indexPath.row inSection:indexPath.section];
           [cell setName:Loc(_loc_titile)];
            
            __block UIImage *image = nil;
            DispatchTask *task = [DispatchTask taskWithExecuteBlock:^(DispatchTask *newTask) {
                image =     [[DataSource source] cashedImageWithoutRequestForURL:[NSURL URLWithString:APPDelegate.user.avatar]];
            } andCompletitionBlock:^(DispatchTask *item)
                                  {
                                      [(SettingsCell *)cell  setImage:image];
                                  }];
            [[DispatchTools Instance] addTask:task];
        }

    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;

    cell.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1];
    if (indexPath.section != 0)
    {
        NSString *_loc_titile = [[SettingSource source] nameRow:indexPath.row inSection:indexPath.section];
        cell.textLabel.text = Loc(_loc_titile);
    }
    
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.textColor = [UIColor colorWithRed:8.f/255 green:102.f/255 blue:166.f/255 alpha:1.f];
    cell.detailTextLabel.text = [self detailValueForIndex:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsCell *cell = (SettingsCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(setEditableTextField:)])
    {
        self.editableCell = cell;
        [(SettingCellWithTextField *)cell setEditableTextField:YES];
        [(SettingCellWithTextField *)cell setValueForTextField:cell.detailTextLabel.text];
        [(SettingCellWithTextField *)cell becomeFirstResponderTextField];
    }

    cell.detailTextLabel.alpha = 0;
    self.currentIndexPath = indexPath;
    
    NSArray *rowsArray = [categoriesMenu objectAtIndex:indexPath.section];
    NSString *SELName = [rowsArray objectAtIndex:indexPath.row];
    [self performSelector:NSSelectorFromString(SELName)];    
   
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsCell *cell = (SettingsCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil)
    {
        cell = (SettingsCell *)self.editableCell;
    }
    cell.detailTextLabel.alpha = 1;
    if ([cell respondsToSelector:@selector(setEditableTextField:)])
    {
        [(SettingCellWithTextField *)cell setEditableTextField:NO];
        [(SettingCellWithTextField *)cell resignFirstResponderTextField];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 44.f;
    if (indexPath.section == 3 || (indexPath.section == 1 && indexPath.row == 0))
    {
        height = [AppHelper getCellSizeForText:[self detailValueForIndex:indexPath] font:[UIFont fontWithName:@"Helvetica" size:18] width:200];
        if (height < 44)
            height = 44.f;
    }
    return height;
}

#pragma  mark - ChangePasswordPopupDelegate

- (void) changePasswordPopup:(ChangePasswordPopup *)popup didClickToButtonWithIndex:(int)index
{
    switch (index) {
        case kOKButton:
        {
            [self changeOldPassword:[popup oldPassword]
                      toNewPassword:[popup newPassword]];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case kCamera:
        {
            [self showCamera];
        }
            break;
        case kLibrary:
        {
            [self showLibrary];
        }
            break;
        case kCancel:
        {
            //[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void) showCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = (id)self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = YES;
        [self presentViewController:picker animated:YES completion:^{
            
        }];
    }
}

- (void) showLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = (id)self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:^{
            
        }];
    }

}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    dbgLog(@"info = %@", info);
    UIImage *image = [info  objectForKey:UIImagePickerControllerOriginalImage];
    image = [image fixOrientation];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self uploadPhotoForProfile:image];
    }];
}

#pragma mark DataPicker

- (int)  selectedRowOfDataPickerView:(DataPickerView *)dataPicker
{
    return self.selectedCountryRow;
}

@end
