//
//  VerticalProgressBar.m
//  Ringtone
//
//  Created by destman on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VerticalProgressBar.h"

@implementation VerticalProgressBar

- (void) drawRect:(CGRect)rect
{
    CGRect bounds = self.bounds;
    
    CGContextClearRect(UIGraphicsGetCurrentContext(), bounds);
    
    CGSize size = self.frame.size;
    double filledPart = size.height*(1-_value);
    
    CGRect filledRect = CGRectMake( 0, filledPart, size.width, size.height-filledPart);
    [emptyImage drawAtPoint:CGPointMake((size.width - emptyImage.size.width)/ 2.0, 0)];
    
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CGContextClipToRect(UIGraphicsGetCurrentContext(), filledRect);
    [filledImage drawAtPoint:CGPointMake((size.width - filledImage.size.width)/ 2.0, 0)];
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

- (void) layoutSubviews
{
    CGSize size = self.frame.size;
    double filledPart = (size.height - thumbImageView.frame.size.height)*(1-_value);
    
    thumbImageView.center = CGPointMake(size.width/2.0, filledPart + thumbImageView.frame.size.height/2.0);
}


@end
