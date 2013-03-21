//
//  FeedViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/5/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "FeedViewController.h"
#import "NetworkTaskGenerator.h"
#import "NewsCell.h"
#import "News.h"
#import "DataSource.h"
#import "NetworkTaskGenerator.h"
#import "NewsDetailsViewController.h"
#import "AppDelegate.h"
#import "NewsCategorie.h"

NSString *const kDefaultNews  = @"feed";
NSString *const kMaterialNews = @"material";

@interface FeedViewController ()

@property (nonatomic) int activNewsMode;
@property (nonatomic, retain) NSString *newsType;

@end

@implementation FeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        newsList = [[NSMutableArray alloc] init];
        self.tabBarItem.title = Loc(@"_Loc_News");
        [self.tabBarItem setFinishedSelectedImage:[Tools hiresImageNamed:@"btn_news_s.png"] withFinishedUnselectedImage:[Tools hiresImageNamed:@"btn_news.png"]];
        
        self.newsType = @"";
    }
    return self;
}

- (void) dealloc
{
    [self releaseOutlets];
    [newsList release];
    [_newsType release];
    [super dealloc];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Localization localizeView:self.contentView];
    _refreshManager = [[MNMBottomTopPullToRefreshManager alloc] initWithPullToRefreshViewHeight:55 tableView:table withClient:(id)self];
    
    self.activNewsMode = NewsViewModeTeaser;
    self.categoryID = -1;
    [LoadingView showInView:self.tabBarController.view];
    [self downloadNewsWithTimeStamp:-1 CompleteBlock:^{
        
    }];
       
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(showCategory:)];
    panRecognizer.delegate = (id)self;
    panRecognizer.maximumNumberOfTouches = 1;
    [self.contentView addGestureRecognizer:panRecognizer];
    [panRecognizer release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCategory:) name:@"SelectedCategory" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readMore:) name:@"ReadMore" object:nil];

}

- (void) releaseOutlets
{
    [table release];
    table = nil;
    [_refreshManager release];
    _refreshManager = nil;
    [_contentView release];
    _contentView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [self releaseOutlets];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [self releaseOutlets];
    [[DataSource source] clearImageCache];
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadTable];
}

- (void) downloadNewsWithTimeStamp:(int)timestamp CompleteBlock:(dispatch_block_t)block
{
   // [LoadingView showInView:self.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForGetListNewsWithViewMode:self.activNewsMode page:page limit:LIMIT_ITEMS_ON_PAGE
                                                                                     category:self.categoryID newsType:self.newsType
                                                                                 createdafter:timestamp
                                                                                completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSArray *response = [(NetworkTaskGenerator *)item objectFromString];
            dbgLog(@"%@", response);
            if (timestamp < 0)
                [self addNews:response];
            else
                [self addNewsToStart:response];
            [self loadTable];
            
            page++;
            
            block();
        }
        [LoadingView hide];

    }];
    [[DispatchTools Instance] addTask:task];
}

- (void) showCategoryView
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect rect = APPDelegate.navigationController.view.frame;
                         rect.origin.x = 270;
                         APPDelegate.navigationController.view.frame = rect;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void) hideCategoryView
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect rect = APPDelegate.navigationController.view.frame;
                         rect.origin.x = 0;
                         APPDelegate.navigationController.view.frame = rect;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - Recognizer

- (void) showCategory:(UIPanGestureRecognizer *)recognizer
{
    CGPoint moveLocation = [recognizer translationInView:self.contentView];
    UIGestureRecognizerState state = recognizer.state;
    if (state == UIGestureRecognizerStateBegan)
    {
        beginingPoint = moveLocation;
    }
    else if (state == UIGestureRecognizerStateEnded)
    {
        int angle = (int)atanf((moveLocation.y - beginingPoint.y)/(moveLocation.x - beginingPoint.x));
        dbgLog(@"angle = %d move = %f", angle, beginingPoint.x - moveLocation.x);
        if (angle == 0 & (beginingPoint.x - moveLocation.x) < -50)
        {
            [self showCategoryView];
        }
        else if (angle == 0 & (beginingPoint.x - moveLocation.x) > 50)
        {
            [self hideCategoryView];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}
//

#pragma mark - Buttons

- (IBAction) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) search:(id)sender
{
    AppDelegate *dlg = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [dlg showSearchControllerInNavController:self.navigationController];
}

- (IBAction) updateNewsMode:(UIButton *)sender
{
    [newsList removeAllObjects];
    page = 0;
    
    if (self.activNewsMode == NewsViewModeMini)
    {
        [sender setImage:[UIImage imageNamed:@"btn_news_mode_teaser"] forState:UIControlStateNormal];
        self.activNewsMode = NewsViewModeTeaser;
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"btn_news_mode"] forState:UIControlStateNormal];
        self.activNewsMode = NewsViewModeMini;
    }
    sender.enabled = NO;
    [self downloadNewsWithTimeStamp:-1 CompleteBlock:^{
        [table setContentOffset:CGPointZero];
        sender.enabled = YES;
    }];
}

