//
//  AppDelegateBase.m
//  IPhoneSpeedTracker
//
//  Created by destman on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegateBase.h"

#ifdef FacebookAppID
#import "FacebookTools.h"
#endif

@implementation AppDelegateBase

@synthesize window = _window, navigationController = _navigationController, tabBarController = _tabBarController;

#if !HAVE_ARC
- (void)dealloc 
{
    [_window release];
	[_navigationController release];
    [_tabBarController release];
    [super dealloc];
}
#endif

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
#if HAVE_ARC
    dbgLog(@"Using ARC");
#else
    dbgLog(@"Using retain/release");
#endif
	[[Tools Instance] appStart];

    NSString *windowClassName = @"UIWindow";
    if([self respondsToSelector:@selector(WindowClassName)])
    {
        windowClassName = [self performSelector:@selector(WindowClassName)];
    }
 	CGRect rt = [[UIScreen mainScreen] bounds];
    _window = [[NSClassFromString(windowClassName) alloc] initWithFrame:rt];
    
    [_window makeKeyAndVisible];
    return YES;
}

#ifdef FacebookAppID
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    return [[FacebookTools Instance] handleOpenURL:url];
}
#endif


- (void)applicationDidEnterBackground:(UIApplication *)application 
{
    if(_tabBarController.modalViewController)
    {
        [_tabBarController.modalViewController viewWillDisappear:NO];
        [_tabBarController.modalViewController viewDidDisappear:NO];
    }else
    {
        [_tabBarController.selectedViewController viewWillDisappear:NO];
        [_tabBarController.selectedViewController viewDidDisappear:NO];
    }
    
    if(_navigationController.modalViewController)
    {
        [_navigationController.modalViewController viewWillDisappear:NO];
        [_navigationController.modalViewController viewDidDisappear:NO];
    }else
    {
        [_navigationController.topViewController viewWillDisappear:NO];
        [_navigationController.topViewController viewDidDisappear:NO];
    }
    
	[[Tools Instance] appGoToBackgound];
}


- (void)applicationWillEnterForeground:(UIApplication *)application 
{
    if(_tabBarController.modalViewController)
    {
        [_tabBarController.modalViewController viewWillAppear:NO];
        [_tabBarController.modalViewController viewDidAppear:NO];
    }else
    {
        [_tabBarController.selectedViewController viewWillAppear:NO];
        [_tabBarController.selectedViewController viewDidAppear:NO];
    }
    
    if(_navigationController.modalViewController)
    {
        [_navigationController.modalViewController viewWillAppear:NO];
        [_navigationController.modalViewController viewDidAppear:NO];
    }else
    {
        [_navigationController.topViewController viewWillAppear:NO];
        [_navigationController.topViewController viewDidAppear:NO];
    }
    
	[[Tools Instance] appGoToForeground];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[Tools Instance] appTerminate];
}

- (void) initNavigationControllerWithRootViewController:(UIViewController *)rootViewController
{   
    _navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.window.rootViewController = _navigationController;
}


- (void) initTabBarControllerWithViewControllerNames:(NSArray *)vcNames
{
    _tabBarController = [[UITabBarController alloc] init];
    [_window addSubview:_tabBarController.view];
    
    NSMutableArray *vcArray = [NSMutableArray array];
    
    for(NSString *vcName in vcNames)
    {
        [vcArray addObject:[Tools loadToNavigationControlerViewControllerNamed:vcName]];
    }
    _tabBarController.viewControllers = vcArray;
}

- (void) showAndFadeoutDefaultImageWithCompletitionBlock:(void (^)(void)) completeBlock
{
    UIImage *img = nil;
    if([Tools isIPad])
    {
        img = [UIImage imageNamed:@"Default.png"];
        if(img==nil)
        {
            img = [UIImage imageNamed:@"Default-Landscape.png"];
        }
    }else
    {
        img = [Tools hiresImageNamed:@"Default.png"];
    }

    UIImageView *defImage = [[UIImageView alloc] initWithImage:img];
    UIView *baseView = _window;
    defImage.frame = baseView.bounds;
    [baseView addSubview:defImage];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         defImage.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if(finished)
                         {
                             [defImage removeFromSuperview];
                             RELEASE(defImage);
                         }
                         if(completeBlock)
                         {
                             completeBlock();
                         }
                     }
     ];    
}

- (void) showAndFadeoutDefaultImage
{
    [self showAndFadeoutDefaultImageWithCompletitionBlock:nil];
}

@end
