//
//  FilmStripView.m
//  iPhoneMediaViewer
//
//  Created by destman on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HorizontalItemsView.h"
#import <QuartzCore/QuartzCore.h>

@implementation HorizontalItemsView

-(void) dealloc
{
    [nextPageButton release];
    [prevPageButton release];
    [_pageControl release];
    [super dealloc];
}

-(CGSize) cellSize
{
    CGSize size = _cellSize;
    if(_pageControl)
    {
        size = self.frame.size;
    }
    return size;
}

-(void) updateItems
{
    [super updateItems];
    
    CGSize size = [self cellSize];
    CGRect	rtScroll = self.bounds;
    int n = floor(self.contentOffset.x / size.width);
    if(n<0)
        n = 0;
    
    CGRect rt = CGRectMake(size.width*n, 0, size.width, size.height);
    while(CGRectIntersectsRect(rt, rtScroll)&&n<_nItems)
    {
        ItemCell *cell = [self findVisibleCellWithIndex:n];
        if(cell == nil)
        {
            cell = [itemsViewDataSource cellForItemsView:self atIndex:n];
            [self addSubview:cell];
            [cell cellDidShow];
            [_displayItems addObject:cell];            
        }
        cell.cellIndex = n;
        [cell setSelected:n==_selectedIndex animated:NO];
        cell.frame = rt;
        rt.origin.x += size.width;
        n++;
    }    
}

- (void) changePageAnimated:(BOOL)animated
{
    int curPage = _pageControl.currentPage;
    CGSize size = [self cellSize];
    [self setContentOffset:CGPointMake(curPage*size.width, 0) animated:animated];
}

- (void) pageChanged
{
    [self changePageAnimated:YES];
}

- (IBAction) scrollToNextPage
{
    int nextPage = _pageControl.currentPage+1;
    if(nextPage<_pageControl.numberOfPages)
    {
        _pageControl.currentPage = nextPage;
        [self pageChanged];
    }
}

- (IBAction) scrollToPrevPage
{
    int nextPage = _pageControl.currentPage-1;
    if(nextPage>=0)
    {
        _pageControl.currentPage = nextPage;
        [self pageChanged];
    }
}

- (IBAction) rightArrow:(id)sender
{
    CGSize cellSize = [self cellSize];
    CGPoint curOffset = self.contentOffset;
    CGPoint newOffset = CGPointMake(curOffset.x + cellSize.width, curOffset.y);
    
    int n = floor(newOffset.x / cellSize.width);
    if (n+2 > _nItems)
    {
        return;
    }
    [self setContentOffset:newOffset animated:YES]; 

}

- (IBAction) leftArrow:(id)sender
{
    CGSize cellSize = [self cellSize];
    CGPoint curOffset = self.contentOffset;
    CGPoint newOffset = CGPointMake(curOffset.x - cellSize.width, curOffset.y);
    
    int n = floor(newOffset.x / cellSize.width);
    if (n < 0)
    {
        return;
    }
    [self setContentOffset:newOffset animated:YES];
}

- (int) curPage
{
    return _pageControl.currentPage;
}

- (void) updatePageButtonsVisibility
{
    int numberOfPages = self.contentSize.width/self.bounds.size.width;
    if(numberOfPages<1)
        numberOfPages = 1;
    int curPage = self.contentOffset.x/self.bounds.size.width;
    if(curPage<0)
        curPage = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    prevPageButton.alpha = (curPage==0)?0:1;
    nextPageButton.alpha = (curPage==(numberOfPages-1))?0:1;
    [UIView commitAnimations];
}

- (void) updateScrollContentButtonsVisibility
{
    CGSize cellSize = [self cellSize];
    int n = floor(self.contentOffset.x / cellSize.width);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    prevPageButton.alpha = (n<=0)?0:1;
    nextPageButton.alpha = (n>=(_nItems-2))?0:1;
    [UIView commitAnimations];
}

- (void) updatePageControl
{
    if(_pageControl && [[self.layer animationKeys] count]==0)
    {   
        CGSize size = self.frame.size;
        int numberOfPages = self.contentSize.width/size.width;
        if(numberOfPages<1)
            numberOfPages = 1;
        int curPage = self.contentOffset.x/size.width;
        if(curPage<0)
            curPage = 0;
        
        _pageControl.numberOfPages = numberOfPages;
        _pageControl.currentPage = curPage;
        [self updatePageButtonsVisibility];
    }
    else 
        [self updateScrollContentButtonsVisibility];
}

- (void) setPageControl:(UIPageControl *)pageControl
{
    if(pageControl!=_pageControl)
    {
        [_pageControl removeTarget:self action:@selector(pageChanged) forControlEvents:UIControlEventValueChanged];
        [_pageControl release];
        _pageControl = [pageControl retain];
        [_pageControl addTarget:self action:@selector(pageChanged) forControlEvents:UIControlEventValueChanged];
        self.pagingEnabled = YES;
    }
}

- (UIPageControl *)pageControl
{
    return _pageControl;
}

- (void) setAlpha:(CGFloat)alpha
{
    [super setAlpha:alpha];
    if(alpha==0)
    {
        nextPageButton.alpha = alpha;
        prevPageButton.alpha = alpha;
    }else
    {
        [self updatePageButtonsVisibility];
    }
}

- (void) updateContentSize
{
    CGSize size = [self cellSize];
    if(!CGSizeEqualToSize(size, _oldSize))
    {
        _oldSize = size;
        CGSize contentSize = CGSizeMake(size.width*_nItems, 0);
        if (contentSize.width == 0)
        {
            contentSize.width = 1;
        }
        self.contentSize = contentSize;
        [self changePageAnimated:NO];
    }
}

- (void) layoutSubviews
{
	[super layoutSubviews];
    [self  updateContentSize];
	[self  updateItems];
    [self  updatePageControl];
}

- (void)reloadData
{
    [super reloadData];
    CGSize size = [self cellSize];
    CGSize contentSize = CGSizeMake(size.width*_nItems, 0);
    if (contentSize.width == 0)
    {
        contentSize.width = 1;
    }
    self.contentSize = contentSize;
    [self  pageChanged];
    [self  updatePageControl];
	[self  updateItems];
}

- (void) updateAndClearItems
{
    [super updateAndClearItems];
    [self updateItems];
}

@end
