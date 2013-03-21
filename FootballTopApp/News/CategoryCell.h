//
//  CategoryCell.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/20/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

+ (CategoryCell *) loadCell;

- (void) setNameCategory:(NSString *)name;

@end
