//
//  BaloonView.m
//  iPhoneScreenMaker
//
//  Created by Arkadiy Tolkun on 12.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BaloonView.h"

@implementation BaloonView

- (void) _init
{
    _leftImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _rightImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _centerImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    [self addSubview:_leftImgView];
    [self addSubview:_rightImgView];
    [self addSubview:_centerImgView];
}

- (void) dealloc
{
    [_leftImgView release];
    [_rightImgView release];
    [_centerImgView release];
    [_contentView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame])) 
    {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self=[super initWithCoder:aDecoder]))
    {
        [self _init];
    }
    return self;
}

- (void) setLeftImage:(UIImage*)image   capWidth:(double)capWidth
{
    _leftCap = capWidth;
    [_leftImgView setImage:[image stretchableImageWithLeftCapWidth:capWidth topCapHeight:0]];
}

- (void) setRightImage:(UIImage*)image  capWidth:(double)capWidth;
{
    _rightCap = capWidth;
    [_rightImgView setImage:[image stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
}

- (void) setCenterImage:(UIImage*)image
{
    [_centerImgView setImage:image];
}

- (void) showAtView:(UIView *)baseView withContentView:(UIView *)contentView rectOfInterest:(CGRect)rectOfInterest animated:(BOOL)animated
{
    if(self.superview!=baseView)
    {
        [self removeFromSuperview];
        [baseView addSubview:self];
    }
    
    void (^finalState)(void)=^
    {
        if(_contentView!=contentView)
        {
            [_contentView release];
            _contentView = [contentView retain];
        }
        if(_contentView.superview!=self)
        {
            [_contentView removeFromSuperview];
            [self addSubview:_contentView];
        }
        
        CGSize conentSize   = _contentView.bounds.size;
        
        CGSize centerImageSize = _centerImgView.image.size;
        
        CGSize baloonSize = CGSizeMake(conentSize.width, centerImageSize.height);
        CGPoint pointOfInterest = CGPointMake(CGRectGetMidX(rectOfInterest),CGRectGetMinY(rectOfInterest)+5);

        double centerOffset = pointOfInterest.x-baseView.bounds.size.width/2;
        CGPoint curCenter  = [self convertPoint:CGPointMake(baloonSize.width/2+centerOffset, baloonSize.height) toView:baseView];
        CGPoint center = self.center;
        center.x += pointOfInterest.x-curCenter.x;
        center.y += pointOfInterest.y-curCenter.y;
        self.center = center;
        
        double centerX = baloonSize.width/2+centerOffset;
        
        _centerImgView.frame = CGRectMake(centerX-centerImageSize.width/2, 0, 
                                          centerImageSize.width, centerImageSize.height);
        
        _leftImgView.frame  = CGRectMake(0, 0, centerX-centerImageSize.width/2 , centerImageSize.height);
        _rightImgView.frame = CGRectMake(centerX+centerImageSize.width/2, 0, baloonSize.width-centerX-centerImageSize.width/2, centerImageSize.height);
        _contentView.frame = CGRectMake(0, 0 , conentSize.width, conentSize.height);
    };
    
    if(animated)
    {
        [UIView animateWithDuration:0.5 animations:finalState];
    }else
    {
        finalState();
    }
    
    
}

@end
