//
//  SettingsCell.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/5/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsCell : UITableViewCell

- (NSString *) value;
- (void) setImage:(UIImage *)image;
- (void)  moveText;
- (void) setName:(NSString *) name;

@end
