//
//  DataPickerView.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/28/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum FTPickerType
{
    FTPickerTypeDate    = 0,
    FTPickerTypeData    = 1,
} FTPickerType;

typedef void (^DatPickerBlock)(id object);

@class DataPickerView;

@protocol DataPickerViewDelegate <NSObject>

@optional
    - (void) dataPickerViewDidClickDoneButton:(DataPickerView *)dataPicker;
    - (int)  selectedRowOfDataPickerView:(DataPickerView *)dataPicker;


@end

@interface DataPickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIView *overlayView;
}

@property (nonatomic)  BOOL isShowing;
@property (nonatomic, assign) id<DataPickerViewDelegate> dataPickerDelegate;
@property (nonatomic, copy) DatPickerBlock block;

+ (DataPickerView *) loadPickerWithType:(FTPickerType) type;

- (void) showInView:(UIView *)view;
- (void) showInView:(UIView *)view withOffset:(CGFloat ) offset;
- (void) hide;

@end
