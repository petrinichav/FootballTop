//
//  ViewStack.m
//  IPhoneSpeedTracker
//
//  Created by Arkadiy Tolkun on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewStack.h"

@implementation ViewStack

-(void) awakeFromNib
{
#if DEBUG
    int nViews   = [viewsCollection count];
    if(buttonsCollection)
    {
        int nButtons = [buttonsCollection count];
        NSAssert(nButtons==nViews, @"Number of buttons must be equal to number of views");
    }
    
    if(bgCollection)
    {
        int nBgs     = [bgCollection count];
        NSAssert(nViews==nBgs  , @"Number of backgrounds must be equal to number of views");
    }
#endif
    [self setSelectedView:0 animated:NO];
}

#if !HAVE_ARC
-(void) dealloc
{
    [viewsCollection release];
    [buttonsCollection release];
    [bgCollection release];    
    [super dealloc];
}
#endif

#pragma mark Events
-(void) switchView:(UIButton *)btn
{
    int index = [buttonsCollection indexOfObject:btn];
    if(index != NSNotFound)
    {
        [self setSelectedView:index animated:YES];
    }
}


#pragma mark properties
-(void) setButtonsCollection:(NSArray *)buttonsCollection_in
{
    if(buttonsCollection!=buttonsCollection_in)
    {
        for (UIButton *button in buttonsCollection)
        {
            [button removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
        }
        RELEASE(buttonsCollection);
        buttonsCollection = RETAIN(buttonsCollection_in);
        
        for (UIButton *button in buttonsCollection)
        {
            [Localization localizeView:button];
            [button addTarget:self action:@selector(switchView:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

-(NSArray *) buttonsCollection
{
    return buttonsCollection;
}

-(void) setViewsCollection:(NSArray *)viewsCollection_in
{
    if(viewsCollection!=viewsCollection_in)
    {
        for (UIView *view in viewsCollection)
        {
            if(view.superview == self)
            {
                [view removeFromSuperview];
            }
        }
        RELEASE(viewsCollection);
        viewsCollection = RETAIN(viewsCollection_in);
        for (UIView *view in viewsCollection)
        {
            [Localization localizeView:view];
            view.alpha = 0;
        }
    }    
}

-(NSArray*) viewsCollection
{
    return viewsCollection;
}

-(void) setBgCollection:(NSArray *)bgCollection_in
{
    if(bgCollection!=bgCollection_in)
    {
        RELEASE(bgCollection);
        bgCollection = RETAIN(bgCollection_in);
        for (UIImageView *view in bgCollection)
        {
            view.alpha = 0;
        }
    }    
}

-(NSArray*) bgCollection
{
    return viewsCollection;
}


-(void) setSelectedView:(int)selectedView_in animated:(BOOL) animated
{
    if(selectedView!=selectedView_in || !animated)
    {
        UIView      *curView   = nil;
        UIButton    *curButton = nil;
        UIImageView *curBg     = nil;
        
        if(selectedView>=0)
        {
            curView   = [viewsCollection   objectAtIndex:selectedView];
            curButton = [buttonsCollection objectAtIndex:selectedView];
            curBg     = [bgCollection      objectAtIndex:selectedView];            
        }        
        
        selectedView = selectedView_in;

        UIView      *newView   = nil;
        UIButton    *newButton = nil;
        UIImageView *newBg     = nil;
        if(selectedView>=0)
        {
            newView   = [viewsCollection   objectAtIndex:selectedView];
            newButton = [buttonsCollection objectAtIndex:selectedView];
            newBg     = [bgCollection      objectAtIndex:selectedView];            
            self.userInteractionEnabled = YES;
        }else
        {
            self.userInteractionEnabled = NO;
        }

        if(bgCollection && curBg!=newBg)
        {
            NSAssert(curBg.superview!=nil, @"Backgrounds must be placed correctly.");
            [curBg.superview    insertSubview:newBg     aboveSubview:curBg];
        }
        
        if(curView.superview)
        {
            [curView.superview  insertSubview:newView   aboveSubview:curView];
        }else
        {
            [self addSubview:newView];
        }
        
        dispatch_block_t anim = ^
        {
            curView.alpha       = 0;
            newView.alpha       = 1;
            newButton.selected  = YES;
            newBg.alpha         = 1;
        };
        
        dispatch_block_t animEnd = ^
        {
            if(curView!=newView)
            {
                curButton.selected  = NO;
                curBg.alpha         = 0;
            }
        };
        
        
        if(animated)
        {
            [UIView animateWithDuration:0.25 animations:anim completion:^(BOOL finished) 
            {
                animEnd();
            }];
        }else
        {
            anim();
            animEnd();
        }
    }
        
}

-(void) setSelectedView:(int)selectedView_in
{
    [self setSelectedView:selectedView_in animated:NO];
}

-(int) selectedView
{
    return selectedView;
}

@end
