//
//  SearchViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/20/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "ItemsListViewController.h"

@interface SearchViewController : ItemsListViewController

@property (nonatomic, retain) IBOutlet UISearchBar *aSearchBar;
@property (nonatomic, retain) IBOutlet UIView      *noResultView;
@property (nonatomic, retain) IBOutlet UILabel     *noResultLbl;

@end
