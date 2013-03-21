//
//  UICSSStyleRule.m
//  ToolsTest
//
//  Created by destman on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UICSSStyleRule.h"
#import "UICSSStyleItem.h"
#import "UICSSStyleItemPropertie.h"

@implementation UICSSStyleRule

-(id) init
{
	if( (self=[super init]) )
	{
		items = [[NSMutableArray alloc] init];
		properties = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) dealloc
{
	[items release];
	[properties release];
	[super dealloc];
}

-(BOOL) parseSource:(NSString *)source
{
	source = [Tools removeCPPStyleCommentsFromString:source];
	
	NSCharacterSet *ruleDivSet = [NSCharacterSet characterSetWithCharactersInString:@"{"];
	NSArray *ruleParts = [source componentsSeparatedByCharactersInSet:ruleDivSet];
	if([ruleParts count]!=2)
	{
		dbgLog(@"UICSSStyleRule: Error invalid syntax in rule '%@'", source);
		return NO;
	}

	NSCharacterSet *ruleDivItemsSet = [NSCharacterSet characterSetWithCharactersInString:@","];
	NSArray *ruleItems = [[ruleParts objectAtIndex:0] componentsSeparatedByCharactersInSet:ruleDivItemsSet];
	for(NSString *source in ruleItems)
	{
		source = [source stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if([source length]<2)
			continue;
		UICSSStyleItem *item = [[UICSSStyleItem alloc] initWithString:source];
		if(item)
		{
			[items addObject:item];
			[item release];
		}
	}
	
	NSCharacterSet *ruleDivParamsSet = [NSCharacterSet characterSetWithCharactersInString:@";"];
	NSArray *ruleParams = [[ruleParts objectAtIndex:1] componentsSeparatedByCharactersInSet:ruleDivParamsSet];
	for(NSString *source in ruleParams)
	{
		source = [source stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if([source length]<2)
			continue;
		UICSSStyleItemPropertie *item = [[UICSSStyleItemPropertie alloc] initWithString:source];
		if(item)
		{
			[properties addObject:item];
			[item release];
		}
	}
	
	if([items count]==0)
	{
		dbgLog(@"UICSSStyleRule: Error no valid items for item '%@'", source);
		return NO;	
	}

	if([properties count]==0)
	{
		dbgLog(@"UICSSStyleRule: Error no valid properties for item '%@'", source);
		return NO;	
	}
	return YES;
}


-(id) initWithString:(NSString *)source
{
	if( (self=[self init]) )
	{
		if(![self parseSource:source])
		{
			[self release];
			return nil;
		}
	}
	return self;
}

+(id) ruleWithString:(NSString *)source
{
	return [[[self alloc] initWithString:source] autorelease];
}

-(void) applyRuleToView:(UIView *)view
{
    BOOL matches = NO;
    for (UICSSStyleItem *item in items) 
    {
        if([item matchesToView:view])
        {
            matches = YES;
            break;
        }
    }
    
    if(matches)
    {
        for (UICSSStyleItemPropertie *prop in properties) 
        {
            [prop setInObject:view];
        }
    }
}


@end
