//
//  FTPlotView.h
//  FootballTopApp
//
//  Created by worker on 12/27/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"


@interface FTPlotView : UIView <CPTScatterPlotDelegate, CPTScatterPlotDataSource, CPTPlotDataSource, CPTPlotSpaceDelegate>
{
    NSMutableArray *dataToPlot;
    
    CPTGraphHostingView *hostingView;
    CPTXYGraph *graph;
    NSMutableArray *xLabels;
    NSMutableArray *yLabels;
    NSString *chartTitle;
}
- (id) initWithView: (UIView*) parentView;

- (void) createPlotWithData: (NSDictionary*) data;
- (void) setPlotData: (NSDictionary*) data;
- (void) reloadWithData: (NSDictionary*) data;

@end
