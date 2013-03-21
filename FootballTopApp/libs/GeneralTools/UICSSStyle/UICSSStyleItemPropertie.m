//
//  UICSSStyleItemProperties.m
//  ToolsTest
//
//  Created by destman on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UICSSStyleItemPropertie.h"


@implementation UICSSStyleItemPropertie

@synthesize value = _value;
@synthesize isObjCValue = _isObjCValue;

+(BOOL) parseInString:(NSString *)string ints:(int)count to:(int *)res
{
    if(string==nil)
        return NO;
    
	NSCharacterSet *divSet = [NSCharacterSet characterSetWithCharactersInString:@","];
	NSArray *vals = [string componentsSeparatedByCharactersInSet:divSet];
    if([vals count]!=count)
    {
        dbgLog(@"UICSSStyleItemPropertie: invalid value '%@'", string);
        return NO;
    }

    for (int i=0; i<count; i++) 
    {
        NSScanner *scanner = [NSScanner scannerWithString:[vals objectAtIndex:i]];
        if(![scanner scanInt:&res[i]])
        {
            dbgLog(@"UICSSStyleItemPropertie: invalid number '%@' in '%@'", [vals objectAtIndex:i] , string);
            return NO;
        }
    }
    return YES;
}

+(NSString *) getListString:(NSString *)string
{
	NSRange valsStart = [string rangeOfString:@"("];
	if(valsStart.location==NSNotFound)
	{
		dbgLog(@"UICSSStyleItemPropertie: expected '(' in '%@'", string);
		return nil;
	}
	NSRange valsEnd = [string rangeOfString:@")"];
	if(valsStart.location==NSNotFound)
	{
		dbgLog(@"UICSSStyleItemPropertie: expected ')' in '%@'", string);
		return nil;
	}
    return [string substringWithRange:NSMakeRange(valsStart.location+1, valsEnd.location-valsStart.location-1)];
}

-(UIColor *) parseRGBA:(NSString *)val
{
    int v[4];
	if(![UICSSStyleItemPropertie parseInString:[UICSSStyleItemPropertie getListString:val] ints:4 to:v])
	{
		return nil;
	}
	return [UIColor colorWithRed:(double)v[0]/255.0 green:(double)v[1]/255.0 blue:(double)v[2]/255.0 alpha:(double)v[3]/255.0];	
}

-(UIColor *) parseRGB:(NSString *)val
{
    int v[3]; 
	if(![UICSSStyleItemPropertie parseInString:[UICSSStyleItemPropertie getListString:val] ints:3 to:v])
	{
		return nil;
	}
	return [UIColor colorWithRed:(double)v[0]/255.0 green:(double)v[1]/255.0 blue:(double)v[2]/255.0 alpha:1];	
}

-(UIImage *) parseImage:(NSString *)val
{
    NSString *str = [UICSSStyleItemPropertie getListString:val];
    return [Tools hiresImageNamed:str];
}

-(BOOL) parseSource:(NSString *)source
{
	NSCharacterSet *divSet = [NSCharacterSet characterSetWithCharactersInString:@":="];
	NSArray *parts = [source componentsSeparatedByCharactersInSet:divSet];
	
	if([parts count]!=2)
	{
		dbgLog(@"UICSSStyleItemPropertie: syntax error in '%@'", source);
		return NO;
	}

	NSString *key = [[parts objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _key = [key retain];
    
	NSString *valueSrc = [[parts objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	id value = nil;
	
	if([valueSrc hasPrefix:@"rgba"])
	{
		value = [self parseRGBA:valueSrc];
	}else if([valueSrc hasPrefix:@"rgb"])
	{
		value = [self parseRGB:valueSrc];
	}else if([valueSrc hasPrefix:@"image"])
    {
        value = [self parseImage:valueSrc];
    }
        
    
    NSString *typeName = @"";
	if(value == nil)
	{
        NSScanner *scanner = [NSScanner scannerWithString:valueSrc];
        if(![scanner scanInt:(int *)&value])
        {
            dbgLog(@"UICSSStyleItemPropertie: can not understand value '%@'", valueSrc);
            return NO;
        }
        _isObjCValue=NO;
        _value = value;
	}else
    {
        _isObjCValue=YES;
        _value = [value retain];

        if([value isKindOfClass:[UIColor class]])
        {
            typeName = @"Color";
        }
    }
	
    NSMutableString *selectorName = [NSMutableString new];
    [selectorName appendString:@"set"];
    [selectorName appendString:[_key capitalizedString]];
    [selectorName appendString:typeName];
    
    _selSet         = NSSelectorFromString([selectorName stringByAppendingString:@":"]);
    _selSetForState = NSSelectorFromString([selectorName stringByAppendingString:@":forState:"]);
    
    _selGet         = NSSelectorFromString([_key stringByAppendingString:typeName]);
    _selGetForState = NSSelectorFromString([[_key stringByAppendingString:typeName] stringByAppendingString:@"ForState:"]);
    
    [selectorName release];
    
	return YES;
}

-(void) dealloc
{
	[_key release];
    if(_isObjCValue)
        [_value release];
	[super dealloc];
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

-(BOOL) setInObject:(NSObject *) obj forState:(UIControlState)state
{
    if([obj respondsToSelector:_selSetForState])
    {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[obj methodSignatureForSelector:_selSetForState]];        
        [inv setSelector:_selSetForState];
        [inv setArgument:&_value atIndex:2];
        [inv setArgument:&state atIndex:3];
        [inv retainArguments];
        [inv invokeWithTarget:obj];
        return YES;
    }    
    
    NSLog(@"Error setting '%@' in '%@'",_key, obj);
    return NO;
}

-(BOOL) setInObject:(NSObject *) obj
{
    if([obj respondsToSelector:_selSet])
    {
        [obj performSelector:_selSet withObject:_value];
        return YES;
    }
    return [self setInObject:obj forState:UIControlStateNormal];
}

-(id)   getFormObject:(NSObject *) obj forState:(UIControlState)state
{
    if([obj respondsToSelector:_selGetForState])
    {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[obj methodSignatureForSelector:_selGetForState]];        
        [inv setSelector:_selSetForState];
        [inv setArgument:&state atIndex:2];
        
        id rv;
        [inv invokeWithTarget:obj];
        [inv getReturnValue:&rv];
        return rv;
    }    
    
    NSLog(@"Error getting '%@' in '%@'",_key, obj);
    return nil;    
}


-(id)   getFormObject:(NSObject *) obj
{
    if([obj respondsToSelector:_selSet])
    {
        return [obj performSelector:_selGet withObject:nil];
    }
    return [self getFormObject:obj forState:UIControlStateNormal];    
}





@end
