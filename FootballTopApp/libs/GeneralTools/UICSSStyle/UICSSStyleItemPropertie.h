//
//  UICSSStyleItemProperties.h
//  ToolsTest
//
//  Created by destman on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UICSSStyleItemPropertie : NSObject 
{
    BOOL        _isObjCValue;
	NSString	*_key;
    SEL         _selSet,_selSetForState,_selGet,_selGetForState;
	id			_value;
}

@property (readonly) id     value;
@property (readonly) BOOL   isObjCValue;

-(id) initWithString:(NSString *)source;

-(BOOL) setInObject:(NSObject *) obj;
-(BOOL) setInObject:(NSObject *) obj forState:(UIControlState)state;

-(id)   getFormObject:(NSObject *) obj;
-(id)   getFormObject:(NSObject *) obj forState:(UIControlState)state;

@end
