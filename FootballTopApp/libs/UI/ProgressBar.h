//
//  VerticalProgressBar.h
//  Ringtone
//
//  Created by destman on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressBar : UIView
{
    double _value;
    UIImage *emptyImage;
    UIImage *filledImage;
    UIImageView *thumbImageView;
    
}

@property (assign) double value;
@property (retain) UIImage *emptyImage, *filledImage, *thumbImage;

@end
