//
//  StripCell.m
//  iPhoneMediaViewer
//
//  Created by destman on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ItemCell.h"
#import "ItemsView.h"

@implementation ItemCell

@synthesize cellIndex = _cellIndex;

- (void)dealloc
{
    [super dealloc];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
}

- (void) setEditing:(BOOL)editing   animated:(BOOL)animated
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    ItemsView *itemsView = (ItemsView *)self.superview;
    [itemsView setSelectedIndex:_cellIndex];
}

- (void) cellDidShow
{
}


@end
