//
//  AppHelper.h
//  iPhoneExpoTools
//
//  Created by Alex Petrinich on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoadingView.h"

@class UnderlinedButton;

enum 
{  
    ID_TXTFIELD_LOGIN = 100,
    ID_TXTFIELD_PASS  = 101,
    ID_TXTFIELD_EMAIL = 102,
    
    ID_LBL_TITLE      = 200,
    ID_LBL_CREATOR    = 201,
    ID_LBL_DATE       = 202,
    ID_LBL_VOTES      = 203,
    ID_LBL_COMMENTS   = 204,
    ID_LBL_BODY       = 205,
    ID_LBL_NAV_TITLE  = 206,
    ID_LBL_CAPTION    = 207,
    ID_LBL_CLUB       = 208,
    ID_LBL_GENDER     = 209,
    ID_LBL_COUTRY     = 210,
    ID_LBL_CITY       = 211,
    ID_LBL_ADD_VOTE   = 212,
    ID_LBL_TITLE_COUNTRY = 213,
    ID_LBL_TITLE_BDATE   = 214,
    
    ID_IMG_LOGO       = 300,
    ID_IMG_PROFILE    = 301,
    ID_IMG_LINE       = 302,
    ID_IMG_DEFAULT    = 304,
    
    ID_WEB_VIEW       = 400,
    ID_WEB_GRAPH      = 401,
    
    ID_COMMENTS_VIEW  = 500,
    ID_PICKER         = 501,
    ID_PICKER_VIEW    = 502,
    
    ID_BTN_ADD_VOTE   = 600,
};

enum
{
    ItemPlayer       = 1,
    ItemCoach        = 4,
    ItemClub         = 2,
    ItemTeam         = 3,
    ItemChempionship = 5,
};

enum
{
    NewsViewModeMini,
    NewsViewModeTeaser,
    NewsViewModeFull,
};

enum
{
    Guest = 0,
    User  = 1,
};

@class Event;

@interface AppHelper : NSObject

+ (NSString *)applicationDocumentsDirectory ;
+ (NSString*) getDeviceID;

+ (NSString *) pathInDirectoryForFile:(NSString *)name;
+ (NSString *) documentDirectory;
+ (NSArray *) files;

+ (NSString *) deleteBadCharacterFromString:(NSString *)str;

+ (float) getCellSizeForText:(NSString *)text font:(UIFont *)font width:(CGFloat) width;
+ (float) getCellSizeForSurveyPreview:(NSString *)text font:(UIFont *)font;

+ (NSDate *) dateFromString:(NSString *) value forFormat:(NSString *)format;
+ (NSString *) date:(NSDate *)date withFormat:(NSString *) format;
+ (NSString *) dateFromString:(NSString *)dateStr fromFormat:(NSString *)oldFormat toFormat:(NSString *) newformat;

+ (NSString *) shortFormatDate:(NSDate *)date;
+ (NSString *) formatDate:(NSDate *)date;
+ (NSString *) dateForLeadList:(NSDate *)date;
+ (NSString*) dateForEventList: (NSDate*) date;

+ (NSString*) dateForEventListStart: (NSDate*) startDate end: (NSDate*) endDate;

+ (NSString *) dateRangeForMainScreen:(NSDate *)start end: (NSDate*) end;

+ (NSString *) stringValueForNumber:(int) number;

+ (int) dayFromDate:(NSDate *) date;

+ (UnderlinedButton *) createUnderlinedButtonWithText:(NSString *)title fromView:(UIView *)parentView point:(CGPoint)point target:(id)target selector:(SEL)method;

@end
