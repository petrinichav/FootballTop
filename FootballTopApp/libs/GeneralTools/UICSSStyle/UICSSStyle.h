//
//  UICSSStyle.h
//  ToolsTest
//
//  Created by destman on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UICSSStyle : NSObject 
{
	NSMutableArray *_rules;
}

-(void) appendRulesString:(NSString *)source;
-(void) applyStyleToView:(UIView *)view;

+(UICSSStyle *) styleFromString:(NSString *)source;
+(UICSSStyle *) styleFromFile:(NSString *)name;

@end
