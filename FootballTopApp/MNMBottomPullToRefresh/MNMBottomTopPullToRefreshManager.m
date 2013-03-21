//
//  MNMBottomTopPullToRefreshManager.m
//  ElementsForOtherProjects
//
//  Created by Alex Petrinich on 10/2/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "MNMBottomTopPullToRefreshManager.h"
#import "MNMBottomPullToRefreshView.h"

@implementation MNMBottomTopPullToRefreshManager

- (void)dealloc {
     
    [pullToRefreshTopView_ release];
    pullToRefreshTopView_ = nil;
     
    [super dealloc];
}

- (id) initWithPullToRefreshViewHeight:(CGFloat)height tableView:(UITableView *)table withClient:(id<MNMBottomPullToRefreshManagerClient>)client
{
    if ((self = [super initWithPullToRefreshViewHeight:height tableView:table withClient:client]))
    {
        pullToRefreshTopView_ = [[MNMBottomPullToRefreshView alloc] initWithTopFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(table_.frame), -height)];
        [table_ addSubview:pullToRefreshTopView_];
    }
    
    return self;
}

- (void)  setPullToRefreshViewVisible:(BOOL)visible
{
    [super setPullToRefreshViewVisible:visible];
    pullToRefreshTopView_.hidden = !visible;
}

- (void) tableViewScrolledDown
{
    if (!pullToRefreshTopView_.hidden && !pullToRefreshTopView_.isLoading) {
        
        CGFloat offset = table_.contentOffset.y;
        CGFloat height = pullToRefreshTopView_.frame.size.height;
        
        if (offset <= 0.0f && -offset <= height) {
            
            [pullToRefreshTopView_ changeStateOfControl:MNMBottomPullToRefreshViewStatePull withOffset:offset];
            
        } else {
            
            [pullToRefreshTopView_ changeStateOfControl:MNMBottomPullToRefreshViewStateRelease withOffset:CGFLOAT_MAX];
            
        }
    }
    
}

- (void) tableViewReleasedDown
{
    if (!pullToRefreshTopView_.hidden && !pullToRefreshTopView_.isLoading) {
        
        CGFloat offset = table_.contentOffset.y;
        CGFloat height = pullToRefreshTopView_.frame.size.height;
        
        if (offset <= 0.0f &&  -offset >= height) {
            [client_ MNMTopPullToRefreshManagerClientReloadTable];
            
            [pullToRefreshTopView_ changeStateOfControl:MNMBottomPullToRefreshViewStateLoading withOffset:CGFLOAT_MAX];
            
            [UIView animateWithDuration:0.2f animations:^{
                
                table_.contentInset = UIEdgeInsetsMake(height, 0.0f, 0.0f, 0.0f);
            }];
        }
    }
}

- (void) tableViewReloadFinished
{
    [super tableViewReloadFinished];
    [pullToRefreshTopView_ changeStateOfControl:MNMBottomPullToRefreshViewStateIdle withOffset:CGFLOAT_MAX];
}


@end
