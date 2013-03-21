//
//  AppDelegate.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 8/29/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "AppDelegate.h"

#import "LoginViewController.h"
#import "libs/GeneralTools/DataSource.h"
#import "FeedViewController.h"
#import "ProfileViewController.h"
#import "RateViewController.h"
#import "SettingsViewController.h"
#import "SearchViewController.h"
#import "DefaultViewController.h"
#import "SettingSource.h"
#import "FTUser.h"
#import "NetworkTaskGenerator.h"
#import "AlertModule.h"
#import "CategoryView.h"

enum
{
    kIndexNewsVC,
    kIndexProfileVC,
    kIndexRateVC,
    kIndexSettingsVC,
};

@implementation AppDelegate

- (void)dealloc
{
    [_user release];
    [super dealloc];
}

- (void) pushMainPagesWithMode:(int)mode
{
    UITabBarController *tabBarVC = [[UITabBarController alloc] init];
    tabBarVC.tabBar.tintColor = [UIColor colorWithRed:19.f/255 green:115.f/255 blue:175.f/255 alpha:1.f];
    tabBarVC.delegate = (id)self;
    
    FeedViewController *feedVC = [[FeedViewController alloc] initWithNibName:nil bundle:nil];
    UIViewController *profileVC = nil;
    RateViewController* rateVC = [[RateViewController alloc] initWithNibName:nil bundle:nil];
    UIViewController *settingsVC = nil;
    
    if (mode == Guest)
    {
        profileVC = [[DefaultViewController alloc] initWithNibName:nil bundle:nil forType:FTDefaultVCTypeProfile];
        settingsVC= [[DefaultViewController alloc] initWithNibName:nil bundle:nil forType:FTDefaultVCTypeSettings];
    }
    else
    {
        profileVC = [[ProfileViewController alloc] initWithNibName:nil bundle:nil];
        settingsVC = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
    }

    
    UINavigationController *newsNavVC = [[UINavigationController alloc] initWithRootViewController:feedVC];
    newsNavVC.navigationBarHidden = YES;
    UINavigationController *profileNavVC = [[UINavigationController alloc] initWithRootViewController:profileVC];
    profileNavVC.navigationBarHidden = YES;
    UINavigationController *rateNavVC = [[UINavigationController alloc] initWithRootViewController:rateVC];
    rateNavVC.navigationBarHidden = YES;
    UINavigationController *settingsNavVC = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsNavVC.navigationBarHidden = YES;
    
    tabBarVC.viewControllers = [NSArray arrayWithObjects:newsNavVC, profileNavVC, rateNavVC, settingsNavVC, nil];    
        
    [self.navigationController pushViewController:tabBarVC animated:YES];
    
    [newsNavVC release];
    [profileNavVC release];
    [rateNavVC release];
    [settingsNavVC release];
    [feedVC release];
    [profileVC release];
    [rateVC release];
    [settingsVC release];
    [tabBarVC release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeselectCategory" object:nil];
}

- (void) showSearchControllerInNavController:(UINavigationController *) navVC
{
    SearchViewController *searchVC = nil;
    for (UIViewController *vc in navVC.viewControllers)
    {
        if ([vc isKindOfClass:[SearchViewController class]])
        {
            searchVC = (SearchViewController *)vc;
            [navVC popToViewController:searchVC animated:YES];
            return;
        }
    }
    searchVC = [[SearchViewController alloc] initWithNibName:nil bundle:nil];
    [navVC pushViewController:searchVC animated:YES];
    [searchVC release];
}

- (void) getUserWithBlock:(dispatch_block_t) block
{    
    int uid = [[[DataSource data] objectForKey:USER_ID] intValue];
    
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForGetProfileWithID:uid completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSDictionary *response = [(NetworkTaskGenerator *)item objectFromString];
            [_user release];
            _user = nil;
            
            FTUser *newUser = [FTUser new];
            newUser.typeOfUser = User;
            newUser.info = response;
            dbgLog(@"%@", response);
            [newUser parseUserInfo];
            
            self.user = newUser;
            [newUser release];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SAVE_USER object:nil];
            
            block();
        }
        [LoadingView hide];
    }];
    [[DispatchTools Instance] addTask:task];

}

