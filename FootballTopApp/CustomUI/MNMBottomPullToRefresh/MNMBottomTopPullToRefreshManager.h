//
//  MNMBottomTopPullToRefreshManager.h
//  ElementsForOtherProjects
//
//  Created by Alex Petrinich on 10/2/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "MNMBottomPullToRefreshManager.h"

@interface MNMBottomTopPullToRefreshManager : MNMBottomPullToRefreshManager
{
    MNMBottomPullToRefreshView *pullToRefreshTopView_;
}

- (void) tableViewScrolledDown;
- (void) tableViewReleasedDown;

@end
