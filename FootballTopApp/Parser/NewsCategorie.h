//
//  NewsCategorie.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/22/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsCategorie : NSObject

@property (nonatomic, copy) NSString *titleCategorie;
@property (nonatomic) int IDCategorie;

- (id) initWithID:(int)ID title:(NSString *) title;

@end
