//
//  RollingNumbers.m
//  Speedometer
//
//  Created by Evgen Bodunov on 7/6/09.
//  Copyright 2009 Evgen Bodunov <evgen.bodunov@gmail.com>. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DigitalNumbers.h"

@implementation DigitalNumbers

@synthesize digitsCount;
@synthesize multiplyer;
@synthesize digitsSpacing;

- (id)initWithCoder:(NSCoder *)decoder 
{
	if ( (self=[super initWithCoder:decoder]) ) 
    {
        autoScroll = YES;
		imgArray = [[NSMutableArray alloc] init];
        imageViewCache = [[NSMutableArray alloc] init];
        staticImages = [[NSMutableArray alloc] init];
        multiplyer = 1;
		self.clipsToBounds = YES;
	}
	return self;
}

- (void)dealloc 
{
	[imgArray release];
    [imageViewCache release];
    [staticImages release];
    [curRow release];
    [super dealloc];
}

- (NSMutableArray *) rowForValue:(double) val
{
	NSMutableArray *row = [[NSMutableArray alloc] init];
    int tmpValue = val*multiplyer;
    int digitsScroll = 0;
    
    
    int valDigitsCount = floor(log(val*multiplyer)/log(10))+1;
    if(valDigitsCount>digitsCount)
    {
        digitsScroll = valDigitsCount-digitsCount;
        tmpValue = round(val*multiplyer/pow(10, digitsScroll));
    }
    
    int curDigit;
    double totalWidth = 0;
	for (int i = 0; i<digitsCount+[staticImages count]; i++) 
    {
		UIImageView *imgView = nil;
        
        if([imageViewCache count]!=0)
        {
            imgView = [[imageViewCache lastObject] retain];
            [imageViewCache removeLastObject];
        }else
        {
            imgView = [[UIImageView alloc] init];
        }

        bool isStaticImage = NO;
        for(NSArray *staticImgaeData in staticImages)
        {
            int pos = [[staticImgaeData objectAtIndex:0] intValue]-digitsScroll;
            if(pos==i)
            {
                isStaticImage = YES;
                imgView.image = [staticImgaeData objectAtIndex:1];
                break;
            }
        }
        
        if(!isStaticImage)
        {
			curDigit = tmpValue%10;
			tmpValue /= 10;
			imgView.image = [imgArray objectAtIndex:curDigit];
		}
        
        totalWidth += imgView.image.size.width+digitsSpacing;
        [row addObject:imgView];
        [imgView release];
    }

    double x = floor((self.bounds.size.width+totalWidth)/2);
    for (UIImageView *imgView in row)
    {
        CGSize imgSize = imgView.image.size;
        x -= imgSize.width;
        imgView.frame = CGRectMake(x, 0, imgSize.width, imgSize.height);
        x -= digitsSpacing;
    }
	return [row autorelease];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	NSMutableArray *row = (NSMutableArray *) context;
	for(UIView* view in row)
	{
		[view removeFromSuperview];
	}
	[row release];
}

- (void) setCurRow:(NSMutableArray *)nextRow animated:(BOOL) animated
{
    if(nextRow==curRow) return;
    if(animated)
    {
        if([[self.layer animationKeys] count]==0)
        {
            CATransition *transition = [CATransition animation];
            transition.duration = 0.1;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            transition.type = kCATransitionFade;
            [self.layer addAnimation:transition forKey:nil];	 
        }
    }else
    {
        [self.layer removeAllAnimations];
    }
    
    for (UIImageView *view in curRow)
    {
        [imageViewCache addObject:view];
        [view removeFromSuperview];
    }
    [curRow release];
    curRow = [nextRow retain];
    
    for (UIImageView *view in nextRow)
    {
        [self addSubview:view];
    }        
}

- (void) setDigitNames:(NSArray *)names
{
	[imgArray removeAllObjects];
	for (NSString *name in names) 
	{
		UIImage *img = [Tools hiresImageNamed:[name stringByAppendingString:@".png"]];
		if (img)
		{
			[imgArray addObject:img];
		}
	}
}

- (double) value 
{
	return value;
}

- (void) setValue:(double)val animated:(BOOL)animated 
{
	value = val;
    [self setCurRow:[self rowForValue:value] animated:animated];
}

- (void) setValue:(double)val 
{
	[self setValue:val animated:NO];
}

- (void) removeAllStaticImages
{
    [staticImages removeAllObjects];
}

- (void) addStaticImage:(UIImage *)img atPosition:(int)pos
{
    [staticImages addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:pos], img, nil]];
}

-(BOOL) haveData
{
    return curRow!=nil;
}

@end
