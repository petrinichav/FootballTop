//
//  UICSSStyleItemMatch.h
//  ToolsTest
//
//  Created by destman on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UICSSStyleItemMatch : NSObject 
{
	NSMutableArray	*_props;
	Class _class;
	UIControlState matchState;
}

@property (readonly) UIControlState matchState;

-(id) initWithString:(NSString *)source;

-(BOOL) isMatching:(id) object;


@end
