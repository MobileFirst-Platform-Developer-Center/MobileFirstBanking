//
//  NormalCircle.m
//  SuQian
//
//  Created by Suraj on 24/9/12.
//  Copyright (c) 2012 Suraj. All rights reserved.
//

#import "NormalCircle.h"
#import <QuartzCore/QuartzCore.h>

#define kOuterColor			[UIColor colorWithRed:181/255.0 green:194/255.0 blue:204/255.0 alpha:1]

#define kInnerColor			[UIColor colorWithRed:181/255.0 green:194/255.0 blue:204/255.0 alpha:1]

#define kHighlightColor		[UIColor grayColor]
#define light_blue [UIColor colorWithRed:0.0/255.0 green:179.0/255.0 blue:217.0/255.0 alpha:1]

@implementation NormalCircle
@synthesize selected,cacheContext;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
	}
	return self;
    
}

- (id)initwithRadius:(CGFloat)radius
{
	CGRect frame = CGRectMake(0, 0, 2*radius, 2*radius);
	NormalCircle *circle = [self initWithFrame:frame];
	if (circle) {
		[circle setBackgroundColor:[UIColor clearColor]];
	}
	return circle;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	self.cacheContext = context;
	CGFloat lineWidth = 2.0;
	CGRect rectToDraw = CGRectMake(rect.origin.x+lineWidth, rect.origin.y+lineWidth, rect.size.width-2*lineWidth, rect.size.height-2*lineWidth);
	CGContextSetLineWidth(context, lineWidth);

	if (self.selected){
		CGContextSetStrokeColorWithColor(context, light_blue.CGColor);
	} else {
        CGContextSetStrokeColorWithColor(context, light_blue.CGColor);
	}
	
	CGContextStrokeEllipseInRect(context, rectToDraw);
	
	if(self.selected == NO)
		return;
}

- (void)highlightCell
{
	self.selected = YES;
	[self setNeedsDisplay];
}

- (void)resetCell
{
	self.selected = NO;
	[self setNeedsDisplay];
}


@end
