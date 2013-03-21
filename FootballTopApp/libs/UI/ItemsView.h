//
//  StripView.h
//  iPhoneMediaViewer
//
//  Created by Alex Petrinich on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemCell.h"

@class ItemsView;

@protocol ItemsViewDataSource
@required
- (int)         itemsCountInItemsView:(ItemsView *) view;
- (ItemCell*)   cellForItemsView:(ItemsView*)view  atIndex:(int)index;
@end

@protocol ItemsViewDelegate
@required
- (CGSize)  cellSizeInItemsView:(ItemsView *)view;
@optional
- (void)    itemActionInItemsView:(ItemsView *) view atIndex:(int)index;

- (void)    itemsViewDidBeginEdit:(ItemsView *) view;
- (void)    itemsView:(ItemsView *)view deleteCellAtIndex:(int)index;
- (void)    itemsView:(ItemsView *)view moveCellAtIndex:(int)index1  toIndex:(int)index2;
@end

@interface ItemsView : UIScrollView
{
	id<ItemsViewDataSource> itemsViewDataSource;
	id<ItemsViewDelegate>	itemsViewDelegate;

	NSMutableArray *_freeItems,*_displayItems;
	
	int				_nItems,_selectedIndex;
	CGSize			_cellSize;
}

@property (assign) int selectedIndex;
@property (assign) IBOutlet id<ItemsViewDataSource> itemsViewDataSource;
@property (assign) IBOutlet id<ItemsViewDelegate>   itemsViewDelegate;
- (void)        reloadData;
- (void)        updateItems;
- (void)        updateAndClearItems;

- (ItemCell *)  findVisibleCellAtPoint:(CGPoint) point;
- (ItemCell *)  findVisibleCellWithIndex:(int) index;

- (ItemCell *)  dequeueReusableCell;
- (ItemCell *)  dequeueReusableCellWithClass:(Class)cellClass;
- (void)        queueResuableCell:(ItemCell *)cell;

@end
