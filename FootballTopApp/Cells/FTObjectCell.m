//
//  FTObjectCell.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/28/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "FTObjectCell.h"
#import "FTItem.h"
#import "DispatchTools.h"
#import "DataSource.h"
#import "Player.h"
#import "Coach.h"
#import "Team.h"
#import "Club.h"

@implementation FTObjectCell

+ (NSString *) nibNameForItemType:(int)type
{
    NSString *nib = nil;
    switch (type) {
        case ItemPlayer:
            nib = @"FTPlayerCell";
            break;
        case ItemCoach:
            nib = @"FTCoachCell";
            break;
        case ItemClub:
            nib = @"FTClubCell";
            break;
        case ItemTeam:
            nib = @"FTTeamCell";
            break;
        case ItemChempionship:
            nib = @"FTChempionshipCell";
            break;
        default:
            nib = @"FTChempionshipCell";
            break;
    }
    
    return nib;
}

+ (FTObjectCell *) loadCellWithItemType:(int)type
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:[FTObjectCell nibNameForItemType:type] owner:self options:NULL];
    FTObjectCell *cell = [objects objectAtIndex:0];
    cell.itemType = type;
    [cell createActivitiIndicator];
    return cell;
}

- (void) dealloc
{
    [activityIndicator release];
    [_commentsView release];
    [_votesView release];
    [_selectedBgView release];
    _selectedBgView = nil;
    _commentsView = nil;
    _votesView = nil;
    [_queue release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected)
    {
        self.selectedBgView.alpha = 1;
    }
    else
    {
        self.selectedBgView.alpha = 0;
    }
    // Configure the view for the selected state
}

- (void) createActivitiIndicator
{
    activityIndicator = [[ UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.color = [UIColor blueColor];
    [self addSubview:activityIndicator];
    
    activityIndicator.center = ImageViewInViewWithID(self, ID_IMG_LOGO).center;
    
    self.queue = [[NSOperationQueue alloc] init];
    
}

- (void) setValueAdditionalViewForItem:(FTItem *)obj
{
    switch (self.itemType) {
        case ItemPlayer:
        {
            LabelInViewWithID(self, ID_LBL_CAPTION).text = [(Player *)obj role];
            LabelInViewWithID(self, ID_LBL_CLUB).text = [NSString stringWithFormat:@"Клуб %@", [(Player *)obj club]];
        }
            break;
        case ItemCoach:
        {
            LabelInViewWithID(self, ID_LBL_CLUB).text = [(Coach *)obj place];
        }
            break;
        case ItemClub:
        {
            LabelInViewWithID(self, ID_LBL_CLUB).text = [(Club *)obj championship];
        }
            break;
        case ItemTeam:
        {
        }
            break;
            
        default:
            break;
    }
}

- (void) updateCommentsViewForObject:(FTItem *)obj
{
    if (obj.comments == 0)
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

- (void) updateVotesViewForObject:(FTItem *)obj
{
    if (obj.votes == 0)
    {
        self.votesView.image = [UIImage imageNamed:@"votes_icon_inactive"];
        LabelInViewWithID(self, ID_LBL_VOTES).textColor = [UIColor lightGrayColor];
    }
    else
    {
        self.votesView.image = [UIImage imageNamed:@"votes_icon"];
        LabelInViewWithID(self, ID_LBL_VOTES).textColor = [UIColor colorWithRed:43.f/255.f green:102.f/255.f blue:120.f/255.f alpha:1.f];
    }
}

//-(void)loadImageWithParams:(FTItem*)obj{
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//    [activityIndicator startAnimating];
//    loadingImageView = YES;
//    loadedImage = NO;
//    UIImage* thumb = [[DataSource source] cashedImageWithoutRequestForURL:[NSURL URLWithString:obj.imageURL]];
//    [self performSelectorOnMainThread:@selector(setImage:) withObject:thumb waitUntilDone:YES];//обновление UI только на главном потоке
//    [pool release];
//}
//
//-(void)setImage:(UIImage *)thumb{
//    ImageViewInViewWithID(self, ID_IMG_LOGO).image = nil;
//    ImageViewInViewWithID(self, ID_IMG_LOGO).image = thumb;
//    loadingImageView = NO;
//    loadedImage = YES;
//    [activityIndicator stopAnimating];
//}
//
//- (void) clear
//{
//    if (loadingImageView)
//    {
//        NSInvocationOperation *operation = [[self.queue operations] lastObject];
//        [operation cancel];
//    }
//    
//    ImageViewInViewWithID(self, ID_IMG_LOGO).image = nil;
//    loadingImageView = NO;
//    loadedImage = NO;
//    [activityIndicator stopAnimating];
//}

- (UIImageView *)createImageViewWithFrame:(CGRect)rect
{
    UIImageView *view = [[UIImageView alloc] initWithFrame:rect];
    view.tag = ID_IMG_LOGO;
    return [view autorelease];
}

- (void) setItem:(FTItem *)obj
{
    [self updateCommentsViewForObject:obj];
    [self updateVotesViewForObject:obj];
    
    LabelInViewWithID(self, ID_LBL_TITLE).text = obj.title;
    LabelInViewWithID(self, ID_LBL_VOTES).text = [AppHelper stringValueForNumber:obj.votes];
    LabelInViewWithID(self, ID_LBL_COMMENTS).text = [AppHelper stringValueForNumber:obj.comments];
    
    [self setValueAdditionalViewForItem:obj];
    
    UIImageView *imgView = ImageViewInViewWithID(self, ID_IMG_LOGO);
    CGRect imgRect = imgView.frame;
    [imgView removeFromSuperview];
    imgView = nil;
    imgView = [self createImageViewWithFrame:imgRect];    
    [self insertSubview:imgView belowSubview:activityIndicator];
    imgView.contentMode = UIViewContentModeScaleAspectFit;

    [activityIndicator startAnimating];
    if ([[DataSource source] contentImageCashDataForURL:[NSURL URLWithString:obj.imageURL]])
    {
        [imgView removeFromSuperview];
        imgView = nil;
        imgView = [self createImageViewWithFrame:imgRect];
        [self insertSubview:imgView belowSubview:activityIndicator];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        
        imgView.image = [[DataSource source] cashedImageWithoutRequestForURL:[NSURL URLWithString:obj.imageURL]];
        [activityIndicator stopAnimating];
        
    }
    else{
        //ImageViewInViewWithID(self, ID_IMG_LOGO).image = nil;
        imgView.image = [Tools hiresImageNamed:@"default_image.png"];
        
        __block UIImage *image = nil;
        DispatchTask *task = [DispatchTask taskWithExecuteBlock:^(DispatchTask *item) {
            image = [[DataSource source] cashedImageWithoutRequestForURL:[NSURL URLWithString:obj.imageURL]];
        } andCompletitionBlock:^(DispatchTask *item) {
            imgView.image = image;
            [activityIndicator stopAnimating];
        }];
        [[DispatchTools Instance] addTask:task];
    }
    
}

@end
