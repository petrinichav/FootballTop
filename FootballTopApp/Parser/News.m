//
//  News.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/25/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "News.h"

@implementation News

- (void) dealloc
{
    [_smallImageURL release];
    [_bigImageURL release];
    [_title release];
    [_htmlBody release];
    [_author release];
    [_htmlFullBody release];
    [super dealloc];
}

@end
