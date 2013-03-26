//
//  FTItem.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/11/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTItem : NSObject
{
    NSString      *imageURL;
    NSString      *title;
    NSDictionary  *data;
    NSString      *url;
    NSString      *value;
    
    int comments;
    int votes;
    int nID;
}

@property (copy) NSString      *imageURL;
@property (copy) NSString      *title;
@property (copy) NSDictionary  *data;
@property (copy) NSDictionary  *allInformation;
@property (copy) NSString      *url;
@property (copy) NSString      *value;

@property int comments;
@property int votes;
@property int nID;
@property int rating;
@property int itemType;

+ (id) createItemWithType:(int)type info:(NSDictionary *)info;
+ (int) FTObjectTypeFromString:(NSString *) titleType;

- (id) initWithInfo:(NSDictionary *)info;
- (void) setInfo:(NSDictionary *)info;

@end
