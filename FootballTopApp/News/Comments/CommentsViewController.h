//
//  CommentsViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 12/17/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"

@interface CommentsViewController : UIViewController
{
    NSMutableArray *commentsArray, *heightCellArray;
    
    int objectID;
    MNMBottomPullToRefreshManager   *_refreshManager;
    CGFloat lastOffset;
    
    UIView *overlayView;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) IBOutlet UITextView  *commentTextView;
@property (nonatomic, retain) IBOutlet UIView      *addCommentView;
@property (nonatomic, retain) IBOutlet UILabel     *noCommentsLbl;

- (void) showComments:(BOOL) isShow forObjectWithID:(int)ID;

- (IBAction) back:(id)sender;
- (IBAction) writeComment:(id)sender;
- (IBAction) postComment:(id)sender;

@end