- (void) popToLoginScreen
{
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[LoginViewController class]])
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        }
    }
    
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
    NSMutableArray *vcArray = [NSMutableArray arrayWithObject:loginVC];
    [self.navigationController setViewControllers:vcArray animated:YES];
    [self.navigationController popToViewController:loginVC animated:YES];
    [loginVC release];
}

- (void) avtoligonWitnUsername:(NSString *)username password:(NSString *)pass block:(dispatch_block_t) block
{
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForLanguage:@"ru" Login:username password:pass completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful || ((NetworkTaskGenerator *)item).statusCode == 406)
        {
            NSDictionary *response = [(NetworkTaskGenerator *)item objectFromString];
            @try {
                NSString *uid = [response objectForKey:@"uid"];
                if (uid)
                {
                    [[DataSource data] setObject:uid forKey:USER_ID];
                    [[DataSource data] setObject:username forKey:USER];
                    [[DataSource data] setObject:pass forKey:PASSWORD];
                    [[DataSource source] saveData];
                }
            }
            @catch (NSException *exception) {
                dbgLog(@"login error %@", exception);
            }
            
            [self getUserWithBlock:^{
                [self pushMainPagesWithMode:User];

                UIImageView *defaultView = (UIImageView *)[self.window viewWithTag:ID_IMG_DEFAULT];
                [defaultView removeFromSuperview];
            }];
            block();
        }
        else
        {
            block();
            [self popToLoginScreen];
            [LoadingView hide];
        }
    }];
    [[DispatchTools Instance] addTask:task];
}

- (BOOL) createdUser
{
    return self.user != nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    CategoryView *categoryView = [CategoryView loadView];
    CGRect rect = categoryView.frame;
    rect.origin.x = 0;
    rect.origin.y = 20;
    categoryView.frame = rect;
    categoryView.delegate = (id)self;    
    [self.window addSubview:categoryView];
    
    [[DataSource source] loadData];
    
    [[SettingSource source] countries];
    
//    NSString *userName = [[DataSource data] objectForKey:USER];
//    NSString *pass     = [[DataSource data] objectForKey:PASSWORD];
//    if ([userName length] > 0)
//    {
        UIImage *defaultImage = nil;
        if (![Tools isRetina4])
        {
            defaultImage = [UIImage imageNamed:@"Default"];
        }
        else
        {
            defaultImage = [UIImage imageNamed:@"Default-568h@2x.png"];
        }
        UIImageView *defaultView = [[UIImageView alloc] initWithImage:defaultImage];
        defaultView.frame = [UIScreen mainScreen].bounds;
        defaultView.tag   = ID_IMG_DEFAULT;
        [self.window addSubview:defaultView];
    
    _navigationController = [[UINavigationController alloc] init];
    self.window.rootViewController = _navigationController;
    self.navigationController.navigationBarHidden = YES;
    [self pushMainPagesWithMode:Guest];
    
    [defaultView removeFromSuperview];
    [defaultView release];

//    
//        [self avtoligonWitnUsername:userName password:pass block:^{
//            _navigationController = [[UINavigationController alloc] init];
//            self.window.rootViewController = _navigationController;
//            self.navigationController.navigationBarHidden = YES;
//        }];
//    }
//    else
//    {        
//        [self initNavigationControllerWithRootViewController:[Tools loadViewControllerNamed:@"LoginViewController"]];
//        self.navigationController.navigationBarHidden = YES;
//    }
    
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[DataSource source] clearImageCache];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[DataSource source] saveData];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark  - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([((UINavigationController *)viewController).topViewController isKindOfClass:[DefaultViewController class]])
    {
        [[AlertModule instance] createAlertWithType:LoginRequest buttons:2 withCancelBlock:^(UIAlertView *_alert) {
            
        } completeBlock:^(UIAlertView *_alert) {
            [self popToLoginScreen];
        }];
        [[AlertModule instance] showAlert];
    }
}

@end
