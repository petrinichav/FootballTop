/*
 * Copyright (c) 2012 Mario Negro Martín
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 */

#import "MNMBottomPullToRefreshManager.h"
#import "MNMBottomPullToRefreshView.h"

@interface MNMBottomPullToRefreshManager()

/**
 * Returns the correct offset to apply to the pull-to-refresh view, depending on contentSize
 *
 * @return The offset
 * @private
 */
- (CGFloat)tableScrollOffset;

@end

@implementation MNMBottomPullToRefreshManager

#pragma mark -
#pragma mark Memory management

/**
 * Deallocates not used memory
 */
- (void)dealloc {
    [pullToRefreshBottomView_ release];
    pullToRefreshBottomView_ = nil;
    
    [table_ release];
    table_ = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Instance initialization

/**
 * Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 * @return nil because that instance must be initialized with custom constructor
 */
- (id)init {
    return nil;
}

/*
 * Initializes the manager object with the information to link view and table
 */
- (id)initWithPullToRefreshViewHeight:(CGFloat)height tableView:(UIScrollView *)table withClient:(id<MNMBottomPullToRefreshManagerClient>)client {

    if (self = [super init]) {
        
        client_ = client;
        
        table_ = [table retain];
        
        pullToRefreshBottomView_ = [[MNMBottomPullToRefreshView alloc] initWithFrame:CGRectMake(0, 0.0f, CGRectGetWidth(table_.frame), height)];
        //pullToRefreshTopView_ = [[MNMBottomPullToRefreshView alloc] initWithTopFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(table_.frame), -height)];
        //[table_ addSubview:pullToRefreshTopView_];
        [table_ addSubview:pullToRefreshBottomView_];

    }
    
    return self;
}

#pragma mark -
#pragma mark Visuals

/*
 * Returns the correct offset to apply to the pull-to-refresh view, depending on contentSize
 */
- (CGFloat)tableScrollOffset {
    
    CGFloat offset = 0.0f;        
    
    if (table_.contentSize.height < table_.frame.size.height) {
        
        offset = -table_.contentOffset.y;
        
    } else {
        
        offset = (table_.contentSize.height - table_.contentOffset.y) - table_.frame.size.height;
    }
    return offset;
}

/*
 * Relocate pull-to-refresh view
 */
- (void)relocatePullToRefreshView {
    
    CGFloat yCoord = 0.0f;
    
    if (table_.contentSize.height >= table_.frame.size.height) {
        
        yCoord = table_.contentSize.height;
        
    } else {
        
        yCoord = table_.frame.size.height;
        
    }
    
    CGRect frame = pullToRefreshBottomView_.frame;
    frame.origin.y = yCoord;
        
    pullToRefreshBottomView_.frame = frame;

    //[table_ addSubview:pullToRefreshBottomView_];
}

/*
 * Sets the pull-to-refresh view visible or not. Visible by default
 */
- (void)setPullToRefreshViewVisible:(BOOL)visible {
    pullToRefreshBottomView_.hidden = !visible;
    //pullToRefreshTopView_.hidden = !visible;
}

#pragma mark -
#pragma mark Table view scroll management

/*
 * Checks state of control depending on tableView scroll offset
 */
- (void)tableViewScrolledUp 
{
   
    if (!pullToRefreshBottomView_.hidden && !pullToRefreshBottomView_.isLoading) {
        CGFloat offset = [self tableScrollOffset];

        CGFloat height = -CGRectGetHeight(pullToRefreshBottomView_.frame);

        
        
        if (offset <= 0.0f && offset >= height) {

            [pullToRefreshBottomView_ changeStateOfControl:MNMBottomPullToRefreshViewStatePull withOffset:offset];
            
        } else {
            
            [pullToRefreshBottomView_ changeStateOfControl:MNMBottomPullToRefreshViewStateRelease withOffset:CGFLOAT_MAX];
        }
    }
    
}

- (void) tableViewScrolledDown
{
//    if (!pullToRefreshTopView_.hidden && !pullToRefreshTopView_.isLoading) {
//        
//        CGFloat offset = table_.contentOffset.y;
//        CGFloat height = pullToRefreshTopView_.frame.size.height;
//        
//        if (offset <= 0.0f && -offset <= height) {
//            
//            [pullToRefreshTopView_ changeStateOfControl:MNMBottomPullToRefreshViewStatePull withOffset:offset];
//            
//        } else {
//            
//            [pullToRefreshTopView_ changeStateOfControl:MNMBottomPullToRefreshViewStateRelease withOffset:CGFLOAT_MAX];
//            
//        }
//    }

}

/*
 * Checks releasing of the tableView
 */
- (void)tableViewReleasedUp 
{
    
    if (!pullToRefreshBottomView_.hidden && !pullToRefreshBottomView_.isLoading) {
        
        CGFloat offset = [self tableScrollOffset];
        CGFloat height = -CGRectGetHeight(pullToRefreshBottomView_.frame);
        
        if (offset <= 0.0f && offset < height) {
            
            [client_ MNMBottomPullToRefreshManagerClientReloadTable];
            
            [pullToRefreshBottomView_ changeStateOfControl:MNMBottomPullToRefreshViewStateLoading withOffset:CGFLOAT_MAX];
            
            [UIView animateWithDuration:0.2f animations:^{
                
                if (table_.contentSize.height >= table_.frame.size.height) {
                
                    table_.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, -height, 0.0f);
                    
                } else {
                    
                    table_.contentInset = UIEdgeInsetsMake(height, 0.0f, 0.0f, 0.0f);
                }
            }];
        }
    }
    

}

- (void) tableViewReleasedDown
{
//    if (!pullToRefreshTopView_.hidden && !pullToRefreshTopView_.isLoading) {
//        
//        CGFloat offset = table_.contentOffset.y;
//        CGFloat height = pullToRefreshTopView_.frame.size.height;
//        
//        if (offset <= 0.0f &&  -offset >= height) {
//            [client_ MNMTopPullToRefreshManagerClientReloadTable];
//            
//            [pullToRefreshTopView_ changeStateOfControl:MNMBottomPullToRefreshViewStateLoading withOffset:CGFLOAT_MAX];
//            
//            [UIView animateWithDuration:0.2f animations:^{
//                
//                table_.contentInset = UIEdgeInsetsMake(height, 0.0f, 0.0f, 0.0f);
//            }];
//        }
//    }
}

/*
 * The reload of the table is completed
 */
- (void)tableViewReloadFinished {
    
    table_.contentInset = UIEdgeInsetsZero;
    
    [self relocatePullToRefreshView];
    
    //[pullToRefreshTopView_ changeStateOfControl:MNMBottomPullToRefreshViewStateIdle withOffset:CGFLOAT_MAX];
    [pullToRefreshBottomView_ changeStateOfControl:MNMBottomPullToRefreshViewStateIdle withOffset:CGFLOAT_MAX];
    
}

@end