//
//  ProfileFavouriteCell.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/19/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FTItem;

@interface ProfileFavouriteCell : UITableViewCell
{
    CGPoint beginingPoint;
    
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) IBOutlet UIImageView *photoView;
@property (nonatomic, retain) IBOutlet UILabel     *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel     *typeLabel;
@property (nonatomic, retain) IBOutlet UILabel     *ratingLabel;
@property (nonatomic, retain) IBOutlet UIButton    *deleteBtn;

+ (ProfileFavouriteCell *) loadCell;

- (void) setValuesForItem:(FTItem *)item;

@end
