//
//  SPLockOverlay.h
//  SuQian
//
//  Created by Suraj on 25/9/12.
//  Copyright (c) 2012 Suraj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPLine.h"
#import "NormalCircle.h"

@interface SPLockOverlay : UIView

@property (nonatomic, strong) NSMutableArray *pointsToDraw;
@property (nonatomic) NormalCircle *theCircle;

@end
