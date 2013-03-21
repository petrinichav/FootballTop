//
//  UICSSStyleItem.h
//  ToolsTest
//
//  Created by destman on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UICSSStyleItemMatch.h"

typedef enum
{
	NoRelation      =0,
	DirectParent    =1,
	AnyParent       =2
}ParentRelation;

@interface UICSSStyleItem : NSObject 
{
	ParentRelation parentRelation;
	UICSSStyleItemMatch *itemMatch,*parentMatch;
}

-(id) initWithString:(NSString *)source;


-(BOOL) matchesToView:(UIView *)view;

@end
