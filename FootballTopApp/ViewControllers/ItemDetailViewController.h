//
//  ItemDetailViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/28/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FTItem, CommentsView;

@interface ItemDetailViewController : UIViewController
{
    
    
    float contentHeight;
    
    CGFloat lastOffset;    
}

@property (nonatomic, retain) IBOutlet UIWebView    *description;
@property (nonatomic, retain) IBOutlet UILabel      *titleLbl;
@property (nonatomic, retain) IBOutlet UIImageView  *imageItem;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIButton     *commentsBtn;
@property (nonatomic, retain) IBOutlet UIButton     *addToFavBtn;
@property (nonatomic, retain) IBOutlet UILabel      *infoTitleLbl;


- (void) setItem:(FTItem *)item;

- (IBAction) back:(UIButton *)sender;
- (IBAction) openComments:(id)sender;

@end
