//
//  RateViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/5/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "RateViewController.h"
#import "NetworkTaskGenerator.h"
#import "ItemsListViewController.h"
#import "AppDelegate.h"
#import "RateCell.h"

@interface RateViewController ()

@end

@implementation RateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.tabBarItem.title = Loc(@"_Loc_Rate" );
        [self.tabBarItem setFinishedSelectedImage:[Tools hiresImageNamed:@"btn_rate_s.png"] withFinishedUnselectedImage:[Tools hiresImageNamed:@"btn_rate.png"]];
        
        categories = [[NSMutableArray alloc] init];
        images     = [[NSMutableArray alloc] init];
        for (int i = 1; i<=5; i++)
        {
            NSString *loc_name = [NSString  stringWithFormat:@"_Loc_Item_%d", i];
            NSString *name = Loc(loc_name);
            [categories addObject:name];
            
            NSString *loc_image = [NSString stringWithFormat:@"_Loc_Item_Image_%d", i];
            NSString *imageName = Loc(loc_image);
            [images addObject:imageName];
        }        
    }
    return self;
}

- (void) dealloc
{
    [categories release];
    [images release];
    [table release];
    table = nil;
    [super dealloc];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Localization localizeView:self.view];
    
    //refreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:55 tableView:table withClient:(id)self];

    // Do any additional setup after loading the view from its nib.
}

- (void) didReceiveMemoryWarning
{
    [table release];
    table = nil;

    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [table reloadData];
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
    return [categories count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    identifier = @"ItemCell";
    RateCell *cell = (RateCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [RateCell loadCell];
        
        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_arrow.png"]];
        cell.accessoryView = arrow;
        [arrow release];
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor clearColor];
        cell.backgroundView = bgView;
        [bgView release];
                
        [self setBackgroundColorForCell:cell withIndex:indexPath.row];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.rateName.text = [categories objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[images objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *loc_name = [NSString stringWithFormat:@"_Loc_Item_Const_%d", indexPath.row+1];
    NSString *itemType = Loc(loc_name);
    [LoadingView showInView:self.tabBarController.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForGetItems:itemType language:@"ru" page:0 limit:LIMIT_ITEMS_ON_PAGE completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSArray *arrayItems = [(NetworkTaskGenerator *)item objectFromString];
//            NSArray *arrayItems = [response objectForKey:@"result"];
            for (NSDictionary *dict in arrayItems)
            {
                dbgLog(@"dict = %@", dict);
            }
            
            ItemsListViewController *vc = [[ItemsListViewController alloc] initWithNibName:nil bundle:nil];
            vc.typeObjects = itemType;
            [vc setItems:arrayItems typeItem:(indexPath.row + 1) title:[categories objectAtIndex:indexPath.row]];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];

        }
        [LoadingView hide];
        
    }];
    [[DispatchTools Instance] addTask:task];
}

@end
