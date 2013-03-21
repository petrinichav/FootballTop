//
//  Comment.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/1/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (nonatomic, retain) NSString *authorName;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSString *body;
@property (nonatomic) NSTimeInterval timeCreated;

- (void) setCommentData:(NSDictionary *)data;

- (float) heightBodyText;

@end
