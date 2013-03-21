//
//  SettingsCell.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/5/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "SettingsCell.h"

@implementation SettingsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       

    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void) setImage:(UIImage *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(5, self.contentView.frame.size.height/2-20, 40, 40);
    [self.contentView addSubview:imageView];
    [imageView release];
    
    [self moveText];
}

- (void)  moveText
{
    CGRect rect = self.textLabel.frame;
    rect.origin.x = 50;
    self.textLabel.frame = rect;
}

- (void) setName:(NSString *) name
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, 100, 40)];
    [self.contentView addSubview:label];
    label.backgroundColor = [UIColor clearColor];
    label.text = name;
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    [label release];
}

- (NSString *) value
{
    return self.detailTextLabel.text;
}

@end
