//
//  CategoryView.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 12/27/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "CategoryView.h"
#import "NewsCategorie.h"
#import "NetworkTaskGenerator.h"

@implementation CategoryView

+ (id) loadView
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:[Tools xibForRetina4_inch:@"CategoryView"] owner:self options:NULL];
    CategoryView *view = [objects objectAtIndex:0];
    [view getCategories];
    return view;

}

- (void) deselectCategory:(NSNotification *) notif
{
    [self.table reloadData];
    [self.table selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void) getCategories
{
    categories = [[NSMutableArray alloc] init];
    
    NewsCategorie *categorie = [[NewsCategorie alloc] initWithID:-1 title:Loc(@"_Loc_ALL_News")];
    [categories addObject:categorie];
    [categorie release];
    categorie = nil;
    
    categorie = [[NewsCategorie alloc] initWithID:-2 title:Loc(@"_Loc_Material")];
    [categories addObject:categorie];
    [categorie release];

    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForGetNewsCategoriesForLanguage:@"ru" withCompleteBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSArray *response = [(NetworkTaskGenerator *)item objectFromString];
            for (NSDictionary *object in response) {
                NSString *title = [object objectForKey:@"name"];
                int ID = [[object objectForKey:@"tid"] intValue];
                NewsCategorie *categorie = [[NewsCategorie alloc] initWithID:ID title:title];
                [categories addObject:categorie];
                [categorie release];
            }
            [self.table reloadData];
            [self.table selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            
        }
    }];
    [[DispatchTools Instance] addTask:task];    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deselectCategory:) name:@"DeselectCategory" object:nil];

}

- (void) dealloc
{
    [_table release];
    _table = nil;
    [categories release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [categories count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indetifier = @"CategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indetifier];
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indetifier] autorelease];
    }
    
    NewsCategorie *categorie = [categories objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = categorie.titleCategorie;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsCategorie *category = [categories objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectedCategory" object:category];
}

@end
