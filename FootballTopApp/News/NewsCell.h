//
//  NewsCell.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/26/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class News;

@interface NewsCell : UITableViewCell
{
    UIActivityIndicatorView *activityIndicator;
    
    int comments;
}

@property (nonatomic, retain) IBOutlet UIImageView *commentsView;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnail;
@property (nonatomic, retain) IBOutlet UIView      *selectedView;

+ (NewsCell *) loadCellForViewMode:(int)viewMode hasImage:(BOOL) isImage;

- (void) setNews:(News *)news;
- (void) setSelectedTextColor;

@end
