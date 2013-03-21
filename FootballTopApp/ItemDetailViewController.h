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
    IBOutlet UIWebView              *description;
    IBOutlet UILabel                *titleLbl;
    IBOutlet UIImageView            *imageItem;
    IBOutlet UIScrollView           *scrollView;
    
    float contentHeight, commentHeight;
    
    CGFloat lastOffset;
    
    CommentsView      *commentsView;
}

@property (nonatomic, retain) IBOutlet UIButton     *commentsBtn;
@property (nonatomic, retain) IBOutlet UIButton     *addToFavBtn;
@property (nonatomic, retain) IBOutlet UIView       *addCommentField;
@property (nonatomic, retain) IBOutlet UITextView   *commentField;
@property (nonatomic, retain) IBOutlet UILabel      *infoTitleLbl;

- (void) setItem:(FTItem *)item;

- (IBAction) back:(UIButton *)sender;
- (IBAction) postComment:(id)sender;
- (IBAction) addComment:(id)sender;
- (IBAction) openComments:(id)sender;

@end