- (void) addNews:(NSArray *) newsArray
{
    for (NSDictionary *newsInfo in newsArray)
    {
        News *news  = [News new];
        news.author = [newsInfo objectForKey:@"author"];
        news.title = [newsInfo objectForKey:@"title"];
        news.newsID = [[newsInfo objectForKey:@"nid"] intValue];
        news.comments = [[newsInfo objectForKey:@"comment_count"] intValue];
        news.pubDate = [[newsInfo objectForKey:@"created"] doubleValue];
        news.htmlBody = [newsInfo objectForKey:@"body"];
        news.bigImageURL = [newsInfo objectForKey:@"image"];
        [newsList addObject:news];
        [news release];
    }
}

- (void) addNewsToStart:(NSArray *) newsArray
{
    for (int i = [newsArray count] - 1; i >= 0; i--)
    {
        NSDictionary *newsInfo = [newsArray objectAtIndex:i];
        
        News *news  = [News new];
        news.author = [newsInfo objectForKey:@"author"];
        news.title = [newsInfo objectForKey:@"title"];
        news.newsID = [[newsInfo objectForKey:@"nid"] intValue];
        news.comments = [[newsInfo objectForKey:@"comment_count"] intValue];
        news.pubDate = [[newsInfo objectForKey:@"created"] doubleValue];
        news.htmlBody = [newsInfo objectForKey:@"body"];
        news.bigImageURL = [newsInfo objectForKey:@"image"];
        [newsList insertObject:news atIndex:0];
        [news release];
    }
}

- (void) setNews:(NSArray *) newsArray viewMode:(int)viewMode
{
    [self addNews:newsArray];
    
    self.activNewsMode = viewMode;
    page = 1;
}

- (CGFloat) heightForRowWithImage:(BOOL) isImage
{
    CGFloat height = 0;
    switch (self.activNewsMode) {
        case NewsViewModeMini:
            height = 82;
            break;
        case NewsViewModeTeaser:
            if (isImage)
                height = 286;
            else     
                height = 130;
            break;
        case NewsViewModeFull:
            height = 150;
            break;
        default:
            break;
    }
    return height;
}

- (void) openNews:(News *) news
{
    [LoadingView showInView:self.tabBarController.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForGetNewsWithID:[NSString stringWithFormat:@"%d", news.newsID] completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSArray *response = [(NetworkTaskGenerator *)item objectFromString];
            dbgLog(@"response = %@", response);
            news.htmlFullBody = [[response objectAtIndex:0] objectForKey:@"body"];
            NewsDetailsViewController *vc = [[NewsDetailsViewController alloc] initWithNibName:@"NewsDetailsViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            [vc setNews:news];
            [vc release];
        }
        [LoadingView hide];
    }];
    [[DispatchTools Instance] addTask:task];

}

#pragma mark - Tbl

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [newsList count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"";
    News *news = [newsList objectAtIndex:indexPath.row];
    if (news.bigImageURL == nil)
        identifier = @"RSSCell";
    else
        identifier = @"RSSCellWithImage";
    NewsCell *cell = (NewsCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [NewsCell loadCellForViewMode:self.activNewsMode hasImage:news.bigImageURL!=nil];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setNews:news];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    News *news = [newsList objectAtIndex:indexPath.row];
    [self openNews:news];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    News *news = [newsList objectAtIndex:indexPath.row];
    return [self heightForRowWithImage:news.bigImageURL!=nil];
}

#pragma  mark RefreshManager

- (void)loadTable
{
    [table reloadData];
    [_refreshManager tableViewReloadFinished];
}

- (void) getNextPosts
{
    page = 0;
    News *news = [newsList objectAtIndex:0];
    [self downloadNewsWithTimeStamp:news.pubDate CompleteBlock:^{
        
    }];
}

- (void) getPrevPosts
{
    [self downloadNewsWithTimeStamp:-1 CompleteBlock:^{
        
    }];
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

#pragma mark - Selected Category

- (void) selectedCategory:(NSNotification *)notif
{
    NewsCategorie *category = [notif object];
    [self hideCategoryView];
    
    page = 0;
    
    if (category.IDCategorie == -2)
    {
        self.newsType = kMaterialNews;
    }
    else // if (category.IDCategorie == -1)
    {
        self.newsType = @"";
    }
//    else
//        self.newsType = kDefaultNews;
    
    self.categoryID = category.IDCategorie;
    [newsList removeAllObjects];
    [LoadingView showInView:self.tabBarController.view];
    [self downloadNewsWithTimeStamp:-1 CompleteBlock:^{
        [table setContentOffset:CGPointZero];
    }];
}

- (void) readMore:(NSNotification *)notif
{
    NSIndexPath *idxPath = [table indexPathForCell:[notif object]];
    
    News *news = [newsList objectAtIndex:idxPath.row];
    [self openNews:news];

}

@end
