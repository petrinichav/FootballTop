//
//  DefaultViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 12/2/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "DefaultViewController.h"

@interface DefaultViewController ()

@end

@implementation DefaultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forType:(FTDefaultVCType) type
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        if (type == FTDefaultVCTypeProfile)
        {
            self.tabBarItem.title = Loc(@"_Loc_Profile" );
            self.tabBarItem.image = [Tools hiresImageNamed:@"btn_prof.png"];
        }
        else if (type == FTDefaultVCTypeSettings)
        {
            self.tabBarItem.title = Loc(@"_Loc_Settings" );
            self.tabBarItem.image = [Tools hiresImageNamed:@"btn_settings.png"];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
