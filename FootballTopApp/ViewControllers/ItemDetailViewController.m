//
//  ItemDetailViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/28/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "ItemDetailViewController.h"

#import "FTItem.h"
#import "FTUser.h"
#import "Coach.h"
#import "Player.h"
#import "Team.h"
#import "Chempionship.h"
#import "Club.h"

#import "NetworkTaskGenerator.h"
#import "DataSource.h"
#import "AppDelegate.h"

#import "AlertModule.h"
#import "CommentsViewController.h"

#import "FTPlotView.h"

@interface ItemDetailViewController ()

@property (nonatomic, retain) FTItem *ftObject;

@end

@implementation ItemDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Localization localizeView:self.view];
    [Localization localizeView:self.scrollView];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseComments:) name:@"IncreaseComments" object:nil];
}

- (void) releaseOutlets
{
    [_description release];
    _description = nil;
    [_titleLbl release];
    _titleLbl = nil;
    [_imageItem release];
    _imageItem = nil;
    [_scrollView release];
    _scrollView = nil;
    [_commentsBtn release];
    _commentsBtn = nil;
    [_addToFavBtn release];
    _addToFavBtn = nil;
    [_infoTitleLbl release];
    _infoTitleLbl = nil;
}

- (void) dealloc
{
    [self releaseOutlets];
    [_ftObject release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [self releaseOutlets];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notifications

- (void) increaseComments:(NSNotification *) notif
{
    self.ftObject.comments ++;
    [self.commentsBtn setTitle:[NSString stringWithFormat:@" %d", self.ftObject.comments] forState:UIControlStateNormal];
}

#pragma mark - Controller Logic

- (void) getVotesForObject:(FTItem *)obj
{
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForGetVotesForObject:obj completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSDictionary *response = [(NetworkTaskGenerator *)item objectFromString];
            dbgLog(@"%@", response);
        };
    }];
    [[DispatchTools Instance] addTask:task];

}

- (void) moveContentToTopAndRigth:(float) offsetToRight
{
    if (LabelInViewWithID(self.scrollView, ID_LBL_TITLE_BDATE).alpha == 0)
    {
        CGRect countryLblRect = LabelInViewWithID(self.scrollView, ID_LBL_TITLE_COUNTRY).frame;
        CGRect countryNameRect = LabelInViewWithID(self.scrollView, ID_LBL_COUTRY).frame;
        CGRect bDatelblRect   = LabelInViewWithID(self.scrollView, ID_LBL_TITLE_BDATE).frame;
        countryLblRect.origin.y = bDatelblRect.origin.y;
        countryNameRect.origin.y = bDatelblRect.origin.y;
        if (offsetToRight == 0)
            countryNameRect.origin.x = countryLblRect.origin.x;
        else
            countryNameRect.origin.x -= offsetToRight;
        LabelInViewWithID(self.scrollView, ID_LBL_TITLE_COUNTRY).frame = countryLblRect;
        LabelInViewWithID(self.scrollView, ID_LBL_COUTRY).frame = countryNameRect;
    }
}

- (void) setInfoLabelForItem:(FTItem *)item
{
    LabelInViewWithID(self.scrollView, ID_LBL_TITLE_BDATE).alpha = 0;
    LabelInViewWithID(self.scrollView, ID_LBL_TITLE_COUNTRY).alpha = 0;

    switch (item.itemType) {
        case ItemCoach:
        {
            NSString *place = [((Coach *)item) place];
            LabelInViewWithID(self.scrollView, ID_LBL_COUTRY).text = place;
            if (![place isEqualToString:Loc(@"_Loc_Free_Agent")])
            {
                LabelInViewWithID(self.scrollView, ID_LBL_TITLE_COUNTRY).text = Loc(@"_Loc_ClubOrTeam");
                LabelInViewWithID(self.scrollView, ID_LBL_TITLE_COUNTRY).alpha = 1;
                double offset = [LabelInViewWithID(self.scrollView, ID_LBL_TITLE_COUNTRY).text  length]*(-2.f);
                [self moveContentToTopAndRigth:offset];
            }
            else
            {
                LabelInViewWithID(self.scrollView, ID_LBL_TITLE_COUNTRY).alpha = 0;
                double offset = 0;
                [self moveContentToTopAndRigth:offset];
                
            }
            self.infoTitleLbl.text = Loc(@"_Loc_AboutFTObject1");
            
            
        }
            break;
        case ItemClub:
        {
            LabelInViewWithID(self.scrollView, ID_LBL_COUTRY).text = [((Club *)item) championship];
            LabelInViewWithID(self.scrollView, ID_LBL_TITLE_COUNTRY).text = Loc(@"_Loc_Liga");
            LabelInViewWithID(self.scrollView, ID_LBL_TITLE_COUNTRY).alpha = 1;
            self.infoTitleLbl.text = Loc(@"_Loc_AboutFTObject2");
            [self moveContentToTopAndRigth:[LabelInViewWithID(self.scrollView, ID_LBL_TITLE_COUNTRY).text  length]*3.f];
        }
            break;
        case ItemChempionship:
        {
            self.infoTitleLbl.text = Loc(@"_Loc_AboutFTObject2");
        }
            break;
        case ItemPlayer:
        {
            NSString *bDate = [((Player *)item) bDate];
            if ([bDate length] > 0)
            {
                LabelInViewWithID(self.scrollView, ID_LBL_TITLE_BDATE).alpha = 1;
                LabelInViewWithID(self.scrollView, ID_LBL_DATE).text   = bDate;
            }
            else
            {
                LabelInViewWithID(self.scrollView, ID_LBL_TITLE_BDATE).alpha = 0;
                LabelInViewWithID(self.scrollView, ID_LBL_DATE).alpha = 0;
                [self moveContentToTopAndRigth:[LabelInViewWithID(self.scrollView, ID_LBL_TITLE_COUNTRY).text  length]*0.5f];
            }
            LabelInViewWithID(self.scrollView, ID_LBL_TITLE_COUNTRY).alpha = 1;
            LabelInViewWithID(self.scrollView, ID_LBL_COUTRY).text = [((Player *)item) country];
            
            self.infoTitleLbl.text = Loc(@"_Loc_AboutFTObject1");
        }
            break;
        case ItemTeam:
        {
            self.infoTitleLbl.text = Loc(@"_Loc_AboutFTObject2");
        }
            break;
            
        default:
            break;
    }
}

