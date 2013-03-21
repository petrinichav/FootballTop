//
//  FTPlotView.m
//  FootballTopApp
//
//  Created by worker on 12/27/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "FTPlotView.h"

#define X_VAL @"X_VAL"
#define Y_VAL @"Y_VAL"

#define PADDING_LEFT 35
#define PADDING_RIGHT 20
#define PADDING_TOP 30
#define PADDING_BOTTOM 35


@implementation FTPlotView

- (id) initWithFrame: (CGRect) frame
{
    if (self = [super initWithFrame:frame]) {
        hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(PADDING_LEFT,
                                                                            PADDING_TOP,
                                                                            CGRectGetWidth(frame)-PADDING_LEFT-PADDING_RIGHT,
                                                                            CGRectGetHeight(frame)-PADDING_TOP-PADDING_BOTTOM)];
        [self addSubview:hostingView];
        hostingView.collapsesLayers = NO;
        
        graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
        hostingView.hostedGraph = graph;
        graph.backgroundColor = [CPTColor colorWithComponentRed:.92 green:.92 blue:.90 alpha:1].cgColor;
        
        graph.paddingLeft = -PADDING_LEFT;
        graph.paddingRight = 0;
        graph.paddingTop = -PADDING_TOP;
        graph.paddingBottom = -PADDING_BOTTOM;
        
        graph.plotAreaFrame.paddingLeft = PADDING_LEFT;
        graph.plotAreaFrame.paddingRight = 0;
        graph.plotAreaFrame.paddingBottom = PADDING_BOTTOM;
        graph.plotAreaFrame.paddingTop = PADDING_TOP;
        
        [self createAxes];
    }
    return self;
}

- (id) initWithView: (UIView*) parentView
{
    if (self = [self initWithFrame:parentView.frame]) {
        [parentView addSubview:self];
    }
    return self;
}

- (void) dealloc
{
    [hostingView removeFromSuperview];
    if (graph)
        [graph release];
    [hostingView release];
    [dataToPlot release];
    [super dealloc];
}

#pragma mark - Data

-(void) generateDataSamplesWithData:(NSArray*) data
{
    dataToPlot = [[NSMutableArray alloc]init];
    
    for (NSDictionary *coord in data) {
        double y = [[coord objectForKey:@"y"] doubleValue]*-1;
        [coord setValue:[NSNumber numberWithDouble:y] forKey:@"y"];
    }
    
    [dataToPlot addObjectsFromArray:data];
}

- (void) reciveData:(NSDictionary *)data
{
    chartTitle = [data objectForKey:@"date"];
    graph.title = chartTitle;
    
    NSArray *coord =  [[data objectForKey:@"coordinates"] objectForKey:@"coords"];
    xLabels = [NSMutableArray arrayWithArray:[data objectForKey:@"timeline"]];
    yLabels = [NSMutableArray array];

    for (NSDictionary *position in [[data objectForKey:@"coordinates"] objectForKey:@"positions"]) {
        NSObject *obj = [position objectForKey:@"value"];
        if (![obj isKindOfClass:[NSString class]]) {
            obj = [NSString stringWithFormat:@"%@",obj];
        }
        [yLabels addObject:obj];
    }
    
    [self generateDataSamplesWithData:coord];
}

- (void) reloadWithData: (NSDictionary*) data
{
    if (data == nil || [data isKindOfClass:[NSNull class]])
    {
        return;
    }
    
    [self reciveData:data];

    [self setAxesRange];
    [self createCustomLabels];
    
    if ([[hostingView.hostedGraph allPlots] count] == 0) {
        [self createScatterPlot];
    }
    [hostingView.hostedGraph reloadDataIfNeeded];
    
    [graph release];
    graph = nil;
}

- (void)setPlotData:(NSDictionary *)data
{
    [self reloadWithData:data];
}

- (void)createPlotWithData: (NSDictionary*) data
{
    if (data == nil || [data isKindOfClass:[NSNull class]])
    {
        return;
    }
    [self reciveData:data];
    [self createGraph];
}

- (void) createGraph
{
    [self setAxesRange];
    
    [self createScatterPlot];
    
    [self createAxes];
    [self createCustomLabels];

    [graph release];
    graph = nil;

}

#pragma mark - Visual style

- (void) createScatterPlot
{
    // Create Scatter plot
    CPTScatterPlot *linePlot = [[CPTScatterPlot alloc] initWithFrame:graph.frame];
    linePlot.identifier = @"Plot1";
    CPTMutableLineStyle *lineStyle = [[linePlot.dataLineStyle mutableCopy] autorelease];
    lineStyle.lineWidth = 2.0;
    lineStyle.lineColor = [CPTColor colorWithComponentRed:.23 green:.56 blue:.16 alpha:1];
    linePlot.dataLineStyle = lineStyle;
    linePlot.dataSource = self;
    linePlot.interpolation = CPTScatterPlotInterpolationLinear;
    [graph addPlot:linePlot];
    
    //Create dots
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:.23 green:.56 blue:.16 alpha:1]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(10.0, 10.0);
    linePlot.plotSymbol = plotSymbol;
    
    [linePlot release];

}

