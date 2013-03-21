//
//  DefaultViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 12/2/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum FTDefaultVCType
{
    FTDefaultVCTypeProfile   = 100,
    FTDefaultVCTypeSettings  = 101,
}FTDefaultVCType;

@interface DefaultViewController : UIViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forType:(FTDefaultVCType) type;

@property (nonatomic) FTDefaultVCType defaultType;

@end
