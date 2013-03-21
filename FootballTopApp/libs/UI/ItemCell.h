//
//  StripCell.h
//  iPhoneMediaViewer
//
//  Created by destman on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemCell : UIView
{
    int     _cellIndex;
}

@property (assign) int  cellIndex;

- (void) setSelected:(BOOL)selected animated:(BOOL)animated;
- (void) setEditing:(BOOL)editing   animated:(BOOL)animated;
- (void) cellDidShow;

@end
