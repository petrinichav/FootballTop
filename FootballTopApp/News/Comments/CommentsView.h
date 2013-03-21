//
//  CommentsView.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/26/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"

@class News;

@protocol CommentsViewDelegate <NSObject>

- (void) hideCommentsView;

@end

@interface CommentsView : UIView
{
    NSMutableArray *commentsArray, *heightCellArray;
    
    int objID;
    
    BOOL     isShowing;
}

@property (nonatomic, retain) IBOutlet UITableView *commentsTable;
@property (nonatomic, retain) IBOutlet UILabel     *commentsLbl;
@property (nonatomic) int page;
@property (nonatomic) int numberOfComments;

@property (nonatomic, assign) id <CommentsViewDelegate> delegate;

+ (CommentsView *) commentsViewForObjectID:(int)ID;

- (void) uploadComments;

- (void) showInView:(UIView *) view;
- (void) hide;

@end
