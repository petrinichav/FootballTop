//
//  RateCell.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 29.01.13.
//  Copyright (c) 2013 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RateCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *rateName;
@property (nonatomic, retain) IBOutlet UIView  *selectedBgView;

+ (RateCell *) loadCell;

@end
