//
//  DragImageView.h
//  Ringtone
//
//  Created by destman on 7/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DragImageViewDirection_X 1
#define DragImageViewDirection_Y 2

extern NSString *kDragImageViewCenterChanged;

@interface DragImageView : UIImageView
{
    int _dragDirection;
}

@property (assign) int dragDirection;

@end
