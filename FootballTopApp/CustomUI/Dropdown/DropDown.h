//
//  DropDown.h
//  WorldOfAbsinthe
//
//  Created by Alex Petrinich on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DropDown;

@protocol DropDownDelegate <NSObject>

- (void) dropDown:(DropDown *)dropDown selectItemWithIndex:(int) index;

@end

@interface DropDown : UIView<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *table;
    
    NSArray              *_data;
    
    BOOL                 isShow;
    
    id<DropDownDelegate> dropDownDelegate;
}

@property BOOL isShow;
@property (assign) id<DropDownDelegate> dropDownDelegate;

+ (id) loadViewWithDelegate:(id)delegate;
- (void) show;
- (void) hide;

- (void) setData:(NSArray *)data;
- (void) reloadData;

- (NSString *) titleActivCell;

@end
