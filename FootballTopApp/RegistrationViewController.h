//
//  RegistrationViewController.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/11/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistrationViewController : UIViewController
{
    int countryID;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIButton     *countryButton;

- (IBAction) registration:(id)sender;
- (IBAction) showCountryList:(id)sender;
- (IBAction) back:(id)sender;

@end
