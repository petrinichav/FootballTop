//
//  AppDelegateBase.h
//  IPhoneSpeedTracker
//
//  Created by destman on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDelegateBase : NSObject <UIApplicationDelegate>  
{
    UIWindow                *_window;
	UINavigationController  *_navigationController;
    UITabBarController      *_tabBarController;
}
@property (strong, nonatomic)   UIWindow                *window;
@property (nonatomic, readonly) UINavigationController  *navigationController;
@property (nonatomic, readonly) UITabBarController      *tabBarController;

- (void) initNavigationControllerWithRootViewController:(UIViewController *)rootViewController;
- (void) initTabBarControllerWithViewControllerNames:(NSArray *)vcNames;


- (void) showAndFadeoutDefaultImageWithCompletitionBlock:(void (^)(void)) completeBlock;
- (void) showAndFadeoutDefaultImage;

@end
