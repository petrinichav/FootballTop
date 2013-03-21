//
//  AlertModule.h
//  T3Lockey
//
//  Created by worker on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomAlertView.h"
#import "StyleAlertView.h"

@interface AlertModule : NSObject <UIAlertViewDelegate, UITextFieldDelegate>
{
    NSMutableArray     *alerts;
    
    BOOL               isAlertShow;
    BOOL               isBackgroundMode;
}
@property (readonly) BOOL isBackgroundMode;
+ (AlertModule *) instance;

- (void) createAlertWithType:(int) type buttons:(int)count withCancelBlock:(AlertBlock)cancelBlock completeBlock:(AlertBlock)completeBlock;
- (void) createAlertWithMessage:(NSString *)message withCancelBlock:(AlertBlock)cancelBlock completeBlock:(AlertBlock)completeBlock;
- (void) createAlertWithStyle:(int)style withCancelBlock:(AlertBlock)cancelBlock completeBlock:(AlertBlock)completeBlock;
- (void) showAlert;

- (void)  setBackgroundMode:(BOOL) val;

@end
