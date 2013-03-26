//
//  Player.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/28/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "Player.h"

@implementation Player

- (NSString *) role
{
    NSString *positionOfPlayer = [[self.data objectForKey:@"role"] objectForKey:@"value"];
    positionOfPlayer = [positionOfPlayer capitalizedString];
    return positionOfPlayer;
}

- (NSString *) club
{
    return [[self.data objectForKey:@"club"] objectForKey:@"title"];
}

- (NSString *) country
{
    return [[self.data objectForKey:@"country"] objectForKey:@"title"];
}

- (NSString *) bDate
{
    NSDictionary *dateInfo = [[self.allInformation objectForKey:@"data"] objectForKey:@"birthday"];
    if ([dateInfo count] == 0)
        return @"";
    NSTimeInterval time = [[dateInfo objectForKey:@"value"] doubleValue];
    NSString *_bDate = [AppHelper date:[NSDate dateWithTimeIntervalSince1970:time] withFormat:@"dd/MM/yyyyг."];
    return _bDate;
}

@end
