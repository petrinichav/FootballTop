//
//  DragImageView.m
//  Ringtone
//
//  Created by destman on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DragImageView.h"

NSString *kDragImageViewCenterChanged=@"kDragImageViewCenterChanged";


@implementation DragImageView

@synthesize dragDirection=_dragDirection;

#pragma mark Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *allTouches = [[event touchesForView:self] allObjects];
    if([allTouches count]==1) //move
	{
		UITouch *touch = [allTouches objectAtIndex:0];
		{
			CGPoint pos = [touch locationInView:self];
			CGPoint prevPos = [touch previousLocationInView:self];
            
            CGPoint center = self.center;
            if(_dragDirection&DragImageViewDirection_X)
            {
                double offset = prevPos.x - pos.x;
                center.x-=offset;
            }
            if(_dragDirection&DragImageViewDirection_Y)
            {
                double offset = prevPos.y - pos.y;
                center.y-=offset;
            }
            if(!CGPointEqualToPoint(center, self.center))
            {
                self.center = center;
                [[NSNotificationCenter defaultCenter] postNotificationName:kDragImageViewCenterChanged object:self];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