- (void) setAxesRange
{
    float xAxisStart = 0;
    float xAxisLength = 0;
    float xAxisVisibleRange = 0;
    
    float yAxisStart = 0;
    float yAxisLength = 0;
    
    if ([dataToPlot count] == 0) {
        xAxisStart = 0;
        xAxisLength = 1;
        xAxisVisibleRange = 1;
        
        yAxisStart = 0;
        yAxisLength = 1;
    }
    else
    {
        xAxisStart = -20;
        xAxisLength = [[dataToPlot valueForKeyPath:@"@max.x"] doubleValue]*1.2;
        xAxisVisibleRange = [[dataToPlot valueForKeyPath:@"@max.x"] doubleValue]*1.2;
        
        yAxisStart = [[dataToPlot valueForKeyPath:@"@min.y"] doubleValue]*1.3; // reverted Y axis

        if ([yLabels count] == 1) {
            yAxisLength = fabsf(yAxisStart)*0.5;
        }
        else
        {
            yAxisLength = fabsf(yAxisStart)*1.3;
        }
    }
    
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xAxisStart) length:CPTDecimalFromFloat(xAxisLength)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xAxisStart)
                                                    length:CPTDecimalFromFloat(xAxisVisibleRange)];
    
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(yAxisStart)
                                                    length:CPTDecimalFromDouble(yAxisLength)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    CPTXYAxis *y = axisSet.yAxis;
    
    x.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xAxisStart) length:CPTDecimalFromFloat(xAxisLength)];
    x.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xAxisStart) length:CPTDecimalFromFloat(xAxisLength)];
    y.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yAxisStart) length:CPTDecimalFromFloat(yAxisLength)];
    y.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xAxisStart) length:CPTDecimalFromFloat(yAxisLength)];
}

- (void) createAxes
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;

    // Create grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 1.f;
    majorGridLineStyle.lineColor = [CPTColor colorWithComponentRed:.8 green:.8 blue:.8 alpha:1.];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = .5f;
    minorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    
    //Label style
    CPTMutableTextStyle *labelStyle = [CPTMutableTextStyle textStyle];
    labelStyle.fontSize = 10;
    labelStyle.color = [CPTColor colorWithComponentRed:0.25 green:0.25 blue:0.25 alpha:1.0];
    
	// Create axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    {
		x.minorTicksPerInterval = 0;
		x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(-5);
        x.majorGridLineStyle = nil;
		x.minorGridLineStyle = nil;
		x.axisLineStyle = majorGridLineStyle;
		x.majorTickLineStyle = minorGridLineStyle;
		x.minorTickLineStyle = minorGridLineStyle;
		x.labelOffset = 0.0;
        
        x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];
		x.plotSpace = plotSpace;
        x.labelingPolicy = CPTAxisLabelingPolicyNone;
    
        x.labelTextStyle = labelStyle;
    }
    CPTXYAxis *y = axisSet.yAxis;
	{
        double temp = [[dataToPlot valueForKeyPath:@"@min.y"] doubleValue];

		y.majorIntervalLength = CPTDecimalFromInteger(temp);
		y.minorTicksPerInterval = 0;
		y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0);
		y.preferredNumberOfMajorTicks = 8;
        //		y.majorGridLineStyle = minorGridLineStyle;
        //		y.minorGridLineStyle = minorGridLineStyle;
		y.axisLineStyle = majorGridLineStyle;
		y.majorTickLineStyle = minorGridLineStyle;
		y.minorTickLineStyle = minorGridLineStyle;
		y.labelOffset = 0;
		y.labelRotation = 0;
        y.labelingPolicy = CPTAxisLabelingPolicyNone;
        
        y.labelTextStyle = labelStyle;
        y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];// fix Y axis
    
		y.plotSpace = plotSpace;
    }
    
    // Set axes
    graph.axisSet.axes = [NSArray arrayWithObjects:x, y, nil];
}

