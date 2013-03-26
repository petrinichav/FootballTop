//
//  FTObjectCell.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/28/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FTItem, FTImageView;

@interface FTObjectCell : UITableViewCell
{
    UIActivityIndicatorView *activityIndicator;
    BOOL loadingImageView, loadedImage;
}

@property (nonatomic) int itemType;

@property (nonatomic, retain) IBOutlet UIImageView *commentsView;
@property (nonatomic, retain) IBOutlet UIImageView *votesView;
@property (nonatomic, retain) IBOutlet UIView      *selectedBgView;

@property (nonatomic, retain) NSOperationQueue *queue;

+ (FTObjectCell *) loadCellWithItemType:(int)type;

- (void) setItem:(FTItem *)obj;

@end
