//
//  AlertModule.m
//  T3Lockey
//
//  Created by worker on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlertModule.h"

@implementation AlertModule

@synthesize isBackgroundMode;

static AlertModule *_module = nil;

+ (AlertModule *) instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _module = [[AlertModule alloc] init];
    });
    
    return _module;
}

- (void) dealloc
{
    [alerts release];
    [super dealloc];
}

- (id) init
{
    if ((self = [super init]))
    {
        alerts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)  setBackgroundMode:(BOOL) val
{
    isBackgroundMode = val;
}

- (void) addAlert:(UIAlertView *)alert
{
    BOOL isAdd = YES;
    for (CustomAlertView *curAlert in alerts)
    {
        if (curAlert.type == ((CustomAlertView *)alert).type)
        {
            isAdd = NO;
            break;
        }
    }
    if (isAdd)
        [alerts addObject:alert];
}

- (void) removeAlert:(UIAlertView *)alert
{
    [alerts removeObject:alert];
}

- (void) createAlertWithType:(int) type buttons:(int)count withCancelBlock:(AlertBlock)cancelBlock completeBlock:(AlertBlock)completeBlock
{
     if (!isBackgroundMode)
         {
               NSString *loc_title = [NSString stringWithFormat:@"_Loc_Alert_Title%d", type];
               NSString *loc_body = [NSString stringWithFormat:@"_Loc_Alert_Body%d", type];
               NSString *loc_cancel= [NSString stringWithFormat:@"_Loc_Alert_Cancel%d", type];
               NSString *loc_ok  = [NSString stringWithFormat:@"_Loc_Alert_Ok%d", type];
               
               CustomAlertView *alert = nil;
               if (count == 1)
                   {
                         alert = [[CustomAlertView alloc] initWithTitle:Loc(loc_title) message:Loc(loc_body) 
                                                                  delegate:self 
                                                             cancelButtonTitle:Loc(loc_ok) otherButtonTitles:nil];
                       }
               else 
                   {
                         alert = [[CustomAlertView alloc] initWithTitle:Loc(loc_title) message:Loc(loc_body) 
                                                                delegate:self 
                                                            cancelButtonTitle:Loc(loc_cancel) otherButtonTitles:Loc(loc_ok), nil];
                       }
               
               alert.cancelBlock = cancelBlock;
               alert.completeBlock = completeBlock;
               alert.type = type;
               [self addAlert:alert];
               [alert release];
             }
}

- (void) createAlertWithMessage:(NSString *)message withCancelBlock:(AlertBlock)cancelBlock completeBlock:(AlertBlock)completeBlock
{
    if (!isBackgroundMode)
    {
        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"" message:message 
                                                               delegate:self 
                                                      cancelButtonTitle:Loc(@"_Loc_Alert_Cancel0") otherButtonTitles:Loc(@"_Loc_Alert_Ok0"), nil];
        alert.cancelBlock = cancelBlock;
        alert.completeBlock = completeBlock;
        [self addAlert:alert];
        [alert release];
    }
}

- (void) createAlertWithStyle:(int)style withCancelBlock:(AlertBlock)cancelBlock completeBlock:(AlertBlock)completeBlock
{
    if (!isBackgroundMode)
    {
        @autoreleasepool {
            int fields = 0;
            if (style == EmailStyle)
                fields = 2;
            if (style == PasswordStyle)
                fields = 2;
            StyleAlertView *alert = [StyleAlertView alertViewWithStyle:style withFields:fields deleagte:self];
            [alert createTextFields];
            alert.cancelBlock = cancelBlock;
            alert.completeBlock = completeBlock;
            [self addAlert:alert];

        }
    }
}

- (void) showAlert
{
    if (!isAlertShow && [alerts count] > 0)
    {
        UIAlertView *alert = [alerts objectAtIndex:0];
        if (alert)
        {
            [alert show];
            isAlertShow = YES;
        }
    }
}

#pragma mark UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CustomAlertView *alert = (CustomAlertView *)alertView;
    if (buttonIndex == 0)
        alert.cancelBlock(alert);
    else if (buttonIndex == 1)
        alert.completeBlock(alert);
    
    [self removeAlert:alert];
    isAlertShow = NO;
    [self showAlert];
}

@end
