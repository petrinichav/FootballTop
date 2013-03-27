//
//  ProfileViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/5/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "ProfileViewController.h"
#import "NetworkTaskGenerator.h"
#import "DataSource.h"
#import "FTUser.h"
#import "FTItem.h"
#import "ProfileFavouriteCell.h"
#import "AppDelegate.h"
#import "ItemDetailViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = Loc(@"_Loc_Profile" );
        [self.tabBarItem setFinishedSelectedImage:[Tools hiresImageNamed:@"btn_prof_s.png"] withFinishedUnselectedImage:[Tools hiresImageNamed:@"btn_prof.png"]];        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Localization localizeView:self.view];
    [Localization localizeView:self.bgScrollView];       
   
    // Do any additional setup after loading the view from its nib.
}

- (void) updateProfile
{   
    self.aboutLbl.text = APPDelegate.user.about;
    float height = [AppHelper getCellSizeForText:APPDelegate.user.about font:self.aboutLbl.font width:295.f];
    CGRect aboutrect = self.aboutLbl.frame;
    aboutrect.size.height = height;
    self.aboutLbl.frame = aboutrect;
    
    self.favTitleLbl.frame = CGRectMake(self.favTitleLbl.frame.origin.x,
                                        aboutrect.origin.y + aboutrect.size.height+10,
                                        self.favTitleLbl.frame.size.width,
                                        self.favTitleLbl.frame.size.height);   
    
    LabelInViewWithID(self.bgScrollView, ID_LBL_CREATOR).text = APPDelegate.user.name;
    LabelInViewWithID(self.bgScrollView, ID_LBL_DATE).text = APPDelegate.user.bDate;
    LabelInViewWithID(self.bgScrollView, ID_LBL_COUTRY).text= APPDelegate.user.country;
    LabelInViewWithID(self.bgScrollView, ID_LBL_VOTES).text = [NSString stringWithFormat:@"%d", APPDelegate.user.rating];
    __block UIImage *image = nil;
    ImageViewInViewWithID(self.bgScrollView, ID_IMG_PROFILE).image = [Tools hiresImageNamed:@"default_image.png"];
    DispatchTask *task = [DispatchTask taskWithExecuteBlock:^(DispatchTask *newTask) {
        image =     [[DataSource source] cashedImageWithoutRequestForURL:[NSURL URLWithString:APPDelegate.user.avatar]];
    } andCompletitionBlock:^(DispatchTask *item)
                          {
                              ImageViewInViewWithID(self.bgScrollView, ID_IMG_PROFILE).image = image;
                          }];
    [[DispatchTools Instance] addTask:task];
    
    [self.itemsTable reloadData];
    
    CGRect tableRect = CGRectMake(self.itemsTable.frame.origin.x,
                                  self.favTitleLbl.frame.origin.y + self.favTitleLbl.frame.size.height,
                                  self.itemsTable.frame.size.width,
                                  heightOfTable);;
    self.noFavLabel.frame = CGRectMake(self.noFavLabel.frame.origin.x,
                                       tableRect.origin.y,
                                       self.noFavLabel.frame.size.width,
                                       self.noFavLabel.frame.size.height);
    CGRect lineImageRect = ImageViewInViewWithID(self.bgScrollView, ID_IMG_LINE).frame;
    lineImageRect.origin.y = tableRect.origin.y-1;
    ImageViewInViewWithID(self.bgScrollView, ID_IMG_LINE).frame = lineImageRect;
    
    self.itemsTable.frame = tableRect;
    
    float scrollHeight = 0;
    if (tableRect.size.height == 0)
        scrollHeight = self.noFavLabel.frame.size.height + self.noFavLabel.frame.origin.y;
    else
        scrollHeight = self.itemsTable.frame.origin.y + self.itemsTable.frame.size.height;
    
    [self.bgScrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, scrollHeight)];
    [self.bgScrollView setContentOffset:CGPointMake(0, 0)  animated:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateProfile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteRow:) name:@"DeleteRow" object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) releaseOutlets
{
    [_bgScrollView release];
    _bgScrollView = nil;
    [_itemsTable release];
    _itemsTable = nil;
    [_aboutLbl release];
    _aboutLbl = nil;
    [_favTitleLbl release];
    _favTitleLbl = nil;
    [_noFavLabel release];
    _noFavLabel = nil;
}

