//
//  Arrow.h
//  Speedometer
//
//  Created by Evgen Bodunov on 7/2/09.
//  Copyright 2009 Evgen Bodunov <evgen.bodunov@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Arrow : UIImageView 
{
	double minValue, maxValue, minAngle, maxAngle, value, curAngle;
	CGPoint centerLocation;
}

- (void) setValue:(double)val animated:(BOOL)anim;
- (void) updateView:(BOOL)anim;

@property (assign) double minValue, maxValue, minAngle, maxAngle, value;
@property (assign) CGPoint centerLocation; 

@end
