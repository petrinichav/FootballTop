//
//  NewsCategoriesViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/22/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsCategoriesViewController : UIViewController
{
    NSMutableArray *categories;
    NSMutableArray *choicedCategories;
    
    IBOutlet UITableView *table;
}

@end
