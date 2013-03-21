//
//  Tools.h
//  ToolsTest
//
//  Created by destman on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#include "GeneralTools/Logger.h"
#include "GeneralTools/UsefullOBJCMacro.h"

#if defined(__OBJC__)

#if defined (ChartsBoostsAppID)
#import "ChartBoost.h"
#endif

#import <Foundation/Foundation.h>
#import "GeneralTools/Localization.h"
#import "GeneralTools/UIViewControllerBase.h"
#import "GeneralTools/UsefullOBJCMacro.h"

/*! @defgroup ChangeNotifications Object change notification*/

/*! \interface Tools
 *  \brief Singletone class wiht general tools for applications.
 *
 *  Act as a run-time storage for information about application.
 *  Also contains usefull methods for loading resources, 
 *  reporting events and performing general task.
 */
@interface Tools : NSObject 
{
    /*!
        Store current visible item. This item will be used to report statistics.
     */
	id						visibleItem;
    
    /*! 
        Version of application that was detected at last launch
     */
    NSString                *oldAppVersion;

	NSString				*appVersion;
    NSBundle                *defaultBundle;
    NSString                *appName,*appID;
    
#if defined (ChartsBoostsAppID)
    ChartBoost              *cb;
#endif
}

/*!
 * NSString with name of application form Info.plist (key CFBundleName).
 */
@property (readonly) NSString   *appName;

/*!
 * NSString with version of application form Info.plist (key CFBundleVersion).
 */
@property (readonly) NSString   *appVersion;

/*!
 * NSString with application bundle id form Info.plist (key CFBundleIdentifier).
 */
@property (readonly) NSString   *appID;


/*!
 * NSDate with last time application was active (stored in DataSource).
 */
@property (readonly) NSDate     *lastActiveDate;

/*!
 * int with application runs count.
 */
@property (readonly) int        runCount;

/*!
 * int with application become active count.
 */
@property (readonly) int        appActiveCount;

/*! Bundle with resources that will be loaded by Tools.
    By default it is equal to [NSBundle mainBundle].
 */
@property (retain) NSBundle     *defaultBundle;

/*!
 * method to get singletone instance.
 * @returns singletone Tools instance
 */
+(Tools *)Instance;

/*!
 * @returns YES if running at iPad.
 */
+(BOOL) isIPad;

/*!
 * Checks out if systemVersion >= version.
 * @param version NSString with system version (ex @"5.0.1").
 * @returns YES if current system version >= version
 */
+(BOOL) isSystemVersionGreaterThanOrEqualTo:(NSString *)version;

/*!
 * Use to prevent iCloud backup.
 * The new "do not back up" attribute will only be used by iOS 5.0.1 or later.
 * On iOS 5.0 and earlier, applications will need to store their data in
 * [Application_Home]/Library/Caches to avoid having it backed up. Since this
 * attribute is ignored on older systems, you will need to insure your app complies
 * with the iOS Data Storage Guidelines on all versions of iOS that your application
 * supports.
 * @param URL (NSURL *) file/directory url
 * @returns YES if operation was successfull
 */
+(BOOL) addMobileBackupAttributeToItemAtURL:(NSURL *)URL;

/*!
 * @returns YES if device have GameCenter.
 */
+(BOOL) haveGameCenter;

/*!
 * @returns YES if device possibly jailbroken
 */
+(BOOL) isJailBroken;

/*!
 * Return platrofm name (ex "iPhone2,1").
 * @returns NSString with platrorm name.
 */
+(NSString *) platform;

/*!
 * Return NSString with expanded platrorm name (ex "Phone 4"). Not works for all platrorms.
 * If failed to expand - will return same as method platform.
 * @returns NSString with expaneded platrorm name.
 */
+(NSString *) platformExpanded;

/*!
 * Load view controller with provided class name.
 * @param name              NSString with class name of UIViewController to load
 * @param useDefaultBundle  if YES - uses defaultBundle. if NO - uses mainBundle.
 * @returns loaded UIViewController subclass
 */
