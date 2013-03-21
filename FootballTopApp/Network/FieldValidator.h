//
//  FieldValidator.h
//  Eneco Inzicht
//
//  Created by worker on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FieldValidator : NSObject

+ (BOOL) isEmailValid: (NSString*) text;
+ (BOOL) isEptyString: (NSString*) text;
+ (BOOL) isWord: (NSString*) text;
@end