-(void) createCustomLabels
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    
    NSMutableArray *customtick = [NSMutableArray arrayWithCapacity:[xLabels count]];
    for (int i=0; i<[xLabels count]; i++) {
        [customtick addObject:[[dataToPlot objectAtIndex:i] objectForKey:@"x"]];
    }
    NSUInteger labelLocation = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xLabels count]];
    @try {
        for (NSNumber *tickLocation in customtick) {
            CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [xLabels objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
            newLabel.tickLocation = [tickLocation decimalValue];
            newLabel.offset = x.labelOffset + x.majorTickLength;
            newLabel.rotation = 0;
            [customLabels addObject:newLabel];
            [newLabel release];
        }
        x.axisLabels =  [NSSet setWithArray:customLabels];
        
        x.majorTickLocations = [NSSet setWithArray:customtick];
        x.majorTickLength = 4.;
        x.tickDirection = CPTSignNone;
    }
    @catch (NSException *exception) {
        NSLog(@"Error creating X labels: %@", exception);
    }
    
    x.axisLabels =  [NSSet setWithArray:customLabels];
    
    x.title = @"Дата";
    x.titleTextStyle = x.labelTextStyle;
    x.titleOffset = 18;
    
    CPTXYAxis *y = axisSet.yAxis;
    @try
    {
        customtick = [NSMutableArray arrayWithCapacity:[yLabels count]];
//        for (int i = 0; i < [xLabels count]; i++) {            
//            if (i == 0) {
//                [customtick addObject:[[dataToPlot objectAtIndex:i] objectForKey:@"y"]];
//            }
//            else if (i != ([xLabels count]-1))
//            {
//                CGFloat first = [[[dataToPlot objectAtIndex:i] objectForKey:@"y"] floatValue];
//                CGFloat second = [[[dataToPlot objectAtIndex:i-1] valueForKey:@"y"] floatValue];
//                if (first != second && [customtick count] < [yLabels count]) {
//                        [customtick addObject:[[dataToPlot objectAtIndex:i] objectForKey:@"y"]];
//                    }
//                    else if ([customtick count] >= [yLabels count])
//                        break;
//            }
//            else
//            {
//                [customtick addObject:[[dataToPlot lastObject] objectForKey:@"y"]];
//            }
//        }
        
        NSMutableArray *temp = [[NSMutableArray alloc]init];
        //find unique Y coords
        for (int i=0; i < [xLabels count]; i++) {
            if (i == 0) {
                [temp addObject:[[dataToPlot objectAtIndex:i] objectForKey:@"y"]];
            }
            else
            {
                CGFloat first = [[[dataToPlot objectAtIndex:i] objectForKey:@"y"] floatValue];
                CGFloat second = [[[dataToPlot objectAtIndex:i-1] valueForKey:@"y"] floatValue];
                if (first != second && fabs(second-first)>10) //if dots is placed too close fabs(second-first)>5 - skip
                {
                    [temp addObject:[[dataToPlot objectAtIndex:i] objectForKey:@"y"]];
                }
            }
        }

        //enumerate through unique Y coords and place Y-labels
        int num = 0;
        if ([yLabels count] > 2 && [temp count] > 2) {
            num = ([temp count]-2)/([yLabels count]-2);
        }
        
        //removing unused labels
        if ([yLabels count] > [temp count]) {
            NSMutableIndexSet *idx = [NSMutableIndexSet indexSet];
            for (int j = [temp count]; j < [yLabels count]; j++) {
                [idx addIndex:j];
            }
            [yLabels removeObjectsAtIndexes:idx];
        }
        
        for (int i=0; i < [yLabels count]; i++) {
            if (i==0) {
                [customtick addObject:[temp objectAtIndex:i]];
            }
            else if (i == ([yLabels count]-1))
            {
                if ([yLabels count] == 2) //if total 2 labels then second poind will be different from first
                {
                    [customtick addObject:[temp objectAtIndex:i]];
                }
                else
                {
                    [customtick addObject:[temp lastObject]];
                }
            }
            else
            {
                if (num > 1) {
                    [customtick addObject:[temp objectAtIndex:i*num-1]];
                }
                else
                {
                    [customtick addObject:[temp objectAtIndex:i]];
                }
            }
        }
        
        //sort backwards
        [customtick sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 floatValue] > [obj2 floatValue]) {
                return (NSComparisonResult) NSOrderedDescending;
            }
            else if ([obj1 floatValue] > [obj2 floatValue]) {
                return (NSComparisonResult) NSOrderedAscending;
            }
            return (NSComparisonResult) NSOrderedSame;
        }];
        
        labelLocation = 0;
        yLabels = [NSMutableArray arrayWithArray:[[yLabels reverseObjectEnumerator] allObjects]];
        
        customLabels = [NSMutableArray arrayWithCapacity:[yLabels count]];
        for (NSNumber *tickLocation in customtick) {
            CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[yLabels objectAtIndex:labelLocation++]  textStyle:y.labelTextStyle];
            newLabel.tickLocation = [tickLocation decimalValue];
            newLabel.offset = y.labelOffset + y.majorTickLength;
            newLabel.rotation = 0;
            [customLabels addObject:newLabel];
            [newLabel release];
        }
        y.axisLabels = [NSSet setWithArray:customLabels];
    
        y.majorTickLocations = [NSSet setWithArray:customtick];
        y.majorTickLength = 4.;
        y.tickDirection = CPTSignNone;
    }
    @catch (NSException *exception) {
        NSLog(@"Error creating Y labels: %@",exception);
    }
    

    y.title = @"Место";
    y.titleTextStyle = y.labelTextStyle;
    y.titleOffset = 0;
    y.titleRotation = 0;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    y.titleLocation = plotSpace.yRange.end;

}

#pragma mark - Plot delegate

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot;
{
	return [dataToPlot count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum
			   recordIndex:(NSUInteger)index;
{
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num = [[dataToPlot objectAtIndex:index] valueForKey:key];
    
    return num;
}


-(CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)displacement {
    return CGPointMake(displacement.x,0);
}

- (BOOL) plotSpace:(CPTPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint
{
    return NO;
}

@end
