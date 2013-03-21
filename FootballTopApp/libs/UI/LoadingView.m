//
//  LoadingView.m
//  iPhoneMediaViewer
//
//  Created by Evgen Bodunov on 9/9/10.
//  Copyright 2010 Evgen Bodunov <evgen.bodunov@gmail.com>. All rights reserved.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
		UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[self addSubview:activityIndicator];
        RELEASE(activityIndicator);
		CGRect rect = activityIndicator.frame;
        
		rect.origin = CGPointMake( floor(self.frame.size.width/2 - rect.size.width/2) , 
                                  floor(self.frame.size.height/2 - rect.size.height/2) );
        
		activityIndicator.frame = rect;
		[activityIndicator startAnimating];
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, rect.origin.y + rect.size.height + 5,
                                                                       frame.size.width,
                                                                       floor( frame.size.height - rect.origin.y - rect.size.height -5))];
        textLabel.text = Loc(@"_Loc_Loading_View_Text");
        textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:textLabel];
        RELEASE(textLabel);

		CALayer *l = self.layer;
		l.cornerRadius = 7;
    }
    return self;
}

#pragma mark Singletone stuff

static LoadingView *loadingView;

+ (void) showInView:(UIView *) parent 
{
	@synchronized (loadingView) 
	{
		if (loadingView == nil) 
		{
			loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, 128, 120)];
		}
		
		parent.userInteractionEnabled = NO;

		CGRect parentBounds = parent.bounds;
		CGRect rect = CGRectMake((parentBounds.size.width - 128)/2, (parentBounds.size.height - 120)/3, 128, 120);
		loadingView.frame = rect;
		loadingView.alpha = 0;
        loadingView.center = parent.center;
		
		[parent addSubview:loadingView];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.2];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationBeginsFromCurrentState:YES];
		loadingView.alpha = 1;
		[UIView commitAnimations];
	}
}

+ (void) show
{
    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    
    UIViewController *baseCtrl = nil;
    if([delegate respondsToSelector:@selector(navigationController)])
    {
        baseCtrl = [delegate performSelector:@selector(navigationController)];
    }
    
    if(baseCtrl == nil && [delegate respondsToSelector:@selector(tabBarController)])
    {
        baseCtrl = [delegate performSelector:@selector(tabBarController)];
    }
    
    if(baseCtrl == nil || baseCtrl.view == nil)
    {
        dbgLog(@"Failed to find base view controller to show loading view");
    }else
    {
        [self showInView:baseCtrl.view];
    }
}


+ (void) hide 
{
	if([loadingView superview])
	{
		loadingView.superview.userInteractionEnabled = YES;
		[loadingView removeFromSuperview];
	}
}

@end
