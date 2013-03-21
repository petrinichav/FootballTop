//
//  FeedViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/5/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomTopPullToRefreshManager.h"

extern NSString *const kDefaultNews;
extern NSString *const kMaterialNews;

@interface FeedViewController : UIViewController
{
    IBOutlet UITableView      *table;
    NSMutableArray            *newsList;
    
    int newsViewMode;
    
    MNMBottomTopPullToRefreshManager   *_refreshManager;
    CGFloat lastOffset;
    int page;
    
    CGPoint  beginingPoint;

}

@property (nonatomic) int categoryID;
@property (nonatomic, retain) IBOutlet UIView *contentView;

- (void) setNews:(NSArray *) newsArray viewMode:(int)viewMode;

- (IBAction) back:(id)sender;
- (IBAction) search:(id)sender;
- (IBAction) updateNewsMode:(UIButton *)sender;

@end
