//
//  CategoryView.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 12/27/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsCategorie;
@protocol CategoryViewDelegate <NSObject>

@optional
- (void) selectedCategory:(NewsCategorie *)category;

@end

@interface CategoryView : UIView<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *categories;
}

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, assign) id<CategoryViewDelegate> delegate;

+ (id) loadView;

@end
