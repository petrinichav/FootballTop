//
//  CategoryCell.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/20/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "CategoryCell.h"

@implementation CategoryCell

+ (CategoryCell *) loadCell
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CategoryCell" owner:self options:NULL];
    CategoryCell *cell = [objects objectAtIndex:0];
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

    // Configure the view for the selected state
}

- (void) setNameCategory:(NSString *)name
{
    self.nameLabel.text = name;
}

- (IBAction) on:(UISwitch *)sender
{
    if (sender.on)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_CATEGORY"  object:self];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOVE_CATEGORY"  object:self];
}

- (void) dealloc
{
    [_nameLabel release];
    _nameLabel = nil;
    [super dealloc];
}

@end