+(UIViewController *) loadViewControllerNamed:(NSString *)name useDefaultBundle:(BOOL)useDefaultBundle;

/*!
 * Load view controller from defaultBundle with provided class name.
 * @param name NSString with class name of UIViewController to load
 * @returns loaded UIViewController subclass
 */
+(UIViewController *) loadViewControllerNamed:(NSString *)name;

/*!
 * Create UINavigationController and initialize it with provided view controller class name;
 * @param name NSString with class name of UIViewController to load
 * @returns created UINavigationController
 */
+(UINavigationController *) loadToNavigationControlerViewControllerNamed:(NSString *)name;

/**
 *	At device with retina display - loads retina variant of image if exist. 
 *  At other device - loads normal variant of image;
 *	@param name NSStrin with image name
 *	@param bundle NSBundle with image.
 *	@returns UIImage with loaded image.
 */
+ (UIImage*)hiresImageNamed:(NSString *)name inBundle:(NSBundle *)bundle;

/**
 *	At device with retina display - loads retina variant of image if exist.
 *  At other device - loads normal variant of image;
 *	@param name NSStrin with image name
 *	@param useDefaultBundle if YES - uses defaultBundle. if NO - uses mainBundle.
 *	@returns UIImage with loaded image.
 */
+ (UIImage*)hiresImageNamed:(NSString *)name useDefaultBundle:(BOOL)useDefaultBundle;

/**
 *	Short variant of previous function. Loads image from default bundle.
 *  @param name NSStrin with image name
 *  @returns UIImage with loaded image. 
 */
+ (UIImage*)hiresImageNamed:(NSString *)name;


/*! \addtogroup AppLifeCyecleGroup Application life cycle functions
 *  This functions must be called from application delegate to perform general actions
 *  at startup. If your application delegate is AppDelegateBase subclass - don't forget 
 *  to call super methods.
 *  @{
 */
/*! Must be called once at application startup */
-(void) appStart;
/*! Must be called once at application terminate */
-(void) appTerminate;
/*! Must be called when application goes to background */
-(void) appGoToBackgound;
/*! Must be called when application goes to foreground */
-(void) appGoToForeground;
/*! @} */

/*! Report page view event
    Call of this function must be ballanced with itemDisappear.
    @param item object that will be repoted. For reporting will be used it's class name.
 */
-(void) itemAppear:(id)item;

/*! Report disappear of item reported my itemAppear method. 
    @param item object that was dissapeared.
 */
-(void) itemDisappear:(id)item;

/*! Report event
 *  @param event event name      (ex "btnStart").
 *  @param label used if some detailes available (ex "ON","OFF").
 *  @param value if some digital data available (ex scores after game stops).
 */
-(void) eventHappened:(NSString *)event label:(NSString *)label value:(NSInteger)value;

/*! Report system event.
 *  @param event event name      (ex "btnStart").
 *  @param label used if some detailes available (ex "ON","OFF").
 *  @param value if some digital data available (ex scores after game stops).
 */
-(void) sysEventHappened:(NSString *)event label:(NSString *)label value:(NSInteger)value;


/*! Expand template parameters (like "%appname%" and "%appversion%").
 *  Used in localization. Or in any other place if needed.
 *  @param string template string
 *  \return NSString with replaced parameters
 */
+(NSString *) expandTemplateParams:(NSString *)string;

/**
 *  Find first responder at all application's windows.
 * \return UIView that is first responder or nil if none.
 */
+(UIView *) findFirstResponder;

/**
 *  Find first responder at provided UIView.
 *  @param view UIView to use in recursive search.
 *  \return UIView that is first responder or nil if none.
 */
+(UIView *) findFirstResponderAtView:(UIView *)view;

+ (BOOL) isRetina4;
+ (NSString *) xibForRetina4_inch:(NSString *)xib;

@end

#endif
