//
//  LoadingView.h
//  iPhoneMediaViewer
//
//  Created by Evgen Bodunov on 9/9/10.
//  Copyright 2010 Evgen Bodunov <evgen.bodunov@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingView	 : UIView 
{
    
}

+ (void) showInView:(UIView *) parent;
+ (void) show;
+ (void) hide;

@end
