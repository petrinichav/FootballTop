    //
//  UIViewControllerBase.m
//  AgileFifteens
//
//  Created by destman on 1/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewControllerBase.h"


@implementation UIViewControllerBase
@synthesize hideBlock;

#if !HAVE_ARC
- (void) dealloc
{
    [hideBlock release];
    [super dealloc];
}
#endif

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	id delegate = [UIApplication sharedApplication].delegate;
    if([delegate respondsToSelector:@selector(canUseInterfaceOrientation:)])
    {
        return [(id<AppDelegateViewController>)delegate canUseInterfaceOrientation:interfaceOrientation];
    }else if([delegate respondsToSelector:@selector(currentInterfaceOrientation)])
	{
		UIInterfaceOrientation curOrientation = (UIInterfaceOrientation)[delegate performSelector:@selector(currentInterfaceOrientation)];
		return curOrientation==interfaceOrientation;
	}	
	return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark Navigation logic
- (void) pushViewControllerNamed:(NSString *)name animated:(BOOL) yesOrNo useDefaultBundle:(BOOL) useDefaultBundle
{
	UIViewController *vc = [Tools loadViewControllerNamed:name useDefaultBundle:useDefaultBundle];
	if(vc==nil)
	{
		dbgLog(@"Fatal error: Unable to load view controller '%@'", name);
		exit(-1);
	}
	[self.navigationController pushViewController:vc animated:yesOrNo];
}

-(void) pushViewControllerNamed:(NSString *)name animated:(BOOL)yesOrNo
{
    [self pushViewControllerNamed:name animated:yesOrNo useDefaultBundle:YES];
}


#pragma mark on appear Logic
- (void) viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	[[Tools Instance] itemAppear:self];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[Tools Instance] itemDisappear:self];
}

- (IBAction) goBack
{
    if(hideBlock)
    {
        hideBlock();
    }else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
