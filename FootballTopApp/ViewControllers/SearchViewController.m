//
//  SearchViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/20/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "SearchViewController.h"
#import "NetworkTaskGenerator.h"
#import "FTItem.h"
#import "FTObjectCell.h"
#import "ItemDetailViewController.h"
#import "AlertModule.h"
#import "LoadingView.h"
#import "DataSource.h"

@interface SearchViewController ()

@property (nonatomic, retain) NSString *keyWord;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Localization localizeView:self.view];
    self.keyWord = @"";
    page = 0;
    
    self.noResultLbl.alpha = 0;
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [itemsArray removeAllObjects];
//    [self loadTable];
//    self.aSearchBar.text = @"";
//    self.keyWord = @"";
//    page = 0;
}

- (void) releaseOutlets
{
    [_aSearchBar release];
    _aSearchBar = nil;
    [_noResultView release];
    _noResultView = nil;
    [_noResultLbl release];
    _noResultLbl = nil;
}

- (void)didReceiveMemoryWarning
{
    [self releaseOutlets];
    [[DataSource source] clearImageCache];

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidUnload
{
    [self releaseOutlets];
    [super viewDidUnload];
}

- (void) dealloc
{
    [self releaseOutlets];
    [_keyWord release];
    [super dealloc];
}

- (void) addItems:(NSDictionary *) array
{
    NSDictionary *result = [array objectForKey:@"result"];
    for (NSString *key in result)
    {
        NSDictionary *info = [result objectForKey:key];
        int type = [FTItem FTObjectTypeFromString:[info objectForKey:@"type"]];
        FTItem *item = [FTItem createItemWithType:type info:info];
        item.nID = [key intValue];
        [itemsArray addObject:item];
    }
}

- (void) searchItems
{
    [LoadingView showInView:self.tabBarController.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForSearchText:self.keyWord
                                                                        language:@"ru"
                                                                            page:page
                                                                           limit:LIMIT_ITEMS_ON_PAGE
                                                                   completeBlock:^(DispatchTask *item) {
                                                                       if (((NetworkTaskGenerator *)item).isSuccessful)
                                                                       {
                                                                           NSDictionary *arrayItems = [(NetworkTaskGenerator *)item objectFromString];
                                                                           dbgLog(@"response = %@", arrayItems);
                                                                           [self addItems:arrayItems];
                                                                           
                                                                           if ([itemsArray count] > 9)
                                                                           {
                                                                               [_refreshManager setPullToRefreshViewVisible:YES];
                                                                           }
                                                                           else
                                                                           {
                                                                               [_refreshManager setPullToRefreshViewVisible:NO];
                                                                           }
                                                                           
                                                                           page++;
                                                                       }
                                                                       else if (((NetworkTaskGenerator *)item).statusCode == 404)
                                                                       {
                                                                           [_refreshManager setPullToRefreshViewVisible:NO];
                                                                       }
                                                                       [self loadTable];
                                                                       
                                                                       if ([itemsArray count] == 0)
                                                                       {
                                                                           self.noResultView.alpha = 1;
                                                                           self.noResultLbl.alpha = 1;
                                                                       }
                                                                       else
                                                                       {
                                                                           self.noResultView.alpha = 0;
                                                                       }
                                                                       
                                                                       [LoadingView hide];
                                                                   }];
    [[DispatchTools Instance] addTask:task];
}

#pragma mark - Search Bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar.text length] < 3)
    {
        [[AlertModule instance] createAlertWithType:SearchValidKeyWord
                                            buttons:1
                                    withCancelBlock:^(UIAlertView *_alert) {
                                        
                                    } completeBlock:^(UIAlertView *_alert) {
                                    }];
        [[AlertModule instance] showAlert];
        return;
    }
    
    [searchBar resignFirstResponder];
    [itemsArray removeAllObjects];
    [table reloadData];
    [table setContentOffset:CGPointZero];
    [_refreshManager setPullToRefreshViewVisible:YES];
    self.keyWord = searchBar.text;
    page = 0;
    [self searchItems];
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
    FTItem *item = [itemsArray objectAtIndex:indexPath.row];

    NSString *identifier;
    identifier = [NSString stringWithFormat:@"%d", item.itemType];
    FTObjectCell *cell = (FTObjectCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [FTObjectCell loadCellWithItemType:item.itemType];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = bgView;
        [bgView release];
        
        UIView *selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = [UIColor colorWithRed:192.f/255 green:212.f/255 blue:223.f/255 alpha:1.f];
        cell.selectedBackgroundView = selectedView;
        [selectedView release];
        
        [self setBackgroundColorForCell:cell withIndex:indexPath.row];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            [obj setInfo:response];
            
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
    [self searchItems];
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
