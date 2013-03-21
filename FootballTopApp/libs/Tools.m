//
//  Tools.m
//  ToolsTest
//
//  Created by destman on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Tools.h"
#import "DataSource.h"

#if defined (AD_INFO_SERVICE_URL)
#import "AdsManager.h"
#endif

#if defined (AD_STATS_SERVICE_URL)
#import "AdsReporter.h"
#endif

#ifdef GANTrackerID
#import "GANTracker.h"
#else
#warning No GANTracker integration
#endif

#ifdef TapJoyAppID
#import "TapjoyConnect.h"
#endif

#if defined (FlurryID)
#import "FlurryAnalytics.h"
#endif

#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/xattr.h>


#import "CommonCrypto/CommonDigest.h"

@implementation Tools

@synthesize defaultBundle;

#ifdef AdMobReportAppID
#pragma mark -
#pragma mark AdMob
- (NSString *)hashedISU 
{
    NSString *result = nil;
    NSString *isu = [UIDevice currentDevice].uniqueIdentifier;
    if(isu) 
    {
        unsigned char digest[16];
        NSData *data = [isu dataUsingEncoding:NSASCIIStringEncoding];
        CC_MD5([data bytes], [data length], digest);
        result = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                  digest[0], digest[1], 
                  digest[2], digest[3],
                  digest[4], digest[5],
                  digest[6], digest[7],
                  digest[8], digest[9],
                  digest[10], digest[11],
                  digest[12], digest[13],
                  digest[14], digest[15]];
        result = [result uppercaseString];
    }
    return result;
}

- (void)reportAppOpenToAdMob
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // we're in a new thread here, so we need our own autorelease pool
    // Have we already reported an app open?
    if(![[[DataSource data] objectForKey:@"AdmobAppOpen"] isEqualToString:@"YES"])
    {
        // Not yet reported -- report now
        NSString *appOpenEndpoint = [NSString stringWithFormat:@"http://a.admob.com/f0?isu=%@&md5=1&app_id=%@", [self hashedISU], AdMobReportAppID];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:appOpenEndpoint]];
        NSURLResponse *response;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if((!error) && ([(NSHTTPURLResponse *)response statusCode] == 200) && ([responseData length] > 0)) 
        {
            [[DataSource data] setObject:@"YES" forKey:@"AdmobAppOpen"];
        }
    }
    [pool release];
}
#endif


#pragma mark -
#pragma mark Other
+(Tools *)Instance
{
	static Tools *instance;
	if(instance ==0)
	{
		instance = [[Tools alloc] init];
	}
	return instance;
}

-(id)init
{
	if( (self=[super init]) )
	{
        self.defaultBundle = [NSBundle mainBundle];
	}
	return self;
}

-(NSString *) expandTemplateParams:(NSString *)string
{
    NSString *rv = [string stringByReplacingOccurrencesOfString:@"%appname%" withString:appName];
    rv = [rv stringByReplacingOccurrencesOfString:@"%appversion%" withString:appVersion];
    return rv;
}

+(NSString *) expandTemplateParams:(NSString *)string
{
    return [[Tools Instance] expandTemplateParams:string];
}


-(void) itemAppear:(id)item
{
    if(visibleItem!=item)
    {
        dbgLog(@"Item Appear:%@",NSStringFromClass([item class]));

#ifdef GANTrackerID
        NSString *name = [@"/" stringByAppendingString:NSStringFromClass([item class])];
        NSError *error = 0;
        if(![[GANTracker sharedTracker] trackPageview:name withError:&error])
        {
            dbgLog(@"GANError: %@", error);
        }
#endif
        RELEASE(visibleItem);
        visibleItem = RETAIN(item);
    }
}

-(void) itemDisappear:(id)item
{
	dbgLog(@"Item dissappear:%@",NSStringFromClass([item class]));

	if(visibleItem == item)
	{
        RELEASE(visibleItem);
        visibleItem = 0;
	}
}

- (void) eventHappened:(NSString *)event label:(NSString *)label value:(NSInteger)value
{
	NSString *name = NSStringFromClass([visibleItem class]);
	dbgLog(@"Event happened: Categorie=%@ action=%@ label=%@ value=%d", name, event, label, value);
#ifdef GANTrackerID
	NSError *error = 0;
	if(![[GANTracker sharedTracker] trackEvent:name action:event label:label value:value withError:&error])
	{
		dbgLog(@"GANError: %@", error);
	}
#endif
}

-(void) sysEventHappened:(NSString *)event label:(NSString *)label value:(NSInteger)value
{
	dbgLog(@"Sys event happened: action=%@ label=%@ value=%d", event, label, value);
#ifdef GANTrackerID	
	NSString *name = @"SystemEvent";
	NSError *error = 0;
	if(![[GANTracker sharedTracker] trackEvent:name action:event label:label value:value withError:&error])
	{
		dbgLog(@"GANError: %@", error);
	}	
#endif
}