- (void) setItem:(FTItem *)obj
{
    self.ftObject = obj;
    
    [self.commentsBtn setTitle:[NSString stringWithFormat:@" %d", obj.comments] forState:UIControlStateNormal];
    
    if (obj.itemType == ItemChempionship)
        self.addToFavBtn.alpha = 0;
    
    [self createPlot];
    
    CGRect infoRect = self.infoTitleLbl.frame;
    infoRect.origin.y = self.scrollView.contentSize.height;
    self.infoTitleLbl.frame = infoRect;
    
    UIImageView *lineImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_tbl_header_line.png"]];
    lineImgView.frame = CGRectMake(0, infoRect.origin.y + infoRect.size.height, 320, 1);
    [self.scrollView addSubview:lineImgView];
    
    CGRect descriptionFrame = self.description.frame;
    descriptionFrame.origin.y = lineImgView.frame.origin.y+lineImgView.frame.size.height;
    self.description.frame = descriptionFrame;
    contentHeight = self.description.frame.origin.y;
    [self.description loadHTMLString:obj.value baseURL:nil];
    
    [lineImgView release];
    
    self.titleLbl.text = obj.title;
    LabelInViewWithID(self.scrollView, ID_LBL_CREATOR).text = obj.title;
    LabelInViewWithID(self.scrollView, ID_LBL_VOTES).text = [AppHelper stringValueForNumber:obj.votes];
    [self setInfoLabelForItem:obj];
    
    [self getVotesForObject:obj];
    
    if ([APPDelegate.user contentInFavouriteObjectWithID:obj.nID])
    {
        self.addToFavBtn.selected = YES;
    }

    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            __block UIImage *image =  [[DataSource source] cashedImageWithoutRequestForURL:[NSURL URLWithString:obj.imageURL]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageItem.image = image;
            });
            
        });

    }
    @catch (NSException *exception) {
        dbgLog(@"exeption = %@", exception);
    }
  
}

- (void) addToFavouriteItem
{
    [[AlertModule instance] createAlertWithMessage:@"Добавить в избранное?"
                                   withCancelBlock:^(UIAlertView *_alert) {
                                       
                                   } completeBlock:^(UIAlertView *_alert) {
                                       [LoadingView showInView:self.tabBarController.view];
                                       NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForAddFavouriteObjectWithID:self.ftObject.nID completeBlock:^(DispatchTask *item) {
                                           if (((NetworkTaskGenerator *)item).isSuccessful)
                                           {
                                               [APPDelegate getUserWithBlock:^{
                                                   [LoadingView hide];
                                               }];
                                               self.addToFavBtn.selected = YES;
                                           }
                                           else
                                           {
                                               [LoadingView hide];
                                           }
                                       }];
                                       [[DispatchTools Instance] addTask:task];

                                   }];
    [[AlertModule instance] showAlert];
  
}

