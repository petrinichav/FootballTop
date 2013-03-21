//
//  BaloonView.h
//  iPhoneScreenMaker
//
//  Created by Arkadiy Tolkun on 12.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaloonView : UIView
{
    UIImageView *_leftImgView,*_centerImgView,*_rightImgView;
    UIView      *_contentView;
    int _leftCap,_rightCap;
}

- (void) setLeftImage:(UIImage*)image   capWidth:(double)capWidth;
- (void) setRightImage:(UIImage*)image  capWidth:(double)capWidth;
- (void) setCenterImage:(UIImage*)image;

- (void) showAtView:(UIView *)baseView withContentView:(UIView *)contentView rectOfInterest:(CGRect)rectOfInterest animated:(BOOL)animated;


@end