-(int) appActiveCount
{
	int val = [[[DataSource data] objectForKey:@"AppActiveCount"] intValue];
	return val;
}

-(void) increaseAppActiveCount
{
	int val = [self appActiveCount]+1;
    [[DataSource data] setObject:[NSNumber numberWithInt:val] forKey:@"AppActiveCount"];
    [[DataSource data] setObject:[NSDate date] forKey:@"LastActiveDate"];
}

-(int) runCount
{
	int runCount = [[[DataSource data] objectForKey:@"AppLaunchCount"] intValue];
	return runCount;
}

-(void) increaseRunCount
{
	int runCount = [self runCount]+1;
    [[DataSource data] setObject:[NSNumber numberWithInt:runCount] forKey:@"AppLaunchCount"];
}

-(NSDate *)lastActiveDate
{
    return [[DataSource data] objectForKey:@"LastActiveDate"];
}


-(void) updateVersionData
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];  
	NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:filePath];

    appName = RETAIN([info objectForKey:@"CFBundleName"]);
	appVersion =  RETAIN([info objectForKey:@"CFBundleVersion"]);
    appID  =  RETAIN([info objectForKey:@"CFBundleIdentifier"]);
	oldAppVersion =  RETAIN([[DataSource data] objectForKey:@"AppVersion"]);
    [[DataSource data] setObject:appVersion forKey:@"AppVersion"];
}

-(void) appGoToBackgound
{
    [[DataSource source] saveData];
	[self sysEventHappened:@"AppBackground" label:@"" value:0];
}

-(void) appGoToForeground
{
    [self increaseAppActiveCount];
#if defined (AD_INFO_SERVICE_URL)
    [[AdsManager Instance] updateData];    
#endif
	[self sysEventHappened:@"AppForeground" label:@"" value:0];
}

-(void) appTerminate
{
    [[DataSource source] saveData];
	[self sysEventHappened:@"AppTerminate" label:@"" value:0];
}

#if defined(TapJoyAppID) && defined(TapJoyAppSecret)
-(void) _tapjoyConnected
{
    dbgLog(@"Tapjoy: connected.");
}

-(void) _tapjoyFailedConnect
{
    dbgLog(@"Tapjoy: failed connect");
}
#endif


-(void)appStart
{
#ifdef GANTrackerID
    {
        int dispatchPeriod = 10; 
        [[GANTracker sharedTracker] startTrackerWithAccountID:GANTrackerID
                                               dispatchPeriod:dispatchPeriod
                                                     delegate:nil];	
    }
#endif
    
#if defined (FlurryID)
//  [FlurryAppCircle setAppCircleEnabled:YES]; 
    [FlurryAnalytics startSession:FlurryID];    
#endif

#if defined(TapJoyAppID) && defined(TapJoyAppSecret)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tapjoyConnected) name:TJC_CONNECT_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tapjoyFailedConnect) name:TJC_CONNECT_FAILED object:nil];
    [TapjoyConnect requestTapjoyConnect:TapJoyAppID secretKey:TapJoyAppSecret];
#else
#warning Tapjoy not used. Define TapJoyAppID and TapJoyAppSecret in app pch file.
#endif
    
	NSString *launchType = nil;
	
	if([self runCount]==0)
	{
		launchType = @"FirstLaunch";
	}else
	{
		launchType = @"AppLaunch";
	}
	
	UIDevice *device = [UIDevice currentDevice];
	NSString *deviceInfo = [[Tools platformExpanded] stringByAppendingFormat:@"-%@",device.systemVersion];
	if([Tools isJailBroken])
		deviceInfo = [deviceInfo stringByAppendingString:@"-JB"];
	[self sysEventHappened:launchType label:deviceInfo value:0];
	[self updateVersionData];
	if(oldAppVersion!=nil && ![appVersion isEqualToString:oldAppVersion])
	{
        [self sysEventHappened:[NSString stringWithFormat:@"Update from %@ to %@",oldAppVersion, appVersion] label:@"" value:0];
	}
	[self increaseRunCount];
    [self increaseAppActiveCount];

#if defined (AD_STATS_SERVICE_URL)
    if(self.runCount==1)
    {
        [AdsReporter reportFirstStart];
    }
	[[AdsManager Instance] updateData];
#endif
    
#ifdef AdMobReportAppID
    [self performSelectorInBackground:@selector(reportAppOpenToAdMob) withObject:nil];
#endif
    
#if defined (ChartsBoostsAppID)
    // Configure ChartBoost
    cb = [ChartBoost sharedChartBoost];
    cb.appId = ChartsBoostsAppID;
    cb.appSignature = ChartBoostsAppSignature;
    // Notify an install
    [cb install];
#if defined ChartBoostShouldNotShowAds
    [cb retain];
    cb = nil;
#endif
    // Load interstitial
    [cb showInterstitial];   
    [cb retain];
#endif
    [[DataSource source] saveData];
}

