//
//  VerticalProgressBar.m
//  Ringtone
//
//  Created by destman on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HorizontalProgressBar.h"

@implementation HorizontalProgressBar

- (void) drawRect:(CGRect)rect
{
    CGRect bounds = self.bounds;
    
    CGContextClearRect(UIGraphicsGetCurrentContext(), bounds);
    
    CGSize size = self.frame.size;
    double filledPart = size.width*_value;
    
    CGRect filledRect = CGRectMake(0            , 0 , filledPart            , size.height);
    [emptyImage drawAtPoint:CGPointMake(0, 0)];
    
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CGContextClipToRect(UIGraphicsGetCurrentContext(), filledRect);
    [filledImage drawAtPoint:CGPointMake(0, 0)];
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}


@end
