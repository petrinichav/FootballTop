//
//  StripView.m
//  iPhoneMediaViewer
//
//  Created by Alex Petrinich on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ItemsView.h"

@implementation ItemsView


- (void) _init
{
	_freeItems = [[NSMutableArray alloc] init];
	_displayItems = [[NSMutableArray alloc] init];    
    _selectedIndex = -1;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super initWithCoder:aDecoder]))
	{
		[self _init];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
	{
		[self _init];
    }
    return self;
}

-(void) awakeFromNib
{
    //[self reloadData];
}

- (void)dealloc 
{
	[_displayItems release];
	[_freeItems release];   
	[super dealloc];
}

#pragma mark Reusable Cells

-(ItemCell *) findVisibleCellWithIndex:(int) index
{
    for (ItemCell *cell in _displayItems) 
    {
        if(cell.cellIndex == index)
        {
            return cell;
        }
    }
    return nil;
}

- (ItemCell *)  findVisibleCellAtPoint:(CGPoint) point
{
    for (ItemCell *cell in _displayItems) 
    {
        if(CGRectContainsPoint(cell.frame, point))
        {
            return cell;
        }
    }
    return nil;
}


- (ItemCell *) dequeueReusableCell
{
    ItemCell *cell = nil;
    
    if([_freeItems count])
    {
        cell = [[_freeItems lastObject] retain];
        [_freeItems removeLastObject];
    }
    return [cell autorelease];
}

- (ItemCell *)  dequeueReusableCellWithClass:(Class)cellClass
{
    ItemCell *cell = nil;
    for (id nextItem in _freeItems)
    {
        if([nextItem class]==cellClass)
        {
            cell = [nextItem retain];
            [_freeItems removeObject:cell];
            break;
        }
    }
    return [cell autorelease];
}

- (void)        queueResuableCell:(ItemCell *)cell
{
    [_freeItems addObject:cell];
}

#pragma mark Properties
- (id<ItemsViewDataSource>) itemsViewDataSource
{
	return itemsViewDataSource;
}

- (void) setItemsViewDataSource:(id <ItemsViewDataSource>) val
{
	itemsViewDataSource = val;
}

- (void) setItemsViewDelegate:(id<ItemsViewDelegate>)val
{
    itemsViewDelegate = val;
}

- (id<ItemsViewDelegate>) itemsViewDelegate
{
    return itemsViewDelegate;
}

- (void) updateItems
{
    CGRect	rtScroll = self.bounds;
	int count = [_displayItems count];
	for (int i=0;i<count;) 
	{
		ItemCell *cell = [_displayItems objectAtIndex:i];
		CGRect rt = cell.frame;
		if(!CGRectIntersectsRect(rt, rtScroll))
		{
            [self queueResuableCell:cell];
			[cell removeFromSuperview];
            [_displayItems removeObject:cell];
			count --;
		}else
        {
            i++;
        }
	} 
}

- (void) clearData
{
	for(ItemCell *cell in _displayItems)
	{
        [self queueResuableCell:cell];
		[cell removeFromSuperview];
	}
	[_displayItems removeAllObjects];    
}

- (void) reloadData
{
    [self clearData];
    _nItems = [itemsViewDataSource itemsCountInItemsView:self];
    _cellSize = [itemsViewDelegate cellSizeInItemsView:self];
}

- (void) updateAndClearItems
{
    [self clearData];
}

- (int) selectedIndex
{
	return _selectedIndex;
}

- (void) setSelectedIndex:(int)selectedIndex
{
    ItemCell *cell = [self findVisibleCellWithIndex:_selectedIndex];
    [cell setSelected:NO animated:YES];
    
    _selectedIndex = selectedIndex;

    cell = [self findVisibleCellWithIndex:_selectedIndex];
    [cell setSelected:YES animated:YES];
    if ([(NSObject *)itemsViewDelegate respondsToSelector:@selector(itemActionInItemsView:atIndex:)])
    {
        [itemsViewDelegate itemActionInItemsView:self atIndex:_selectedIndex];
    }
}

@end
