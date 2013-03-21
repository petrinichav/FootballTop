//
//  FilmStripView.m
//  iPhoneMediaViewer
//
//  Created by destman on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VerticalItemsView.h"
#import <QuartzCore/QuartzCore.h>

@implementation VerticalItemsView

-(void) dealloc
{
    [super dealloc];
}

-(void) updateItems
{
    [super updateItems];
    
    CGRect	rtScroll = self.bounds;
    int cols = rtScroll.size.width/_cellSize.width;
    int n = floor(self.contentOffset.y/_cellSize.height)*cols;
    if(n<0)
        n = 0;
    
    CGRect rt = CGRectMake(0, _cellSize.height*(n/cols),_cellSize.width,_cellSize.height);
    while(CGRectIntersectsRect(rt, rtScroll)&&n<_nItems)
    {
        ItemCell *cell = [self findVisibleCellWithIndex:n];
        if(cell == nil)
        {
            cell = [itemsViewDataSource cellForItemsView:self atIndex:n];
            [self insertSubview:cell atIndex:0];
            [cell cellDidShow];
            [_displayItems addObject:cell];            
        }
        cell.cellIndex = n;
        [cell setSelected:n==_selectedIndex animated:NO];
        cell.frame = rt;
        rt.origin.y += _cellSize.height+5;

        n++;
    }    
    
    
}

- (void) updateContentSize
{
    CGSize contentSize = CGSizeMake(0, _cellSize.height*_nItems);
    if (contentSize.height == 0)
    {
        contentSize.height = 1;
    }
    self.contentSize = contentSize;
}

- (void) layoutSubviews
{
	[super layoutSubviews];
    [self updateContentSize];
	[self  updateItems];
}

- (void)reloadData
{
    [super reloadData];
    [self  updateContentSize];
	[self  updateItems];
}

@end
