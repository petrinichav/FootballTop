//
//  NewsDetailsViewController.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/25/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "NewsDetailsViewController.h"
#import "News.h"
#import "NetworkTaskGenerator.h"
#import "CommentsViewController.h"
#import "DataSource.h"

@interface NewsDetailsViewController ()

@end

@implementation NewsDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) releaseOutlets
{
    [_contentWebView release];
    _contentWebView = nil;
    [_bgScrollView release];
    _bgScrollView = nil;
    [_commentsBtn release];
    _commentsBtn = nil;
    [_newsImage release];
    _newsImage = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) increaseComments:(NSNotification *) notif
{
    currentNews.comments ++;
    [self.commentsBtn setTitle:[NSString stringWithFormat:@" %d", currentNews.comments] forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Localization localizeView:self.bgScrollView];
    [Localization localizeView:self.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseComments:) name:@"IncreaseComments" object:nil];
	// Do any additional setup after loading the view.
}

- (void) viewDidUnload
{
    [self releaseOutlets];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [self releaseOutlets];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) dealloc
{
    [self releaseOutlets];
    [super dealloc];
}

- (IBAction) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    [vc showComments:(currentNews.comments != 0) forObjectWithID:currentNews.newsID];
    [vc release];
}

- (void) setNews:(News *) news
{
    LabelInViewWithID(self.view, ID_LBL_NAV_TITLE).text = news.title;
    LabelInViewWithID(self.bgScrollView, ID_LBL_TITLE).text = news.title;
    CGRect titleLblRect = LabelInViewWithID(self.bgScrollView, ID_LBL_TITLE).frame;
    [self.bgScrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, titleLblRect.origin.y+titleLblRect.size.height)];
    [self.bgScrollView setContentOffset:CGPointMake(0, 0)];
    
    LabelInViewWithID(self.bgScrollView, ID_LBL_DATE).text = [AppHelper date:[NSDate dateWithTimeIntervalSince1970:news.pubDate] withFormat:@"dd MMMM yyyy, HH:mm"];

    [self.contentWebView loadHTMLString:news.htmlFullBody baseURL:nil];
    self.contentWebView.scrollView.scrollEnabled = NO;
    
    [self.commentsBtn setTitle:[NSString stringWithFormat:@" %d", news.comments] forState:UIControlStateNormal];
    
    if ([news.bigImageURL length] > 0)
    {
        __block UIImage *img = nil;
        DispatchTask *task = [DispatchTask taskWithExecuteBlock:^(DispatchTask *newTask) {
            img =     [[DataSource source] cashedImageWithoutRequestForURL:[NSURL URLWithString:news.bigImageURL]];
        } andCompletitionBlock:^(DispatchTask *item)
                              {
                                  self.newsImage.image = img;
                              }];
        [[DispatchTools Instance] addTask:task];
    }
    else
    {
        CGRect webViewFrame = self.contentWebView.frame;
        CGRect imageFrame = self.newsImage.frame;
        webViewFrame.origin.y = imageFrame.origin.y-15;
        self.contentWebView.backgroundColor = [UIColor clearColor];
        self.contentWebView.frame = webViewFrame;
        self.newsImage.alpha = 0;
    }
    
    currentNews = news;

}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)_webView
{
    [_webView sizeToFit];
	
    [self.bgScrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, _webView.frame.origin.y+_webView.frame.size.height)];
    [self.bgScrollView setContentOffset:CGPointMake(0, 0)];
    
    _webView.alpha = 1;    
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
