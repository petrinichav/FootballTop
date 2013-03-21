//
//  HorizontalItemsView.h
//  iPhoneMediaViewer
//
//  Created by destman on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemsView.h"

@interface HorizontalItemsView : ItemsView
{
    IBOutlet UIButton   *nextPageButton;
    IBOutlet UIButton   *prevPageButton;
    UIPageControl       *_pageControl;
    CGSize              _oldSize;
}

@property (retain)      IBOutlet UIPageControl           *pageControl;
@property (readonly)    int      curPage;

- (IBAction) scrollToNextPage;
- (IBAction) scrollToPrevPage;

@end
