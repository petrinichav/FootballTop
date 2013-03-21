//
//  ProfileViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/5/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FTUser;

@interface ProfileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    float heightOfTable;
}

@property (nonatomic, retain) IBOutlet UIScrollView *bgScrollView;
@property (nonatomic, retain) IBOutlet UITableView  *itemsTable;
@property (nonatomic, retain) IBOutlet UILabel      *aboutLbl;
@property (nonatomic, retain) IBOutlet UILabel      *favTitleLbl;
@property (nonatomic, retain) IBOutlet UILabel      *noFavLabel;

@end