- (void) removeFromFavouriteItem
{
    [[AlertModule instance] createAlertWithMessage:@"Удалить из избранного?"
                                   withCancelBlock:^(UIAlertView *_alert) {
                                       
                                   } completeBlock:^(UIAlertView *_alert) {
                                       [LoadingView showInView:self.tabBarController.view];
                                       NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForDeleteFavouriteObjectWithID:self.ftObject.nID completeBlock:^(DispatchTask *item) {
                                           if (((NetworkTaskGenerator *)item).isSuccessful)
                                           {
                                               [APPDelegate getUserWithBlock:^{
                                                   [LoadingView hide];
                                               }];
                                               self.addToFavBtn.selected = NO;
                                           }
                                           else
                                           {
                                               [LoadingView hide];
                                           }
                                       }];
                                       [[DispatchTools Instance] addTask:task];
                                   }];
    [[AlertModule instance] showAlert];  
}

- (void) createPlot
{
    CGRect rect = CGRectMake(10, self.imageItem.frame.origin.y + self.imageItem.frame.size.height + 30, 300, 250);
    FTPlotView *plot = [[[FTPlotView alloc] initWithFrame:rect] autorelease];

    [self.scrollView addSubview:plot];
    [self.scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGRectGetMaxY(plot.frame))];
    
    DispatchTask *plotTask = [NetworkTaskGenerator generateTaskForGetPlotDataForObject:self.ftObject.nID completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSDictionary *response = [(NetworkTaskGenerator *)item objectFromString];
            [plot reloadWithData:response];
            //[LoadingView hide];
        }
    }];
    [[DispatchTools Instance]addTask:plotTask];
   
}

#pragma mark - Buttons actions

- (IBAction) addToFav:(id)sender
{
    if ([APPDelegate createdUser])
    {
        if (((UIButton *)sender).selected)
        {
            [self removeFromFavouriteItem];
        }
        else
        {
            [self addToFavouriteItem];
        }
    }
    else
    {
        [[AlertModule instance] createAlertWithType:LoginRequest  buttons:2
                                    withCancelBlock:^(UIAlertView *_alert) {
                                        
                                    } completeBlock:^(UIAlertView *_alert) {
                                        [APPDelegate popToLoginScreen];
                                    }];
        [[AlertModule instance] showAlert];
    }
}

- (IBAction) back:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) addVote:(id)sender
{
    if (![APPDelegate createdUser])
    {
        [[AlertModule instance] createAlertWithType:LoginRequest  buttons:2
                                    withCancelBlock:^(UIAlertView *_alert) {
                                        
                                    } completeBlock:^(UIAlertView *_alert) {
                                        [APPDelegate popToLoginScreen];
                                    }];
        [[AlertModule instance] showAlert];
    }
    else
    {
        [LoadingView showInView:self.tabBarController.view];
        NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForAddVoteForNodeId:self.ftObject.nID
                                                                             completeBlock:^(DispatchTask *item) {
                                                                                 if (((NetworkTaskGenerator *)item).isSuccessful)
                                                                                 {
                                                                                     NSArray *response = [(NetworkTaskGenerator *)item objectFromString];
                                                                                     dbgLog(@"votes = %@", response);
                                                                                     LabelInViewWithID(self.scrollView, ID_LBL_VOTES).text = [AppHelper stringValueForNumber:[[response objectAtIndex:0] intValue]];
                                                                                     LabelInViewWithID(self.scrollView, ID_LBL_ADD_VOTE).text = Loc(@"_Loc_Vote_Is_Successful");
                                                                                     ((UIButton *)sender).alpha = 0;
                                                                                     self.ftObject.votes = [[response objectAtIndex:0] intValue];
                                                                                 }
                                                                                 else
                                                                                 {
                                                                                     [[AlertModule instance] createAlertWithType:VoteError buttons:1 withCancelBlock:^(UIAlertView *_alert) {
                                                                                         
                                                                                     } completeBlock:^(UIAlertView *_alert) {
                                                                                         
                                                                                     }];
                                                                                     [[AlertModule instance] showAlert];
                                                                                 }
                                                                                 [LoadingView hide];
                                                                             }];
        [[DispatchTools Instance] addTask:task];

    }
}

- (IBAction) openComments:(id)sender
{
    CommentsViewController *vc = [[CommentsViewController alloc] initWithNibName:@"CommentsViewController" bundle:[NSBundle mainBundle]];
    @try {
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    @catch (NSException *exception) {
        dbgLog(@"%@", exception);
    }
    [vc showComments:(self.ftObject.comments != 0) forObjectWithID:self.ftObject.nID];
    [vc release];

}

#pragma mark WebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    
    [aWebView sizeToFit];
    contentHeight += aWebView.frame.size.height;
	[self.scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, contentHeight)];
       
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    dbgLog(@"request = %@", [request URL]);
    if ([[[request URL] absoluteString] isEqualToString:@"about:blank"])
        return YES;
    else
    {
        [[UIApplication sharedApplication]openURL:[request URL]];
        return NO;
    }
}

@end
