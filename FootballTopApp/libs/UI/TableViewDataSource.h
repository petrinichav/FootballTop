//
//  ActionsDataSource.h
//  IPhoneSpeedTracker
//
//  Created by destman on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableCellInfo.h"

@interface TableViewDataSource : NSMutableArray<UITableViewDataSource,UITableViewDelegate> 
{
    NSMutableArray          *_categories;
    NSMutableDictionary     *_actions;
    
    NSMutableDictionary     *_footers, *_headers;
    NSMutableArray          *_views;
}

-(void) subscribeView:(UIView *)view;

-(void) addCell:(TableCellInfo *)action    withCategorieID:(NSString *)categorieID animated:(BOOL)animated;
-(void) removeCell:(TableCellInfo *)action withCategorieID:(NSString *)categorieID animated:(BOOL)animated;

-(void) updateCellsWithCategorieID:(NSString *)categorieID;
-(void) setFooterView:(UIView*) footerView forCategorieID:(NSString*) categorieID;
-(void) setHeaderView:(UIView*) headerView forCategorieID:(NSString*) categorieID;
-(void) reloadDataInViews;
-(void) resetData;

@end
