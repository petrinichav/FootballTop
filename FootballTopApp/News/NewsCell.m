//
//  NewsCell.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/26/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "NewsCell.h"
#import "News.h"
#import "DataSource.h"
#import "DispatchTools.h"

@implementation NewsCell

+ (NSString *) xibNameForViewMode:(int)viewMode
{
    switch (viewMode) {
        case NewsViewModeMini:
            return @"NewsMiniCell";
            break;
        case NewsViewModeTeaser:
            return @"NewsTeaserCell";
            break;
        case NewsViewModeFull:
            return @"NewsFullCell";
            break;
            
        default:
            break;
    }
    return @"";
}

+ (NewsCell *) loadCellForViewMode:(int)viewMode hasImage:(BOOL) isImage
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:[NewsCell xibNameForViewMode:viewMode] owner:self options:NULL];
    NewsCell* cell = nil;
    if (!isImage)
        cell = [objects objectAtIndex:0];
    else
    {
        cell = [objects objectAtIndex:1];
        [cell createActivitiIndicator];
    }
    return cell;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected)
    {
        self.selectedView.alpha = 1;
        [self setColorForComments];
    }
    else
    {
        self.selectedView.alpha = 0;
    }
}

- (void) setColorForComments
{
    if (comments == 0)
    {
        self.commentsView.image = [UIImage imageNamed:@"comments_icon_inactive"];
        LabelInViewWithID(self, ID_LBL_COMMENTS).textColor = [UIColor lightGrayColor];
    }
    else
    {
        self.commentsView.image = [UIImage imageNamed:@"comments_icon"];
        LabelInViewWithID(self, ID_LBL_COMMENTS).textColor = [UIColor colorWithRed:234.f/255.f green:121.f/255.f blue:0.f alpha:1.f];
    }
}

- (void) createActivitiIndicator
{
    activityIndicator = [[ UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.color = [UIColor blueColor];
    [self addSubview:activityIndicator];
    
    activityIndicator.center = self.thumbnail.center;
    
}

- (void) setRectForView:(UIView *) forView fromView:(UIView *) fromView offset:(float)offset
{
    if ([fromView isKindOfClass:[UILabel class]])
    {
        UILabel *lbl = (UILabel *)fromView;
        float height = [AppHelper getCellSizeForText:lbl.text font:lbl.font width:lbl.frame.size.width];
        CGRect fromLblRect = lbl.frame;
        fromLblRect.size.height = height;
        lbl.frame = fromLblRect;
        
        CGRect forLblRect = forView.frame;
        forLblRect.origin.y = fromLblRect.origin.y + fromLblRect.size.height-offset;
        forView.frame = forLblRect;
    }
    else if ([fromView isKindOfClass:[UIImageView class]])
    {
        UIImageView *img = (UIImageView *)fromView;
        CGRect fromImgRect = img.frame;
        
        CGRect forLblRect = forView.frame;
        forLblRect.origin.y = fromImgRect.origin.y + fromImgRect.size.height-offset;
        forView.frame = forLblRect;

    }    
    
}

- (void) setPublicDate:(NSTimeInterval) pubDate
{
    int currentDay = [AppHelper dayFromDate:[NSDate date]];
    int previosday = currentDay-1;
    int pubDay = [AppHelper dayFromDate:[NSDate dateWithTimeIntervalSince1970:pubDate]];
    
    if (currentDay == pubDay)
    {
        LabelInViewWithID(self, ID_LBL_DATE).text = [NSString stringWithFormat:@"Сегодня, %@",
                                                     [AppHelper date:[NSDate dateWithTimeIntervalSince1970:pubDate] withFormat:@"HH:mm"]];
    }
    else if (previosday == pubDay)
    {
        LabelInViewWithID(self, ID_LBL_DATE).text = [NSString stringWithFormat:@"Вчера, %@",
                                                     [AppHelper date:[NSDate dateWithTimeIntervalSince1970:pubDate] withFormat:@"HH:mm"]];
    }
    else
    {
        LabelInViewWithID(self, ID_LBL_DATE).text = [AppHelper date:[NSDate dateWithTimeIntervalSince1970:pubDate] withFormat:@"dd MMMM yyyy, HH:mm"];
    }
}

- (void) setNews:(News *)news
{
    LabelInViewWithID(self, ID_LBL_TITLE).text = news.title;
    
    comments = news.comments;    
    [self setColorForComments];
    
    LabelInViewWithID(self, ID_LBL_COMMENTS).text = [NSString stringWithFormat:@"%d", news.comments];
    [self setPublicDate:news.pubDate];
    LabelInViewWithID(self, ID_LBL_BODY).text = news.htmlBody;
    
    __block UIImage *image = nil;
    [activityIndicator startAnimating];
    DispatchTask *task = [DispatchTask taskWithExecuteBlock:^(DispatchTask *newTask) {
        image =     [[DataSource source] cashedImageWithoutRequestForURL:[NSURL URLWithString:news.bigImageURL]];
    } andCompletitionBlock:^(DispatchTask *item)
                          {
                              self.thumbnail.image = image;
                              [activityIndicator stopAnimating];
                          }];
    [[DispatchTools Instance] addTask:task];
    

}

- (void) setSelectedTextColor
{
    LabelInViewWithID(self, ID_LBL_COMMENTS).textColor = [UIColor colorWithRed:234.f/255.f green:121.f/255.f blue:0.f alpha:1.f];
    LabelInViewWithID(self, ID_LBL_DATE).textColor     = [UIColor colorWithRed:149.f/255 green:149.f/255 blue:149.f/255 alpha:1.f];
}

- (IBAction) readMore:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReadMore" object:self];
}

- (void) dealloc
{
    [_commentsView release];
    _commentsView = nil;
    [_thumbnail release];
    _thumbnail = nil;
    [_selectedView release];
    _selectedView = nil;
    [activityIndicator release];
    
    [super dealloc];
}

@end
