//
//  Coach.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/28/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "Coach.h"

@implementation Coach

- (NSString *) place
{
    NSString *locationName = Loc(@"_Loc_Free_Agent");
    NSDictionary *info = [self.data objectForKey:@"related"];
    if ([info isKindOfClass:[NSDictionary class]])
        locationName = [info objectForKey:@"title"];
    
    return locationName;
}

- (NSString *) body
{
    NSString *text = @"";
    NSDictionary *info = [self.data objectForKey:@"body"];
    if ([info isKindOfClass:[NSDictionary class]])
        text = [info objectForKey:@"value"];
    
    return text;
}

@end
