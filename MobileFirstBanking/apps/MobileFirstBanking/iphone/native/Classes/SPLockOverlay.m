//
//  SPLockOverlay.m
//  SuQian
//
//  Created by Suraj on 25/9/12.
//  Copyright (c) 2012 Suraj. All rights reserved.
//

#import "SPLockOverlay.h"

#define kLineColor			[UIColor grayColor]
#define kLineGridColor		[UIColor grayColor]
#define light_blue          [UIColor colorWithRed:0.0/255.0 green:179.0/255.0 blue:217.0/255.0 alpha:0.1]

@implementation SPLockOverlay

@synthesize pointsToDraw;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
			self.backgroundColor = [UIColor clearColor];
			self.pointsToDraw = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat lineWidth = 2.0;
	
	CGContextSetLineWidth(context, lineWidth);
    UIColor *lineColor = [UIColor colorWithRed:(150.0/255.0) green:(144.0/255.0) blue:(174.0/255.0) alpha:1.0];
	CGContextSetStrokeColorWithColor(context, lineColor.CGColor);

    for(SPLine *line in self.pointsToDraw)
		{			
			CGContextMoveToPoint(context, line.fromPoint.x, line.fromPoint.y);
			CGContextAddLineToPoint(context, line.toPoint.x, line.toPoint.y);
			CGContextStrokePath(context);
			
			CGFloat nodeRadius = 60.0;
			
			CGRect fromBubbleFrame = CGRectMake(line.fromPoint.x- nodeRadius/2, line.fromPoint.y - nodeRadius/2, nodeRadius, nodeRadius);
			CGContextSetFillColorWithColor(context, light_blue.CGColor);
			CGContextFillEllipseInRect(context, fromBubbleFrame);
			
			if(line.isFullLength){
				CGRect toBubbleFrame = CGRectMake(line.toPoint.x - nodeRadius/2, line.toPoint.y - nodeRadius/2, nodeRadius, nodeRadius);
				CGContextFillEllipseInRect(context, toBubbleFrame);
			}
		}
}

@end
