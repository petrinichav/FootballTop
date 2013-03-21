//
//  RateViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/5/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RateViewController : UIViewController
{
    NSMutableArray            *categories, *images;
    IBOutlet UITableView      *table;   
}

@end
