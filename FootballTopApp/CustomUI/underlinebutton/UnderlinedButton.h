//
//  text.h
//  Eneco Inzicht
//
//  Created by worker on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnderlinedButton : UIButton
{
    CGSize sizeOfLine;
}

- (void) setSizeOfLine:(CGSize)size;

@end
