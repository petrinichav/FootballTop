//
//  ItemsListViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/27/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "ItemsListViewController.h"
#import "Player.h"
#import "FTItem.h"
#import "FTObjectCell.h"
#import "NetworkTaskGenerator.h"
#import "ItemDetailViewController.h"
#import "AppDelegate.h"
#import "DataSource.h"

@interface ItemsListViewController ()

@end

@implementation ItemsListViewController
@synthesize typeObjects;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        itemsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Localization localizeView:self.view];
    _refreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:55 tableView:table withClient:(id)self];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadTable];
}

- (void)didReceiveMemoryWarning
{
    [table release];
    table = nil;
    [_refreshManager release];
    _refreshManager = nil;
    [[DataSource source] clearImageCache];
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    [table release];
    table = nil;
    [_refreshManager release];
    _refreshManager = nil;
    [itemsArray removeAllObjects];
    [itemsArray release];
    [typeObjects release];
    [super dealloc];   
}

- (void) addItems:(NSArray *) array
{
    for (NSDictionary *info in array)
    {
        FTItem *item = [FTItem createItemWithType:itemType info:info];
        [itemsArray addObject:item];
    }
}

- (void) setItems:(NSArray *)array typeItem:(int)type title:(NSString *)title
{
    itemType = type;
    page = 1;

    [self addItems:array];
    
    LabelInViewWithID(self.view, ID_LBL_TITLE).text = title;
}

- (IBAction) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) search:(id)sender
{
    AppDelegate *dlg = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [dlg showSearchControllerInNavController:self.navigationController];
}

#pragma mark - Tbl

- (void) setBackgroundColorForCell:(UITableViewCell *) cell withIndex:(int)index
{
    if (index % 2 == 0)
    {
        cell.backgroundView.backgroundColor = [UIColor colorWithRed:244.f/255 green:243.f/255 blue:239.f/255 alpha:1.f];
    }
    else
    {
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [itemsArray count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    identifier = @"FTObjectCell";
    FTObjectCell *cell = (FTObjectCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [FTObjectCell loadCellWithItemType:itemType];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = bgView;
        [bgView release];               
    }
    [self setBackgroundColorForCell:cell withIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    FTItem *item = [itemsArray objectAtIndex:indexPath.row];
    [cell setItem:item];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FTItem *obj = [itemsArray objectAtIndex:indexPath.row];
    [LoadingView showInView:self.tabBarController.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForGetItemWithID:obj.nID completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSDictionary *response = [(NetworkTaskGenerator *)item objectFromString];
            dbgLog(@"%@", response);
            obj.allInformation = response;
            obj.value = [[[response objectForKey:@"data"] objectForKey:@"body"] objectForKey:@"value"];
            
            ItemDetailViewController *vc = [[ItemDetailViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            [vc setItem:obj];
            [vc release];
        }
        [LoadingView hide];
    }];
    [[DispatchTools Instance] addTask:task];
}


#pragma  mark RefreshManager

- (void)loadTable
{
    [table reloadData];
    [_refreshManager tableViewReloadFinished];
}

- (void) getNextPosts
{    
    
    
}

- (void) getPrevPosts
{
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForGetItems:typeObjects language:@"ru" page:page limit:LIMIT_ITEMS_ON_PAGE completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSArray *arrayItems = [(NetworkTaskGenerator *)item objectFromString];
            
            [self addItems:arrayItems];
            [self loadTable];
            
            page++;
        }
        
    }];
    [[DispatchTools Instance] addTask:task];
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
