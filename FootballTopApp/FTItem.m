//
//  FTItem.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/11/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "FTItem.h"

@implementation FTItem

@synthesize imageURL, title, url, value;
@synthesize data;
@synthesize comments, votes, nID;

- (void) dealloc
{
    [imageURL release];
    [title release];
    [url release];
    [data release];
    [value release];
    [_allInformation release];

    [super dealloc];
}

+ (int) FTObjectTypeFromString:(NSString *) titleType
{
    if ([titleType isEqualToString:Loc(@"_Loc_Item_Const_1")])
    {
        return ItemPlayer;
    }
    else if ([titleType isEqualToString:Loc(@"_Loc_Item_Const_2")])
    {
        return ItemClub;
    }
    else if ([titleType isEqualToString:Loc(@"_Loc_Item_Const_3")])
    {
        return ItemTeam;
    }
    else if ([titleType isEqualToString:Loc(@"_Loc_Item_Const_4")])
    {
        return ItemCoach;
    }
    else if ([titleType isEqualToString:Loc(@"_Loc_Item_Const_5")])
    {
        return ItemChempionship;
    }
    
    return 0;
}

+ (id) createItemWithType:(int)type info:(NSDictionary *)info
{
    FTItem *item = nil;
    switch (type) {
        case ItemPlayer:
            item = [[NSClassFromString(@"Player") alloc] initWithInfo:info];
            break;
        case ItemCoach:
            item = [[NSClassFromString(@"Coach") alloc] initWithInfo:info];
            break;
        case ItemClub:
            item = [[NSClassFromString(@"Club") alloc] initWithInfo:info];
            break;
        case ItemTeam:
            item = [[NSClassFromString(@"Team") alloc] initWithInfo:info];
            break;
        case ItemChempionship:
            item = [[NSClassFromString(@"Chempionship") alloc] initWithInfo:info];
            break;
            
        default:
            item = [[NSClassFromString(@"Chempionship") alloc] initWithInfo:info];
            break;
    }
    item.itemType = type;
    
    return [item autorelease];
}

- (id) initWithInfo:(NSDictionary *)info
{
    if ((self = [super init]))
    {
        self.comments = [[info objectForKey:@"comments"] intValue];
        self.data     = [info objectForKey:@"data"];
        self.imageURL = [info objectForKey:@"image"];
        self.title    = [info objectForKey:@"title"];
        self.url      = [info objectForKey:@"url"];
        self.votes    = [[info objectForKey:@"votes"] intValue];
        self.rating   = [[info objectForKey:@"rating"] intValue];
        self.nID      = [[info objectForKey:@"nid"] intValue];
    }
    
    return self;
}

- (void) setInfo:(NSDictionary *)info
{
    self.comments = [[info objectForKey:@"comments"] intValue];
    self.data     = [info objectForKey:@"data"];
    self.imageURL = [info objectForKey:@"image"];
    self.title    = [info objectForKey:@"title"];
    self.url      = [info objectForKey:@"url"];
    self.votes    = [[info objectForKey:@"votes"] intValue];
    self.rating   = [[info objectForKey:@"rating"] intValue];
    self.nID      = [[info objectForKey:@"nid"] intValue];
}



@end
