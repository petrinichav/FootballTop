//
//  ItemsListViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/27/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"

@interface ItemsListViewController : UIViewController<MNMBottomPullToRefreshManagerClient>
{
    IBOutlet UITableView            *table;
    
    MNMBottomPullToRefreshManager   *_refreshManager;
    CGFloat lastOffset;
    
    NSMutableArray                  *itemsArray;
    
    int page;
    int itemType;
    
    NSString                        *typeObjects;
}

@property (copy) NSString *typeObjects;

- (void) setItems:(NSArray *)array typeItem:(int)type title:(NSString *)title;

@end
