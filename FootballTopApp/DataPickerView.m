//
//  DataPickerView.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/28/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "DataPickerView.h"
#import "SettingSource.h"

@implementation DataPickerView

+ (DataPickerView *) loadPickerWithNubName:(NSString *)nib
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:nib owner:self options:NULL];
    DataPickerView *view = [objects objectAtIndex:0];
    view.isShowing = YES;
    [view createOverlay];
    return view;
}

+ (DataPickerView *) loadPickerWithType:(FTPickerType) type
{
    DataPickerView *view = nil;
    switch (type) {
        case FTPickerTypeDate:
        {
            view = [self loadPickerWithNubName:@"DatePickerView"];
            UIDatePicker *picker = (UIDatePicker *)ViewInViewWithID(view, ID_PICKER);
            picker.maximumDate = [NSDate date];
        }
            break;
        case FTPickerTypeData:
            view = [self loadPickerWithNubName:@"CountriesPickerView"];
            break;
        default:
            break;
    }
    
    return view;
}

- (void) dealloc
{
    [overlayView release];
    overlayView = nil;
    [super dealloc];
}

- (void) createOverlay
{
    overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = 0.f;
}

- (void) setSelectedRow
{
    UIPickerView *picker = (UIPickerView *)ViewInViewWithID(self, ID_PICKER);
    if ([picker isKindOfClass:[UIPickerView class]])
    {
        [picker selectRow:[self.dataPickerDelegate selectedRowOfDataPickerView:self]
              inComponent:0 animated:NO];
    }
}

#pragma mark - Logic

- (void) showInView:(UIView *)view
{
    if (self.isShowing)
    {        
        __block CGRect frame = self.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        self.frame  = frame;
        [view addSubview:overlayView];
        [view addSubview:self];
        
        [UIView animateWithDuration:0.2 animations:^{
            frame.origin.y -= frame.size.height+60;
            self.frame = frame;
            overlayView.alpha = 0.5;
        } completion:^(BOOL finished) {
        }];
        self.isShowing = NO;
    }
}

- (void) showInView:(UIView *)view withOffset:(CGFloat ) offset
{
    if (self.isShowing)
    {
        __block CGRect frame = self.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        self.frame  = frame;
        [view addSubview:overlayView];
        [view addSubview:self];
        
        [UIView animateWithDuration:0.2 animations:^{
            frame.origin.y -= frame.size.height+offset;
            self.frame = frame;
            overlayView.alpha = 0.7;
        } completion:^(BOOL finished) {
        }];
        self.isShowing = NO;
    }
}

- (void) hide
{
    if (!self.isShowing)
    {
        if ([self typePicker] == FTPickerTypeDate)
        {
            [self postDate];
        }
        else
        {
            [self postCountry];
        }
        
        __block CGRect frame = self.frame;
        
        [UIView animateWithDuration:0.2 animations:^{
            frame.origin.y += frame.size.height-60;
            self.frame = frame;
            overlayView.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [overlayView removeFromSuperview];
        }];
        self.isShowing = YES;
    }
}

- (FTPickerType) typePicker
{
    if ([ViewInViewWithID(self, ID_PICKER) isKindOfClass:[UIPickerView class]])
        return FTPickerTypeData;
    else
        return FTPickerTypeDate;
}

- (void) postDate
{
    UIDatePicker *picker = (UIDatePicker *)ViewInViewWithID(self, ID_PICKER);
    NSDate *date = [picker date];
    NSString *bDate = [AppHelper date:[NSDate dateWithTimeIntervalSinceNow:[date timeIntervalSinceNow]] withFormat:@"dd/MM/yyyy"];
    dbgLog(@"bDate = %@", bDate);
    self.block(bDate);
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"PickerValue" object:bDate];
}

- (void) postCountry
{
    UIPickerView *picker = (UIPickerView *)ViewInViewWithID(self, ID_PICKER);
    int row = [picker selectedRowInComponent:0];
    NSMutableDictionary *country = [NSMutableDictionary dictionaryWithDictionary:[[[SettingSource source] countries] objectAtIndex:row]];
    [country setObject:[NSNumber numberWithInt:row] forKey:@"Row"];
    self.block(country);
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"PickerValue" object:country];
}

- (IBAction) date:(id)sender
{
    
}

- (IBAction) done:(id)sender
{
    [self hide];
}

- (IBAction) previosElement:(id)sender
{
    switch ([self typePicker]) {
        case FTPickerTypeData:
        {
             UIPickerView *picker = (UIPickerView *)ViewInViewWithID(self, ID_PICKER);
            @try {
                int row = [picker selectedRowInComponent:0]-1;
                if (row < 0)
                    row = 0;
                [picker selectRow:row inComponent:0 animated:YES];
            }
            @catch (NSException *exception) {
                dbgLog(@"exep = %@", exception);
            }
           
          
        }
            break;
            
        default:
            break;
    }
}

- (IBAction) nextElement:(id)sender
{
    switch ([self typePicker]) {
        case FTPickerTypeData:
        {
            UIPickerView *picker = (UIPickerView *)ViewInViewWithID(self, ID_PICKER);
            @try {
                int row = [picker selectedRowInComponent:0]+1;
                if (row < 0)
                    row = 0;
                [picker selectRow:row inComponent:0 animated:YES];
            }
            @catch (NSException *exception) {
                dbgLog(@"exep = %@", exception);
            }
            
            
        }
            break;
            
        default:
            break;
    }

}

#pragma mark - Picker View

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[[SettingSource source] countries] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *country = [[[SettingSource source] countries] objectAtIndex:row];
    return [country objectForKey:@"Country"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //[self postCountry];
}

@end