- (void)viewDidUnload
{
    [self releaseOutlets];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) didReceiveMemoryWarning
{
    [self releaseOutlets];
    [super didReceiveMemoryWarning];
}

- (void) dealloc
{
    [self releaseOutlets];
    [super dealloc];
}

- (void) deleteFavouriteObjectWithIndex:(int)index withCompleteBlock:(dispatch_block_t) block
{
    FTItem *obj = [APPDelegate.user.favouritesItems objectAtIndex:index];
    [LoadingView showInView:self.tabBarController.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForDeleteFavouriteObjectWithID:obj.nID completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            block();
        }
        [LoadingView hide];
    }];
    [[DispatchTools Instance] addTask:task];
}

- (void) deleteRow:(NSNotification *)notif
{
    ProfileFavouriteCell *cell = [notif object];
    NSIndexPath *idxPath = [self.itemsTable indexPathForCell:cell];
   [self deleteFavouriteObjectWithIndex:idxPath.row withCompleteBlock:^{
       [APPDelegate.user.favouritesItems removeObjectAtIndex:idxPath.row];
       [self.itemsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:idxPath] withRowAnimation:UITableViewRowAnimationFade];
       
       CGFloat heightCell = cell.frame.size.height;
       
       float heightTable = heightCell*[APPDelegate.user.favouritesItems count];
       if (heightTable == 0)
       {
           heightTable = self.noFavLabel.frame.size.height + self.noFavLabel.frame.origin.y;
       }
       else
       {
           heightTable = self.itemsTable.frame.origin.y + heightCell*[APPDelegate.user.favouritesItems count];
       }
       [self.bgScrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width,  heightTable)];
   }];
}

#pragma mark - Buttons

- (IBAction) search:(id)sender
{
    [APPDelegate showSearchControllerInNavController:self.navigationController];
}


#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    heightOfTable = 80.f + 80.f*([APPDelegate.user.favouritesItems count]-1);
    if ([APPDelegate.user.favouritesItems count] == 0)
    {
        heightOfTable = 0;
        tableView.alpha = 0;
        self.noFavLabel.alpha = 1;
    }
    else
    {
        tableView.alpha = 1;
        self.noFavLabel.alpha = 0;
    }
    return [APPDelegate.user.favouritesItems count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileFavouriteCell *cell = (ProfileFavouriteCell *)[tableView dequeueReusableCellWithIdentifier:@"FavCell"];
    if (cell == nil)
    {
        cell = [ProfileFavouriteCell loadCell];
    }
    [cell setValuesForItem:[APPDelegate.user.favouritesItems objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FTItem *obj = [APPDelegate.user.favouritesItems objectAtIndex:indexPath.row];
    [LoadingView showInView:self.tabBarController.view];
    NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForGetItemWithID:obj.nID completeBlock:^(DispatchTask *item) {
        if (((NetworkTaskGenerator *)item).isSuccessful)
        {
            NSDictionary *response = [(NetworkTaskGenerator *)item objectFromString];
            dbgLog(@"%@", response);
            obj.allInformation = response;
            obj.value = [[[response objectForKey:@"data"] objectForKey:@"body"] objectForKey:@"value"];
            [obj setInfo:response];
            
            ItemDetailViewController *vc = [[ItemDetailViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            [vc setItem:obj];
            [vc release];
        }
        [LoadingView hide];
    }];
    [[DispatchTools Instance] addTask:task];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void) tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
