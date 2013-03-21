//
//  UICSSStyleItem.m
//  ToolsTest
//
//  Created by destman on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UICSSStyleItem.h"


@implementation UICSSStyleItem

-(void) dealloc
{
	[itemMatch release];
	[parentMatch release];
	[super dealloc];
}

-(BOOL) parseSource:(NSString *)source
{
	NSCharacterSet *divSet = [NSCharacterSet characterSetWithCharactersInString:@" >"];
	NSArray *parts = [source componentsSeparatedByCharactersInSet:divSet];
	NSMutableArray *filteredParts = [[[NSMutableArray alloc] init] autorelease];
	for (NSString *item in parts) 
	{
		item = [item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		if([item length]==0)
			continue;
		[filteredParts addObject:item];
	}
	
	if([filteredParts count]>2 || [filteredParts count]<=0)
	{
		dbgLog(@"UICSSStyleItem: invalid syntax '%@'", source);
		return NO;
	}
	
	itemMatch = [[UICSSStyleItemMatch alloc] initWithString:[filteredParts objectAtIndex:0]];
	if(itemMatch==nil)
		return NO;
	parentRelation = NoRelation;
	
	if([filteredParts count]>=2)
	{
		parentMatch =  [[UICSSStyleItemMatch alloc] initWithString:[filteredParts objectAtIndex:1]];
		if(parentMatch==nil)
			return NO;
		
		if([source rangeOfString:@">"].location!=NSNotFound)
			parentRelation = DirectParent;
		else
			parentRelation = AnyParent;
		
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

-(BOOL) matchesToView:(UIView *)view
{
    if(![itemMatch isMatching:view])
        return NO;
    
    if(parentRelation==NoRelation)
        return YES;

    UIView *superview = view.superview;
    if(superview==nil)
        return NO;
    
    if(parentRelation==DirectParent)
    {
        return [parentMatch isMatching:superview];
    }
    
    if(parentRelation==AnyParent)
    {
        while (superview) 
        {
            if([parentMatch isMatching:superview])
                return YES;
            superview = superview.superview;
        }
    }
    return NO;
}


@end
