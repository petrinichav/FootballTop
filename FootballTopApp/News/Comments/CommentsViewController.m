//
//  CommentsViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 12/17/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentCell.h"
#import "Comment.h"
#import "NetworkTaskGenerator.h"
#import "AppDelegate.h"
#import "AlertModule.h"

@interface CommentsViewController ()

@property (nonatomic) int page;
@property (nonatomic) int previosPage;

@end

@implementation CommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark Recognizer

- (void) addTapRecognizer
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCommentField:)];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
}

- (void) hideCommentField:(UITapGestureRecognizer *)recognizer
{
    self.commentTextView.text = @"";
    [self.commentTextView resignFirstResponder];
    [self.view removeGestureRecognizer:recognizer];
}

#pragma mark - Notification

- (void) keyboardWillShow:(NSNotification *)notif
{
    CGRect keyboardFrame = [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.width;
    
    UIViewAnimationCurve animationCurve = [[notif.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat duration = [[notif.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (duration == 0.f)
        duration = 0.25f;
    
    [self.view insertSubview:overlayView belowSubview:self.addCommentView];
    [UIView animateWithDuration:duration delay:0
                        options:(UIViewAnimationOptions)animationCurve
                     animations:^{
                         [self textEnterFieldFrameForKeyboardHeight:keyboardHeight];
                         overlayView.alpha = 0.5;
                     } completion:^(BOOL finished) {
                         [self addTapRecognizer];
                     }];
}

- (void) keyboardWillHide:(NSNotification *)notif
{
    UIViewAnimationCurve animationCurve = [[notif.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat duration = [[notif.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (duration == 0.f)
        duration = 0.25f;
    
    [UIView animateWithDuration:duration delay:0
                        options:(UIViewAnimationOptions)animationCurve
                     animations:^{
                         [self textEnterFieldFrameForKeyboardHeight:0];
                         overlayView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [overlayView removeFromSuperview];
                     }];
}

- (void) textEnterFieldFrameForKeyboardHeight:(CGFloat) height
{
    CGRect rect =  self.addCommentView.frame;
    rect.origin.y = [UIScreen mainScreen].bounds.size.height - height + rect.size.height;
    self.addCommentView.frame = rect;
}

#pragma mark - Life cicle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Localization localizeView:self.view];
    _refreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:55 tableView:self.table withClient:(id)self];
    
    self.table.delegate = (id)self;
    self.table.dataSource = (id)self;
    [self loadTable];
    
    overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = 0;

    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning
{
    [self releaseOutlets];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) releaseOutlets
{
    [_table release];
    _table = nil;
    [_commentTextView release];
    _commentTextView = nil;
    [_addCommentView release];
    _addCommentView = nil;
    [overlayView release];
    overlayView = nil;
    [_noCommentsLbl release];
    _noCommentsLbl = nil;
}

- (void) dealloc
{
    [self releaseOutlets];
    [commentsArray release];
    [heightCellArray release];
    [super dealloc];
}

- (void) showComments:(BOOL) isShow forObjectWithID:(int)ID
{
    CGPoint centerScreen = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2-20);
    self.noCommentsLbl.center = centerScreen;
    
    if (!isShow)
        self.table.alpha = 0;
    
    objectID = ID;
    self.page = 0;
    self.previosPage = 0;
    commentsArray   = [[NSMutableArray alloc] init];
    heightCellArray = [[NSMutableArray alloc] init];
    [self uploadComments];
}

- (void) uploadComments
{
    [LoadingView showInView:self.tabBarController.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForGetCommentsForNewsID:objectID page:self.page limit:LIMIT_ITEMS_ON_PAGE completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSArray *response = [(NetworkTaskGenerator *)item objectFromString];
            dbgLog(@"response = %@", response);            
                        
            for (NSDictionary *dict in response)
            {
                Comment *comment = [Comment new];
                [comment setCommentData:dict];
                CGFloat height = 35 + [comment heightBodyText];
                [heightCellArray addObject:[NSNumber numberWithFloat:height]];
                [commentsArray addObject:comment];
                [comment release];
            }
            if ([response count] > 0)
            {
                self.table.alpha = 1;
                [self loadTable];
            
                self.page++;
            }
            else
            {
                [_refreshManager tableViewReloadFinished];
            }
            
        }
        [LoadingView hide];

    }];
    [[DispatchTools Instance] addTask:task];
}

#pragma mark - Button Actions

- (IBAction) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) writeComment:(id)sender
{
    if ([APPDelegate createdUser])
        [self.commentTextView becomeFirstResponder];
    else
    {
        [[AlertModule instance] createAlertWithType:LoginRequest  buttons:2
                                    withCancelBlock:^(UIAlertView *_alert) {
                                        
                                    } completeBlock:^(UIAlertView *_alert) {
                                        [APPDelegate popToLoginScreen];
                                    }];
        [[AlertModule instance] showAlert];
    }
}

- (IBAction) postComment:(id)sender
{
    if ([self.commentTextView.text length] == 0)
    {
        [[AlertModule instance] createAlertWithType:PostCommentError
                                            buttons:1
                                    withCancelBlock:^(UIAlertView *_alert) {
                                        
                                    } completeBlock:^(UIAlertView *_alert) {
                                        
                                    }];
        [[AlertModule instance] showAlert];
        
        return;
    }
    
    [LoadingView showInView:self.tabBarController.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForAddCommentForNodeId:objectID comment:self.commentTextView.text completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            [self.commentTextView resignFirstResponder];
            self.page = 0;
            [commentsArray removeAllObjects];
            [heightCellArray removeAllObjects];
            
            [self uploadComments];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"IncreaseComments" object:nil];
        }
        [LoadingView hide];
    }];

    [[DispatchTools Instance] addTask:task];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [[heightCellArray objectAtIndex:indexPath.row] floatValue];
    return height;
}

#pragma  mark RefreshManager

- (void)loadTable
{
    [self.table reloadData];
    [_refreshManager tableViewReloadFinished];
}

- (void) getNextPosts
{
    
    
}

- (void) getPrevPosts
{
    [self uploadComments];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (lastOffset > scrollView.contentOffset.y) {
        [_refreshManager tableViewScrolledDown];
    }
    else {
        [_refreshManager tableViewScrolledUp];
        
    }
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    lastOffset = scrollView.contentOffset.y;
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (lastOffset > scrollView.contentOffset.y) {
        [_refreshManager tableViewReleasedDown];
    }else {
        [_refreshManager tableViewReleasedUp];
    }
}

- (void) MNMBottomPullToRefreshManagerClientReloadTable
{
    [self performSelector:@selector(getPrevPosts) withObject:nil afterDelay:2];
}

- (void) MNMTopPullToRefreshManagerClientReloadTable
{
    [self performSelector:@selector(getNextPosts) withObject:nil afterDelay:2];
}


@end
