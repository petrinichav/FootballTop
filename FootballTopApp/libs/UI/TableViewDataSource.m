//
//  ActionsDataSource.m
//  IPhoneSpeedTracker
//
//  Created by destman on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TableViewDataSource.h"
#import <QuartzCore/QuartzCore.h>

static NSString *NilCategorieID = @"NilCategorie";

@implementation TableViewDataSource

- (id) init
{
    if( (self = [super init]) )
    {
        _actions = [[NSMutableDictionary alloc] init];
        _categories = [[NSMutableArray alloc] init];
        _views = [[NSMutableArray alloc] init];
        _footers = [[NSMutableDictionary alloc] init];
        _headers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) subscribeView:(UIView *)view;
{
    if([_views indexOfObject:view]==NSNotFound)
    {
        [_views addObject:view];
    }
}

#if !HAVE_ARC
- (void) dealloc
{
    [_headers release];
    [_footers release];
    [_views release];
    [_actions release];
    [_categories release];
    [super dealloc];
}
#endif

-(void) reloadDataInViews
{
    for (UIView *view in _views) 
    {
        if([view respondsToSelector:@selector(reloadData)])
        {
            [view performSelector:@selector(reloadData)];
        }
    }
}

-(void) resetData
{
    [_actions removeAllObjects];
    [_categories removeAllObjects];
}

-(NSUInteger) count
{
    NSUInteger rv = 0;
    for (NSString *categorieId in _categories)
    {
        NSMutableArray *categorie = [_actions valueForKey:categorieId];
        rv += [categorie count];
    }
    return rv;
}

-(id) objectAtIndex:(NSUInteger)index
{
    for (NSString *categorieId in _categories)
    {
        NSMutableArray *categorie = [_actions valueForKey:categorieId];
        
        if(index<[categorie count])
        {
            return [categorie objectAtIndex:index];
        }
        index -= [categorie count];
    };
    @throw NSRangeException;
}

-(void) animateAddAction:(NSIndexPath *)indexPath
{
    for (UIView *view in _views) 
    {
        if([view isKindOfClass:[UITableView class]])
        {
            UITableView *tView = (UITableView *)view;
            [tView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else
        {
            if([view respondsToSelector:@selector(reloadData)])
            {
                [view performSelector:@selector(reloadData)];
            }            
        }
    }    
}

-(void) animateAddCategorie:(NSInteger)categorieIndex
{
    for (UIView *view in _views) 
    {
        if([view isKindOfClass:[UITableView class]])
        {
            UITableView *tView = (UITableView *)view;
            [tView insertSections:[NSIndexSet indexSetWithIndex:categorieIndex] withRowAnimation:UITableViewRowAnimationFade];
        }else
        {
            if([view respondsToSelector:@selector(reloadData)])
            {
                [view performSelector:@selector(reloadData)];
            }            
        }
    }    
}


-(void) animateRemoveAction:(NSIndexPath *)indexPath
{
    for (UIView *view in _views) 
    {
        if([view isKindOfClass:[UITableView class]])
        {
            UITableView *tView = (UITableView *)view;
            [tView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else
        {
            if([view respondsToSelector:@selector(reloadData)])
            {
                [view performSelector:@selector(reloadData)];
            }            
        }
    }    
}

-(void) addCell:(TableCellInfo *)action           withCategorieID:(NSString *)categorieID animated:(BOOL)animated
{
    if(categorieID == nil)
        categorieID = NilCategorieID;
    
    NSMutableArray *categorieActions=[_actions objectForKey:categorieID];
    BOOL newCategorie = NO;
    if(categorieActions==nil)
    {
        newCategorie = YES;
        categorieActions = [[NSMutableArray alloc] init];
        [_categories addObject:categorieID];
        [_actions setValue:categorieActions forKey:categorieID];
        RELEASE(categorieActions);
    }
    [categorieActions addObject:action];
    if(animated)
    {
        int sectionPos = [_categories indexOfObject:categorieID];
        int rowPos = [categorieActions indexOfObject:action];
        if(newCategorie)
        {
            [self animateAddCategorie:sectionPos];
        }else
        {
            [self animateAddAction:[NSIndexPath indexPathForRow:rowPos inSection:sectionPos]];
        }
    }
}

-(void) updateCellsWithCategorieID:(NSString *)categorieID
{
    for (UIView *view in _views) 
    {
        if([view isKindOfClass:[UITableView class]])
        {
            UITableView *tView = (UITableView *)view;
            int sectionPos = [_categories indexOfObject:categorieID];
            [tView reloadSections:[NSIndexSet indexSetWithIndex:sectionPos] withRowAnimation:UITableViewRowAnimationFade];
        }else
        {
            if([view respondsToSelector:@selector(reloadData)])
            {
                [view performSelector:@selector(reloadData)];
            }            
        }
    }    
}


-(void) removeCell:(TableCellInfo *)action withCategorieID:(NSString *)categorieID animated:(BOOL)animated
{
    if(categorieID == nil)
        categorieID = NilCategorieID;
    
    NSMutableArray *categorieActions=[_actions objectForKey:categorieID];
    if(categorieActions)
    {
        int sectionPos = [_categories indexOfObject:categorieID];
        int rowPos = [categorieActions indexOfObject:action];
        [categorieActions removeObject:action];
        if(animated)
        {
            [self animateRemoveAction:[NSIndexPath indexPathForRow:rowPos inSection:sectionPos]];
        }    
    }
}

-(void)setFooterView:(UIView *)footerView forCategorieID:(NSString *)categorieID
{
    [_footers setValue:footerView forKey:categorieID];
}

-(void) setHeaderView:(UIView*) headerView forCategorieID:(NSString*) categorieID
{
    [_headers setValue:headerView forKey:categorieID];
}


#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    [self subscribeView:tableView];
    return [_categories count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSMutableArray *categorieActions = [_actions objectForKey:[_categories objectAtIndex:section]];
	return [categorieActions count];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *categorieActions = [_actions objectForKey:[_categories objectAtIndex:indexPath.section]];
    TableCellInfo *info = [categorieActions objectAtIndex:indexPath.row];
    if(info.editStyle)
        return info.editStyle(info);
    return UITableViewCellEditingStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSMutableArray *categorieActions = [_actions objectForKey:[_categories objectAtIndex:indexPath.section]];
    TableCellInfo *info = [categorieActions objectAtIndex:indexPath.row];
    UITableViewCell *cell = info.create(info,table);
    info.config(info,cell);
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [_headers valueForKey:[_categories objectAtIndex:section]];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [_footers valueForKey:[_categories objectAtIndex:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    UIView *view = [self tableView:tableView viewForHeaderInSection:section];
    return view.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    UIView *view = [self tableView:tableView viewForFooterInSection:section];
    return view.frame.size.height;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *categorieActions = [_actions objectForKey:[_categories objectAtIndex:indexPath.section]];
    TableCellInfo *info = [categorieActions objectAtIndex:indexPath.row];
    if(info.action)
    {
        info.action(info);
    }
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *categorieActions = [_actions objectForKey:[_categories objectAtIndex:indexPath.section]];
    TableCellInfo *info = [categorieActions objectAtIndex:indexPath.row];
    if(info.editAction)
    {
        info.editAction(info,editingStyle);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

@end
