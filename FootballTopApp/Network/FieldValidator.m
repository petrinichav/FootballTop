//
//  FieldValidator.m
//  Eneco Inzicht
//
//  Created by worker on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FieldValidator.h"

#define kPatternEmail @"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9]{2,}(?:[a-z0-9-]*[a-z0-9])?$"
#define kEmptyString @"^[ ]{0,}$"
#define kPatternLetters @"^([a-zA-Z]{1,}[ ]{0,}){1,}$"

@implementation FieldValidator

+ (BOOL) isEmailValid: (NSString*) text
{
    if (text) {
        NSString *patternEmail = kPatternEmail;
        NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:patternEmail options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray* result = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
        
        if([result count] !=0){
            [regex release];
            return YES;
        }
        else 
        {
            [regex release];
            return NO;
        }        
    }
    return NO;
}

+ (BOOL) isEptyString: (NSString*) text
{
    if (text) {
        NSString *patternEmail = kEmptyString;
        NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:patternEmail options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray* result = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
        
        if([result count] != 0){
            [regex release];
            return YES;
        }
        else 
        {
            [regex release];
            return NO;
        }        
    }
    return NO;
}

+ (BOOL)isWord:(NSString *)text
{
    if (text) {
        NSString *patternEmail = kPatternLetters;
        NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:patternEmail options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray* result = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
        
        if([result count] !=0){
            [regex release];
            return YES;
        }
        else
        {
            [regex release];
            return NO;
        }
    }
    return NO; 
}

@end
