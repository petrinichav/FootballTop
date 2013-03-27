//
//  NewsDetailsViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/25/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class News;

@interface NewsDetailsViewController : UIViewController<UITextViewDelegate>
{
    News   *currentNews;
    
    CGFloat lastOffset;    
}

@property (nonatomic, retain) IBOutlet UIScrollView *bgScrollView;
@property (nonatomic, retain) IBOutlet UIWebView    *contentWebView;
@property (nonatomic, retain) IBOutlet UIButton     *commentsBtn;
@property (nonatomic, retain) IBOutlet UIImageView  *newsImage;

- (void) setNews:(News *) news;

- (IBAction) openComments:(id)sender;
- (IBAction) back:(id)sender;

@end
