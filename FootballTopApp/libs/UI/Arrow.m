//
//  Arrow.m
//  Speedometer
//
//  Created by Evgen Bodunov on 7/2/09.
//  Copyright 2009 Evgen Bodunov <evgen.bodunov@gmail.com>. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Arrow.h"


@implementation Arrow

@synthesize minValue, maxValue, minAngle, maxAngle, centerLocation;

#define degreesToRadian(x) (M_PI * (x) / 180.0)

- (id)initWithCoder:(NSCoder *)decoder 
{
	if ( (self = [super initWithCoder:decoder]) ) 
	{
        value = -1;
	}
	return self;
}

- (void) nextUpdate
{
	
}

- (void) updateView:(BOOL)animated 
{
    if(!CGPointEqualToPoint(self.layer.anchorPoint, centerLocation))
    {
        CGRect frame = self.bounds;
        CGPoint offset = CGPointMake(centerLocation.x-self.layer.anchorPoint.x,centerLocation.y-self.layer.anchorPoint.y);
        offset.x *= frame.size.width;
        offset.y *= frame.size.height;

        CGPoint newCenter = self.center;
        newCenter.x += offset.x;
        newCenter.y += offset.y;
        
        self.center = newCenter;
        self.layer.anchorPoint = centerLocation;
    }
	
	CGAffineTransform transform=CGAffineTransformIdentity;

	double curValue = value;
	if (curValue < minValue)
		curValue = minValue;
	if (curValue > maxValue)
		curValue = maxValue;
	double nextAngle = (maxAngle - minAngle)*((curValue - minValue)/(maxValue - minValue)) + minAngle;

	[self.layer removeAllAnimations];
	if (animated) 
	{
		if(fabs(curAngle-nextAngle)>180)
		{
			int dir = 1;
			if(curAngle>nextAngle)
				dir = -1;
			nextAngle = curAngle+ dir*90;

			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationCurve:UIViewAnimationCurveLinear];
			[UIView setAnimationDidStopSelector:@selector(animationDidStop: finished: context:)];
			[UIView setAnimationDelegate:self];
		}else
		{
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:1.f];
			[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		}
	}
	transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(degreesToRadian(nextAngle)));
    self.transform = transform;                                    
	curAngle = nextAngle;
	if (animated) 
	{
		[UIView commitAnimations];
	}
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self updateView:YES];
}


- (void)dealloc 
{
    [super dealloc];
}

- (double) value 
{
	return value;
}

- (void) setValue:(double)val animated:(BOOL)anim 
{
    if(value!=val || anim==NO)
    {
        value = val;
        [self updateView:anim];
    }
}

- (void) setValue:(double)val 
{
	[self setValue:val animated:NO];
}

@end
