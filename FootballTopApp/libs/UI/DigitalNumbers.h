//
//  RollingNumbers.h
//  Speedometer
//
//  Created by Evgen Bodunov on 7/6/09.
//  Copyright 2009 Evgen Bodunov <evgen.bodunov@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SlideInfo;

@interface DigitalNumbers : UIView 
{
	NSMutableArray  *imgArray,*imageViewCache,*curRow;
    NSMutableArray  *staticImages;
    
    int     digitsCount, digitsSpacing;
	double  value,multiplyer;
    BOOL    autoScroll;
}

- (void) setValue:(double)val   animated:(BOOL)anim;
- (void) setDigitNames:(NSArray *)names;

- (void) removeAllStaticImages;
- (void) addStaticImage:(UIImage *)img atPosition:(int)pos;

@property (readonly) BOOL   haveData;

@property (assign) int		digitsCount;
@property (assign) int      digitsSpacing;

@property (assign) double	value;
@property (assign) double	multiplyer;


@end