- (NSString *) appName
{
    return appName;
}

- (NSString *) appVersion
{
    return appVersion;
}

- (NSString *) appID
{
    return appID;
}

+ (BOOL) isJailBroken
{
	for (NSString *file in [NSArray arrayWithObjects:
							@"/Applications/Cydia.app", 
							@"/Applications/limera1n.app", 
							@"/Applications/greenpois0n.app", 
							@"/Applications/blackra1n.app",
							@"/Applications/blacksn0w.app",
							@"/Applications/redsn0w.app",							
							nil
							])
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath:file])
		{
			return YES;
		}		
	}
	return NO;
}

+(BOOL) isIPad
{
	return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

+ (BOOL) isSystemVersionGreaterThanOrEqualTo:(NSString *)version
{
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: version 
                                                                       options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending) 
        return YES;
    else 
        return NO;
}

+ (BOOL)addMobileBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

+ (NSString *) platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

+ (NSString *) platformExpanded
{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 WiFi";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 GSM";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 CDMA";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    return platform;
}

+(BOOL) haveGameCenter
{
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	return ([currSysVer compare:@"4.1" options:NSNumericSearch] != NSOrderedAscending) && gcClass!=nil;
}

+(UIViewController *) loadViewControllerNamed:(NSString *)name useDefaultBundle:(BOOL)useDefaultBundle
{
	Class vcClass = NSClassFromString(name);
	if(vcClass == nil)
	{
		dbgLog(@"Failed to load view controller %@. No such class.",name);
		return nil;
	}
    
    if(!useDefaultBundle)
    {
        return AUTORELEASE([[vcClass alloc] initWithNibName:nil bundle:nil]);
    }
	return AUTORELEASE([[vcClass alloc] initWithNibName:nil bundle:[Tools Instance].defaultBundle]);
}


+(UIViewController *) loadViewControllerNamed:(NSString *)name
{
    return [self loadViewControllerNamed:name useDefaultBundle:YES];
}

+(UINavigationController *) loadToNavigationControlerViewControllerNamed:(NSString *)name
{
    UIViewController *vc = [Tools loadViewControllerNamed:name];
    if(vc)
    {
        return AUTORELEASE([[UINavigationController alloc] initWithRootViewController:vc]);
    }
    return nil;
}

+ (UIImage*)hiresImageNamed:(NSString *)name inBundle:(NSBundle *)bundle
{
    UIImage *rv = nil;
    if(![Tools isIPad])
    {
        if ([UIScreen instancesRespondToSelector:@selector(scale)] && [UIScreen mainScreen].scale==2.0 ) 
        {
            NSString *name2x = [NSString stringWithFormat:@"%@@2x.%@", 
                                [name stringByDeletingPathExtension], 
                                [name pathExtension]];
            rv = [UIImage imageWithContentsOfFile:[bundle pathForResource:name2x ofType:nil]];
        }
    }
    if(rv == nil)
    {
        rv = [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:nil]];
    }
	return rv;    
}

+ (UIImage*)hiresImageNamed:(NSString *)name useDefaultBundle:(BOOL)useDefaultBundle
{
    NSBundle *bundle;
    if(useDefaultBundle)
    {
        bundle = [Tools Instance].defaultBundle;
    }else
    {
        bundle = [NSBundle mainBundle];
    }
    
    return [self hiresImageNamed:name inBundle:bundle];    
}

+ (UIImage*)hiresImageNamed:(NSString *)name
{
	return [self hiresImageNamed:name useDefaultBundle:YES];
}


+(UIView *) findFirstResponderAtView:(UIView *)view
{
    if (view.isFirstResponder) 
    {
        return view;
    }
    
    for (UIView *subView in view.subviews) 
    {
        UIView *firstResponder = [self findFirstResponderAtView:subView];
        if (firstResponder != nil) 
        {
            return firstResponder;
        }
    }
    return nil;
}

+(UIView *) findFirstResponder
{
    UIView *rv = nil;
    for (UIView *view in [UIApplication sharedApplication].windows) 
    {
        rv = [self findFirstResponderAtView:view];
        if(rv)break;
    }
    return rv;
}

+ (BOOL) isRetina4
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    if (bounds.size.height == 568)
        return YES;
    
    return NO;
}

+ (NSString *) xibForRetina4_inch:(NSString *)xib
{
    if ([Tools isRetina4])
    {
        return [NSString stringWithFormat:@"%@-568h@2x", xib];
    }
    
    return xib;
}

@end
