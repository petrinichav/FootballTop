//
//  ProfileFavouriteCell.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/19/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "ProfileFavouriteCell.h"
#import "FTItem.h"
#import "DataSource.h"
#import "DispatchTools.h"

@implementation ProfileFavouriteCell

+ (ProfileFavouriteCell *) loadCell
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"ProfileFavouriteCell" owner:self options:NULL];
    ProfileFavouriteCell *cell = [objects objectAtIndex:0];
    [cell createActivitiIndicator];
    [cell addPanRecognizer];
    return cell;
}

- (void) createActivitiIndicator
{
    activityIndicator = [[ UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.color = [UIColor blueColor];
    [self addSubview:activityIndicator];
    
    activityIndicator.center = self.photoView.center;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction) deleteFavourite:(id)sender
{
    //Logic of delete favourite
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteRow" object:self];
}

- (void) deleteCell:(UIPanGestureRecognizer *)recognizer
{
    CGPoint moveLocation = [recognizer translationInView:self];
    UIGestureRecognizerState state = recognizer.state;
    if (state == UIGestureRecognizerStateBegan)
    {
        beginingPoint = moveLocation;
    }
    else if (state == UIGestureRecognizerStateEnded)
    {
        int angle = (int)atanf((moveLocation.y - beginingPoint.y)/(moveLocation.x - beginingPoint.x));
        dbgLog(@"angle = %d", angle);
        if (angle == 0 & (beginingPoint.x - moveLocation.x) > 50)
        {
            self.deleteBtn.enabled = YES;
        }
        else if (angle == 0 & (beginingPoint.x - moveLocation.x) < -50)
        {
            self.deleteBtn.enabled = NO;
        }
    }
}

- (void) addPanRecognizer
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCell:)];
    recognizer.delegate = (id)self;
    recognizer.delaysTouchesBegan = 0.1f;
    recognizer.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:recognizer];
    [recognizer release];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) setValuesForItem:(FTItem *)item
{
    switch (item.itemType) {
        case ItemCoach:
            self.typeLabel.text = Loc(@"_Loc_Coach");
            break;
        case ItemTeam:
            self.typeLabel.text = Loc(@"_Loc_Country_Team");
            break;
        case ItemClub:
            self.typeLabel.text = Loc(@"_Loc_Team");
            break;
        case ItemPlayer:
            self.typeLabel.text = Loc(@"_Loc_PLayer");
            break;
            
        default:
            break;
    }
    
    self.nameLabel.text = item.title;
    if (item.rating == 0)
        self.ratingLabel.text = [AppHelper stringValueForNumber:item.votes];
    else
        self.ratingLabel.text = [AppHelper stringValueForNumber:item.rating];
    
    [self.deleteBtn setImage:[UIImage imageNamed:@"profile_tbl_delete"] forState:UIControlStateNormal];
    [self.deleteBtn setImage:[UIImage imageNamed:@"profile_tbl_check"] forState:UIControlStateDisabled];
     self.deleteBtn.enabled = NO;
    
    __block UIImage *image = nil;
    self.photoView.image = image;
    [activityIndicator startAnimating];
    DispatchTask *task = [DispatchTask taskWithExecuteBlock:^(DispatchTask *newTask) {
        image =     [[DataSource source] cashedImageWithoutRequestForURL:[NSURL URLWithString:item.imageURL]];
    } andCompletitionBlock:^(DispatchTask *item)
    {
        self.photoView.image = image;
        [activityIndicator stopAnimating];
    }];
    [[DispatchTools Instance] addTask:task];
}

- (void) releaseOutlets
{
    [_photoView release];
    _photoView = nil;
    [_nameLabel release];
    _nameLabel = nil;
    [_typeLabel release];
    _typeLabel = nil;
    [_ratingLabel release];
    _ratingLabel = nil;
    [_deleteBtn release];
    _deleteBtn = nil;
    [activityIndicator release];
}

- (void) dealloc
{
    [self releaseOutlets];
    [super dealloc];
}

@end
