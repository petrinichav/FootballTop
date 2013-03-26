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
#import "CommentsView.h"
#import "CommentsView.h"
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
    self = [super initWithNibName:[Tools xibForRetina4_inch:@"ItemDetailViewController"] bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Localization localizeView:self.view];
    [Localization localizeView:scrollView];
    commentHeight = 0.f;
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContentSize:) name:@"UpdateContentSize" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRefreshManager:) name:@"UpdateRefreshManager" object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseComments:) name:@"IncreaseComments" object:nil];
}

- (void) releaseOutlets
{
    [description release];
    description = nil;
    [titleLbl release];
    titleLbl = nil;
    [imageItem release];
    imageItem = nil;
    [scrollView release];
    scrollView = nil;
    [_commentField release];
    _commentField = nil;
    [_commentsBtn release];
    _commentsBtn = nil;
    [_addToFavBtn release];
    _addToFavBtn = nil;
    [_addCommentField release];
    _addCommentField = nil;
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

- (void) keyboardWillShow:(NSNotification *)notif
{
    CGRect keyboardFrame = [[notif.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.width;
    
    UIViewAnimationCurve animationCurve = [[notif.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat duration = [[notif.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (duration == 0.f)
        duration = 0.25f;
    
    [UIView animateWithDuration:duration delay:0
                        options:(UIViewAnimationOptions)animationCurve
                     animations:^{
                         [self textEnterFieldFrameForKeyboardHeight:keyboardHeight];
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void) keyboardWillHide:(NSNotification *)notif
{
    UIViewAnimationCurve animationCurve = [[notif.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat duration = [[notif.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (duration == 0.f)
        duration = 0.25f;
    
    [UIView animateWithDuration:duration delay:0
                        options:(UIViewAnimationOptions)animationCurve
                     animations:^{
                         [self textEnterFieldFrameForKeyboardHeight:0];
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void) textEnterFieldFrameForKeyboardHeight:(CGFloat) height
{
    CGRect rect =  self.addCommentField.frame;
    rect.origin.y = [UIScreen mainScreen].bounds.size.height - height + rect.size.height;
    self.addCommentField.frame = rect;
}


- (void) updateContentSize:(NSNotification *) notif
{
   
}

- (void) increaseComments:(NSNotification *) notif
{
    self.ftObject.comments ++;
    [self.commentsBtn setTitle:[NSString stringWithFormat:@" %d", self.ftObject.comments] forState:UIControlStateNormal];
}

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
    if (LabelInViewWithID(scrollView, ID_LBL_TITLE_BDATE).alpha == 0)
    {
        CGRect countryLblRect = LabelInViewWithID(scrollView, ID_LBL_TITLE_COUNTRY).frame;
        CGRect countryNameRect = LabelInViewWithID(scrollView, ID_LBL_COUTRY).frame;
        CGRect bDatelblRect   = LabelInViewWithID(scrollView, ID_LBL_TITLE_BDATE).frame;
        countryLblRect.origin.y = bDatelblRect.origin.y;
        countryNameRect.origin.y = bDatelblRect.origin.y;
        if (offsetToRight == 0)
            countryNameRect.origin.x = countryLblRect.origin.x;
        else
            countryNameRect.origin.x -= offsetToRight;
        LabelInViewWithID(scrollView, ID_LBL_TITLE_COUNTRY).frame = countryLblRect;
        LabelInViewWithID(scrollView, ID_LBL_COUTRY).frame = countryNameRect;
    }
}

- (void) setInfoLabelForItem:(FTItem *)item
{
    LabelInViewWithID(scrollView, ID_LBL_TITLE_BDATE).alpha = 0;
    LabelInViewWithID(scrollView, ID_LBL_TITLE_COUNTRY).alpha = 0;

    switch (item.itemType) {
        case ItemCoach:
        {
            NSString *place = [((Coach *)item) place];
            LabelInViewWithID(scrollView, ID_LBL_COUTRY).text = place;
            if (![place isEqualToString:Loc(@"_Loc_Free_Agent")])
            {
                LabelInViewWithID(scrollView, ID_LBL_TITLE_COUNTRY).text = Loc(@"_Loc_ClubOrTeam");
                LabelInViewWithID(scrollView, ID_LBL_TITLE_COUNTRY).alpha = 1;
                double offset = [LabelInViewWithID(scrollView, ID_LBL_TITLE_COUNTRY).text  length]*(-2.f);
                [self moveContentToTopAndRigth:offset];
            }
            else
            {
                LabelInViewWithID(scrollView, ID_LBL_TITLE_COUNTRY).alpha = 0;
                double offset = 0;
                [self moveContentToTopAndRigth:offset];
                
            }
            self.infoTitleLbl.text = Loc(@"_Loc_AboutFTObject1");
            
            
        }
            break;
        case ItemClub:
        {
            LabelInViewWithID(scrollView, ID_LBL_COUTRY).text = [((Club *)item) championship];
            LabelInViewWithID(scrollView, ID_LBL_TITLE_COUNTRY).text = Loc(@"_Loc_Liga");
            LabelInViewWithID(scrollView, ID_LBL_TITLE_COUNTRY).alpha = 1;
            self.infoTitleLbl.text = Loc(@"_Loc_AboutFTObject2");
            [self moveContentToTopAndRigth:[LabelInViewWithID(scrollView, ID_LBL_TITLE_COUNTRY).text  length]*3.f];
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
                LabelInViewWithID(scrollView, ID_LBL_TITLE_BDATE).alpha = 1;
                LabelInViewWithID(scrollView, ID_LBL_DATE).text   = bDate;
            }
            else
            {
                LabelInViewWithID(scrollView, ID_LBL_TITLE_BDATE).alpha = 0;
                LabelInViewWithID(scrollView, ID_LBL_DATE).alpha = 0;
                [self moveContentToTopAndRigth:[LabelInViewWithID(scrollView, ID_LBL_TITLE_COUNTRY).text  length]*0.5f];
            }
            LabelInViewWithID(scrollView, ID_LBL_TITLE_COUNTRY).alpha = 1;
            LabelInViewWithID(scrollView, ID_LBL_COUTRY).text = [((Player *)item) country];
            
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
    infoRect.origin.y = scrollView.contentSize.height;
    self.infoTitleLbl.frame = infoRect;
    
    UIImageView *lineImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_tbl_header_line.png"]];
    lineImgView.frame = CGRectMake(0, infoRect.origin.y + infoRect.size.height, 320, 1);
    [scrollView addSubview:lineImgView];
    
    CGRect descriptionFrame = description.frame;
    descriptionFrame.origin.y = lineImgView.frame.origin.y+lineImgView.frame.size.height;
    description.frame = descriptionFrame;
    contentHeight = description.frame.origin.y;
    [description loadHTMLString:obj.value baseURL:nil];
    
    [lineImgView release];
    
    titleLbl.text = obj.title;
    LabelInViewWithID(scrollView, ID_LBL_CREATOR).text = obj.title;
    LabelInViewWithID(scrollView, ID_LBL_VOTES).text = [AppHelper stringValueForNumber:obj.votes];
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
                imageItem.image = image;
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
    CGRect rect = CGRectMake(10, imageItem.frame.origin.y + imageItem.frame.size.height + 30, 300, 250);
    FTPlotView *plot = [[[FTPlotView alloc] initWithFrame:rect] autorelease];

    [scrollView addSubview:plot];
    [scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGRectGetMaxY(plot.frame))];
    
//    NSDictionary *response = @{@"date":@"25 \u0434\u0435\u043a\u0430\u0431\u0440\u044f 2012 - 4 \u044f\u043d\u0432\u0430\u0440\u044f 2013",@"timeline":@[@"25",@"26",@"27"],@"coordinates":@{@"positions":@[@{@"value":@"1",@"class":@"mid"}],@"coords":@[@{@"x":@0,@"y":@77.5},@{@"x":@29,@"y":@77.5},@{@"x":@58,@"y":@77.5}]}};

  //  [LoadingView showInView:plot];
    
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
                                                                                     LabelInViewWithID(scrollView, ID_LBL_VOTES).text = [AppHelper stringValueForNumber:[[response objectAtIndex:0] intValue]];
                                                                                     LabelInViewWithID(scrollView, ID_LBL_ADD_VOTE).text = Loc(@"_Loc_Vote_Is_Successful");
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

- (IBAction) search:(id)sender
{
    AppDelegate *dlg = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [dlg showSearchControllerInNavController:self.navigationController];
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

- (IBAction) addComment:(id)sender
{
    [commentsView hide];
    [self.commentField becomeFirstResponder];
}

- (IBAction) postComment:(id)sender
{
   // [LoadingView showInView:self.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForAddCommentForNodeId:self.ftObject.nID comment:self.commentField.text completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            [self.commentField resignFirstResponder];
            [self addComments];
        }
      //  [LoadingView hide];
    }];
    
    [[DispatchTools Instance] addTask:task];
}


- (void) addComments
{
    
}


#pragma mark WebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    
    [aWebView sizeToFit];
    contentHeight += aWebView.frame.size.height;
	[scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, contentHeight)];
       
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

#pragma mark - CommetsViewDelegate

- (void) hideCommentsView
{
    self.commentsBtn.alpha   = 1;
}
@end
