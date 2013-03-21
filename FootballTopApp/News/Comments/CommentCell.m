//
//  CommentCell.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/1/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "CommentCell.h"
#import "Comment.h"
#import "DispatchTools.h"
#import "DataSource.h"

@implementation CommentCell

- (void) dealloc
{
    [_titleLabel release];
    _titleLabel = nil;
    [_timeLabel release];
    _timeLabel = nil;
    [_bodyLabel release];
    _bodyLabel = nil;
    [super dealloc];
}

+ (CommentCell *) loadCell
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:NULL];
    CommentCell* cell = [objects objectAtIndex:0];
    return cell;
}

- (void) setComment:(Comment *)comment
{
    self.titleLabel.text = comment.authorName;    
    self.bodyLabel.text = comment.body;
    self.timeLabel.text = [AppHelper date:[NSDate dateWithTimeIntervalSince1970:comment.timeCreated] withFormat:@"dd MMMM yyyy, HH:mm"];
    
    CGRect bodyRect = self.bodyLabel.frame;
    bodyRect.size.height = comment.heightBodyText;
    self.bodyLabel.frame = bodyRect;   

}

@end
