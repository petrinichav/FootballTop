//
//  CustomAlertView.m
//  T3Lockey
//
//  Created by Alex Petrinich on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomAlertView.h"

@implementation CustomAlertView
@synthesize cancelBlock, completeBlock;
@synthesize type;

- (void) dealloc
{
    [cancelBlock release];
    [completeBlock release];
    [super dealloc];
}



@end
