//
//  CommentsView.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/26/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "CommentsView.h"
#import "News.h"
#import "NetworkTaskGenerator.h"
#import "Comment.h"
#import "CommentCell.h"

@implementation CommentsView

+ (CommentsView *) commentsViewForObjectID:(int)ID
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"CommentsView" owner:self options:NULL];
    CommentsView* view = [objects objectAtIndex:0];
    [Localization localizeView:view];
    [view getCommentsForID:ID];
    return view;
}

- (void) setNumberOfComments:(int)numberOfComments
{
    _numberOfComments = numberOfComments;
    self.commentsLbl.text = [NSString stringWithFormat:@"%d комментариев", numberOfComments];
}

- (void) uploadComments
{
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForGetCommentsForNewsID:objID page:self.page limit:LIMIT_ITEMS_ON_PAGE completeBlock:^(DispatchTask *item) {
                                  if (((NetworkTaskGenerator *)item).isSuccessful)
                                  {                                      
                                      NSArray *response = [(NetworkTaskGenerator *)item objectFromString];
                                      dbgLog(@"response = %@", response);
                                      
                                      for (NSDictionary *dict in response)
                                      {
                                          Comment *comment = [Comment new];
                                          [comment setCommentData:dict];
                                          CGFloat height = 80 + [comment heightBodyText];
                                          [heightCellArray addObject:[NSNumber numberWithFloat:height]];
                                          [commentsArray addObject:comment];
                                          [comment release];
                                      }
                                      self.commentsTable.delegate = (id)self;
                                      self.commentsTable.dataSource = (id)self;
                                      [self.commentsTable reloadData];                                      
                                      
                                      [self.commentsTable sizeToFit];
                                      
                                      self.page++;
                                      
                                  }
    }];
    [[DispatchTools Instance] addTask:task];
}

- (void) getCommentsForID:(int)ID
{
    [Localization localizeView:self];
    
    objID = ID;
    
    commentsArray = [[NSMutableArray alloc] init];
    heightCellArray = [[NSMutableArray alloc] init];
    [self uploadComments];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCommentsView:)];
    [self addGestureRecognizer: recognizer];
    [recognizer release];
}

- (void) dealloc
{
    [_commentsTable release];
    _commentsTable = nil;
    [_commentsLbl release];
    _commentsLbl = nil;
    [commentsArray release];
    [super dealloc];
}

- (IBAction) addComment:(id)sender
{
    [LoadingView showInView:self];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForAddCommentForNodeId:objID comment:@"New comment" completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSDictionary *response = [(NetworkTaskGenerator *) item objectFromString];
            dbgLog(@"add comment %@", response);
            Comment *newComment = [Comment new];
            newComment.authorName = [response objectForKey:@"name"];
            newComment.body = [response objectForKey:@"subject"];
            newComment.timeCreated = [[response objectForKey:@"created"] doubleValue];
            [commentsArray insertObject:newComment atIndex:0];
            
            CGFloat height = 80 + [newComment heightBodyText];
            [heightCellArray addObject:[NSNumber numberWithFloat:height]];

            [newComment release];
            
            [self.commentsTable reloadData];            
        }
        [LoadingView hide];
    }];
    
    [[DispatchTools Instance] addTask:task];
}

- (IBAction) showOtherComments:(id)sender
{
    [self uploadComments];
}

- (void) hideCommentsView:(UITapGestureRecognizer *) recognizer
{
    [self hide];
}

- (void) showInView:(UIView *) view
{
    if (isShowing)
        return;
    
    __block CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 415;
    self.frame = frame;
    
    [view addSubview:self];
    
    isShowing = YES;
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         frame.origin.y -= self.frame.size.height;
                         self.frame = frame;
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void) hide
{
    if (!isShowing)
        return;
    
    __block CGRect frame = self.frame;
    
    isShowing = NO;
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         frame.origin.y += self.frame.size.height;
                         self.frame = frame;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         [self.delegate hideCommentsView];
                     }];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [commentsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"CommentCell";
    CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [CommentCell loadCell];       
    }
    [cell setComment:[commentsArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [[heightCellArray objectAtIndex:indexPath.row] floatValue];
    return height;
}

@end
