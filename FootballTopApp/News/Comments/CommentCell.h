//
//  CommentCell.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/1/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Comment;

@interface CommentCell : UITableViewCell
{
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *bodyLabel;

+ (CommentCell *) loadCell;

- (void) setComment:(Comment *)comment;

@end
