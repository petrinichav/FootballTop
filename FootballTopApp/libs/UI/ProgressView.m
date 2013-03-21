//
//  LoadingView.m
//  iPhoneMediaViewer
//
//  Created by Evgen Bodunov on 9/9/10.
//  Copyright 2010 Evgen Bodunov <evgen.bodunov@gmail.com>. All rights reserved.
//

#import "ProgressView.h"
#import "AppDelegateBase.h"

@implementation ProgressView


- (void)dealloc 
{
    [super dealloc];
}

#pragma mark Singletone stuff
static ProgressView *progressView;
+ (void) initWithNibName:(NSString *)nibName
{
    NSArray *topItems = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    for (UIView *view in topItems)
    {
        if([view isKindOfClass:[self class]])
        {
            progressView = (ProgressView *)[view retain];
        }
    }
}

+ (UIView *) getProgressView
{
    return progressView;
}



+ (void) showInView:(UIView *) parent
{
    if (progressView != nil) 
        @synchronized (progressView) 
        {
            parent.userInteractionEnabled = NO;
            progressView.alpha = 0;
            [parent addSubview:progressView];
            [UIView animateWithDuration:0.2 animations:^
             {
                 progressView.alpha = 1;
             }];
        }
}

+ (void) show
{
    AppDelegateBase *delegate = [UIApplication sharedApplication].delegate;
    
    UIViewController *baseCtrl = nil;
    if(delegate.navigationController!=nil)
    {
        baseCtrl = delegate.navigationController;
    }else if(delegate.tabBarController!=nil)
    {
        baseCtrl = delegate.tabBarController;
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
	if([progressView superview])
	{
		progressView.superview.userInteractionEnabled = YES;
		[progressView removeFromSuperview];
	}
}

+ (void) setProgress:(double) val
{
    progressView->progressBar.value = val;
}



@end
