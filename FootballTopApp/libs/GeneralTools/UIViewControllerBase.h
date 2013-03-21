//
//  UIViewControllerBase.h
//  AgileFifteens
//
//  Created by destman on 1/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AppDelegateViewController

- (BOOL) canUseInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end


@interface UIViewControllerBase : UIViewController 
{
    dispatch_block_t    hideBlock;
}
@property(copy) dispatch_block_t    hideBlock;

- (void) pushViewControllerNamed:(NSString *)name animated:(BOOL) yesOrNo;
- (void) pushViewControllerNamed:(NSString *)name animated:(BOOL) yesOrNo useDefaultBundle:(BOOL) useDefaultBundle;
- (IBAction) goBack;

@end
