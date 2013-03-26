//
//  Club.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/28/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "Club.h"

@implementation Club

- (NSString *) championship
{
    return [[self.data objectForKey:@"championship"] objectForKey:@"title"];
}


@end
