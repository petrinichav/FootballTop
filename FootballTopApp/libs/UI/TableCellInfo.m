//
//  CellInfo.m
//  Fuel Tracker
//
//  Created by Arkadiy Tolkun on 21.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TableCellInfo.h"

@implementation TableCellInfo

@synthesize action      = _action;
@synthesize config      = _config;
@synthesize create      = _create;
@synthesize params      = _params;
@synthesize editStyle   = _editStyle;
@synthesize editAction  = _editAction;

-(id) init
{
    if( (self=[super init]) )
    {
        _params = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#if !HAVE_ARC
-(void) dealloc
{
    [_editStyle release];
    [_editAction release];
    [_params release];    
    
    [_action release];
    [_config release];
    [_create release];
    [super dealloc];
}
#endif

@end