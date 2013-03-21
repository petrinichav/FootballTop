//
//  UICSSStyleRule.h
//  ToolsTest
//
//  Created by destman on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UICSSStyleRule : NSObject 
{
	NSMutableArray *items;
	NSMutableArray *properties;
}

-(void) applyRuleToView:(UIView *) view;

-(id) initWithString:(NSString *)source;
+(id) ruleWithString:(NSString *)source;


@end
