//
//  Localization.m
//  IPhoneSpeedTracker
//
//  Created by destman on 12/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Localization.h"


@implementation LocalizationTableInfo

@synthesize tableBundle = _tableBundle;
@synthesize tableName   = _tableName;

#if !HAVE_ARC
-(void) dealloc
{
    [_tableName release];
    [_tableBundle release];
    [super dealloc];
}
#endif

@end


@implementation Localization


-(void) addLocalizationTable:(LocalizationTableInfo *)table
{
    for (LocalizationTableInfo *val in tables)
    {
        if(val.tableBundle == table.tableBundle && [val.tableName isEqualToString:table.tableName])
        {
            return;
        }
    }
    dbgLog(@"Added localization table:%@",table.tableName);
    [tables addObject:table];
}

-(void) scanBundleForLocalizationTables:(NSBundle *)bundle curDir:(NSString *)dir
{
    NSArray *dirContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
    for (NSString *file in dirContent) 
    {
        if([[file pathExtension] isEqualToString:@"strings"]) 
        {
            LocalizationTableInfo *info = [[LocalizationTableInfo alloc] init];
            info.tableBundle = bundle;
            info.tableName = [file stringByDeletingPathExtension];
            [self addLocalizationTable:info];
            RELEASE(info);
        }
        if([[file pathExtension] isEqualToString:@"lproj"])
        {
            [self scanBundleForLocalizationTables:bundle curDir:[dir stringByAppendingPathComponent:file]];
        }
    }  
}

-(void) scanBundleForLocalizationTables:(NSBundle *)bundle
{
    [self scanBundleForLocalizationTables:bundle curDir:[bundle bundlePath]];
}

-(id) init
{
    if( (self = [super init]) )
    {
        tables = [[NSMutableArray alloc] init];
        [self scanBundleForLocalizationTables:[NSBundle mainBundle]];
    }
    return self;
}

+(Localization *) Instance
{
    static Localization *instance;
    if(instance == 0)
    {
        instance = [[Localization alloc] init];
    }
    return instance;
}

-(NSString *) localizationForKey:(NSString *)key
{
    for (LocalizationTableInfo *table in tables)
    {
        NSString *val = [table.tableBundle localizedStringForKey:key value:nil table:table.tableName];
        if(val != key)
        {
            if([key hasSuffix:@"_Tmpl"])
            {
                return [Tools expandTemplateParams:val];
            }else
            {
                return val;
            }
        }
    }
    dbgLog(@"Failed to find localization for key:%@",key);
    return key;
}

+(void)localizeView:(UIView *)baseView recursive:(BOOL)recursive
{
	for(UIView *view in baseView.subviews)
	{
		if(recursive)
			[self localizeView:view recursive:YES];
		
		if([view respondsToSelector:@selector(text)] && [view respondsToSelector:@selector(setText:)])
		{
			NSString *locKey = [view performSelector:@selector(text)];
			if([locKey hasPrefix:@"_Loc_"])
			{
				NSString *locText = Loc(locKey);
				[view performSelector:@selector(setText:) withObject:locText];
			}
		}
		
		if([view isKindOfClass:[UIButton class]])
		{
			UIButton *tView = (UIButton *)view;
			NSString *defKey = [tView titleForState:UIControlStateNormal];
			if([defKey hasPrefix:@"_Loc_"])
			{
				NSString *locText = Loc(defKey);
				[tView setTitle:locText forState:UIControlStateNormal];
			}
		}
	}
}


+ (void) localizeView:(UIView *)view
{
	[self localizeView:view recursive:YES];
}

@end
