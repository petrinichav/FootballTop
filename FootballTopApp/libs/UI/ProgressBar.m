//
//  VerticalProgressBar.m
//  Ringtone
//
//  Created by destman on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProgressBar.h"
#import "DispatchTools.h"

@implementation ProgressBar

@synthesize emptyImage, filledImage;

- (void) _init
{
    self.backgroundColor = [UIColor clearColor];
    self.value = 0.5;
    [self setNeedsDisplay];
}

- (id)init
{
    if ( (self = [super init]) ) 
    {
        [self _init];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if ( (self = [super initWithCoder:aDecoder]) )
    {
        [self _init];
    }
    return self;
}

- (void) dealloc
{
    [thumbImageView release];
    [emptyImage release];
    [filledImage release];
    [super dealloc];
}

- (double) value
{
    return _value;
}

- (void) setValue:(double)val
{
    if(val!=_value)
    {
        _value = val;
        [DispatchTools doOnMainThread:^
        {
            [self setNeedsDisplay];
            [self setNeedsLayout];
        }];
    }
}

- (void) setThumbImage:(UIImage *)thumbImage
{
    if (thumbImageView)
    {
        [thumbImageView removeFromSuperview];
        [thumbImageView release];
    }
    if (thumbImage)
    {
        thumbImageView = [[UIImageView alloc] initWithImage:thumbImage];
        thumbImageView.frame = CGRectMake(0,
                                          0,
                                          thumbImage.size.width,
                                          thumbImage.size.height);
        [self addSubview:thumbImageView];
    }
    [self setNeedsLayout];
}

- (UIImage *) thumbImage
{
    return thumbImageView.image;
}

@end
