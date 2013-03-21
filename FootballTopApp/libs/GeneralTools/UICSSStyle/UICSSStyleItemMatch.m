//
//  UICSSStyleItemMatch.m
//  ToolsTest
//
//  Created by destman on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UICSSStyleItemMatch.h"
#import "UICSSStyleItemPropertie.h"

@implementation UICSSStyleItemMatch

@synthesize matchState;

-(void) dealloc
{
    [_props release];
    [super dealloc];
}

-(BOOL) parseSource:(NSString *)source
{
	NSRange propStart = [source rangeOfString:@"["];
	NSRange propEnd = [source rangeOfString:@"]"];
	NSString *className = nil;
	NSString *props =nil;

	matchState = UIControlStateNormal;
	if([source hasSuffix:@":highlighted"])
	{
		source = [source stringByReplacingOccurrencesOfString:@":highlighted" withString:@""];
		matchState = UIControlStateHighlighted;
	}
	if([source hasSuffix:@":selected"])
	{
		source = [source stringByReplacingOccurrencesOfString:@":selected" withString:@""];
		matchState = UIControlStateSelected;
	}    
	
	if(propStart.location==NSNotFound)
	{
		className = source;
	}else
	{
		if (propEnd.location==NSNotFound) 
		{
			dbgLog(@"UICSSStyleItemMatch: expected ']' in '%@'", source);
			return NO;
		}
		className = [[source substringWithRange:NSMakeRange(0, propStart.location)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		props = [source substringWithRange:NSMakeRange(propStart.location+1, propEnd.location-propStart.location-1)];
	}
    
	_class = NSClassFromString(className);
	if(_class == nil)
	{
		dbgLog(@"UICSSStyleItemMatch: unknown class '%@' in '%@'", className, source);
		return NO;
	}
    
    if(props)
    {
        NSCharacterSet *propDivItemsSet = [NSCharacterSet characterSetWithCharactersInString:@","];
        NSArray *propStrings = [props componentsSeparatedByCharactersInSet:propDivItemsSet];
        
        _props = [[NSMutableArray alloc] init];
        for(NSString *prop in propStrings)
        {
            if([prop length]<2)
                continue;
            UICSSStyleItemPropertie *newProp = [[UICSSStyleItemPropertie alloc] initWithString:prop];
            if(!newProp)
                return NO;
            [_props addObject:newProp];
            [newProp release];
        }
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

-(BOOL) isMatching:(id) object
{
	if (![object isKindOfClass:_class]) 
	{
		return NO;
	}
	
	if(matchState != UIControlStateNormal && ![object isKindOfClass:[UIControl class]])
	{
		return NO;
	}
    
    for (UICSSStyleItemPropertie *prop in _props)
    {
        id val = [prop getFormObject:object];
        
        if(prop.isObjCValue)
        {
            if(![val isEqual:prop.value])
                return NO;
        }else
        {
            if(val!=prop.value)
                return NO;
        }
    }

	return YES;
}




@end
