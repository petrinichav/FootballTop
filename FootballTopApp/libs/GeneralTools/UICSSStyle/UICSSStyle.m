//
//  UICSSStyle.m
//  ToolsTest
//
//  Created by destman on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UICSSStyle.h"
#import "UICSSStyleRule.h"

@implementation UICSSStyle

+(UICSSStyle *) styleFromString:(NSString *)source
{
	UICSSStyle *rv = [[UICSSStyle alloc] init];
	[rv appendRulesString:source];
	return [rv autorelease];
}

+(UICSSStyle *) styleFromFile:(NSString *)fileName
{
	NSString *source = [NSString stringWithContentsOfFile:fileName 
												 encoding:NSUTF8StringEncoding error:nil];
	if(source!=nil)
	{
		return [self styleFromString:source];
	}
	return nil;
}


-(void) dealloc
{
	[_rules release];
	[super dealloc];
}

-(id) init
{
	if( (self=[super init]) )
	{
		_rules = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) appendRulesString:(NSString *)source
{
	NSCharacterSet *ruleEndSet = [NSCharacterSet characterSetWithCharactersInString:@"}"];
	NSArray *rulesSource = [source componentsSeparatedByCharactersInSet:ruleEndSet];
	for(NSString *ruleSource in rulesSource)
	{
		ruleSource = [ruleSource stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if([ruleSource length]<2)
			continue;
		UICSSStyleRule *newRule = [[UICSSStyleRule alloc] initWithString:ruleSource];
		if(newRule)
		{
			[_rules addObject:newRule];
			[newRule release];
		}
	}
	dbgLog(@"UICSSStyle: %d rules after parsing",[_rules count]);
}

-(void) applyStyleToView:(UIView *)view
{
    for (UICSSStyleRule *rule in _rules) 
    {
        [rule applyRuleToView:view];
    }
    
    for (UIView *subView in view.subviews) 
    {
        [self applyStyleToView:subView];
    }
}


@end
