//
//  Localization.h
//  IPhoneSpeedTracker
//
//  Created by destman on 12/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Loc(str) [[Localization Instance] localizationForKey:str]

@interface LocalizationTableInfo : NSObject 
{
    NSBundle *_tableBundle;
    NSString *_tableName;
}

@property(retain) NSBundle *tableBundle;
@property(retain) NSString *tableName;

@end


@interface Localization : NSObject 
{
    NSMutableArray  *tables;
}

+(Localization *) Instance;
+(void) localizeView:(UIView *)view recursive:(BOOL)recursive;
+(void) localizeView:(UIView *)view;

-(NSString *) localizationForKey:(NSString *)key;
-(void) scanBundleForLocalizationTables:(NSBundle *)bundle;

@end
