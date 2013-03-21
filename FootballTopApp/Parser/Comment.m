//
//  Comment.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 11/1/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (void) dealloc
{
    [_authorName release];
    [_imageURL release];
    [_body release];
    [super dealloc];
}

- (void) setCommentData:(NSDictionary *)data
{
    self.authorName = [[data objectForKey:@"author"] objectForKey:@"name"];
    self.imageURL = [[data objectForKey:@"author"] objectForKey:@"picture"];
    NSString *string = [NSString stringWithCString:[[data objectForKey:@"body"] UTF8String] encoding:NSUTF8StringEncoding];
    self.body = string;
    dbgLog(@"html body = %@", string);
    self.timeCreated = [[data objectForKey:@"created"] doubleValue];
}

- (float) heightBodyText
{
    NSString *text = [self.body stringByReplacingOccurrencesOfString:@"<blockquote>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"</blockquote>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
    self.body = text;
    
    return [AppHelper getCellSizeForText:text font:[UIFont fontWithName:@"Helvetica" size:12] width:297.f];
}

@end
