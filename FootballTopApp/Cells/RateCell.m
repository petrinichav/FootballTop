//
//  RateCell.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 29.01.13.
//  Copyright (c) 2013 Alex Petrinich. All rights reserved.
//

#import "RateCell.h"

@implementation RateCell

+ (RateCell *) loadCell
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"RateCell" owner:self options:NULL];
    RateCell *cell = [objects objectAtIndex:0];
   
    return cell;
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

- (void) dealloc
{
    [_rateName release];
    _rateName = nil;
    [_selectedBgView release];
    _selectedBgView = nil;
    [super dealloc];
}

@end
