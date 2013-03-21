//
//  text.m
//  Eneco Inzicht
//
//  Created by worker on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UnderlinedButton.h"


@implementation UnderlinedButton

- (void) setSizeOfLine:(CGSize)size
{
    sizeOfLine = size;
}

-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
   
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0);
    
    // Draw them with a 1.0 stroke width.
    CGContextSetLineWidth(context, 1.0);
    
    // Draw a single line from left to right  
     
    CGContextMoveToPoint(context, 0, self.frame.size.height);
    CGContextAddLineToPoint(context, sizeOfLine.width, self.frame.size.height); 
    CGContextStrokePath(context);
}

- (void)dealloc {
    [super dealloc];
}

@end
