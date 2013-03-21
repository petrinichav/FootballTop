//
//  ViewStack.h
//  IPhoneSpeedTracker
//
//  Created by Arkadiy Tolkun on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewStack : UIView
{
    NSArray *viewsCollection;
    NSArray *buttonsCollection;
    NSArray *bgCollection;
    
    int     selectedView;
}

@property (nonatomic, retain) IBOutletCollection(UIView)      NSArray *viewsCollection;
@property (nonatomic, retain) IBOutletCollection(UIButton)    NSArray *buttonsCollection;
@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *bgCollection;

@property (nonatomic, assign) int selectedView;
-(void) setSelectedView:(int)selectedView animated:(BOOL) animated;

@end
