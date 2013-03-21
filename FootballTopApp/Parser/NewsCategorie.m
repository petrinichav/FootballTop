//
//  NewsCategorie.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/22/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "NewsCategorie.h"

@implementation NewsCategorie

- (void) dealloc
{
    [super dealloc];
    [_titleCategorie release];
}

- (id) initWithID:(int)ID title:(NSString *) title
{
    if ((self = [super init]))
    {
        self.titleCategorie = title;
        self.IDCategorie = ID;
    }
    
    return self;
}

@end
