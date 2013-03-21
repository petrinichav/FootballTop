//
//  NewsCategoriesViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/22/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "NewsCategoriesViewController.h"
#import "NetworkTaskGenerator.h"
#import "NewsCategorie.h"
#import "FeedViewController.h"
#import "CategoryCell.h"

@interface NewsCategoriesViewController ()

@end

@implementation NewsCategoriesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = Loc(@"_Loc_News");
        [self.tabBarItem setFinishedSelectedImage:[Tools hiresImageNamed:@"btn_news_s.png"] withFinishedUnselectedImage:[Tools hiresImageNamed:@"btn_news.png"]];
        categories = [[NSMutableArray alloc] init];
        
        NewsCategorie *categorie = [[NewsCategorie alloc] initWithID:-1 title:Loc(@"_Loc_ALL_News")];
        [categories addObject:categorie];
        [categorie release];
        
        choicedCategories = [[NSMutableArray alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Localization localizeView:self.view];
    
      // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCategory:) name:@"ADD_CATEGORY" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCategory:) name:@"REMOVE_CATEGORY" object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) dealloc
{
    [categories release];
    [choicedCategories release];
    [table release];
    table = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [table release];
    table = nil;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addCategory:(NSNotification *)notif
{
    CategoryCell *cell = [notif object];
    NSIndexPath *idx = [table indexPathForCell:cell];
    NewsCategorie *category = [categories objectAtIndex:idx.row];
    [choicedCategories addObject:category];
}

- (void) removeCategory:(NSNotification *)notif
{
    CategoryCell *cell = [notif object];
    NSIndexPath *idx = [table indexPathForCell:cell];
    [choicedCategories removeObjectAtIndex:idx.row];
}

#pragma mark - Tbl

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [categories count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Тип новостей";
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    identifier = @"CategorieCell";
    CategoryCell *cell = (CategoryCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [CategoryCell loadCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NewsCategorie *categorie = [categories objectAtIndex:indexPath.row];
    [cell setNameCategory:categorie.titleCategorie] ;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCategorie *categorie = [categories objectAtIndex:indexPath.row];
    [LoadingView showInView:self.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForGetListNewsWithViewMode:NewsViewModeMini page:0 limit:10
                                                                                     category:categorie.IDCategorie newsType:kDefaultNews
                                                                                 createdafter:-1
                                                                                completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSArray *response = [(NetworkTaskGenerator *)item objectFromString];
            dbgLog(@"%@", response);
            FeedViewController *vc = [[FeedViewController alloc] initWithNibName:nil bundle:nil];
            vc.categoryID = categorie.IDCategorie;
            [vc setNews:response viewMode:NewsViewModeMini];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
        [LoadingView hide];
    }];
    [[DispatchTools Instance] addTask:task];
}


@end
