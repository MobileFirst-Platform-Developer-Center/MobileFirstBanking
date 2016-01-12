/*
 *  © Copyright 2015 IBM Corp.
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
#import <UIKit/UIKit.h>
#import "Cordova/CDVViewController.h"
#import <IBMMobileFirstPlatformFoundationHybrid/IBMMobileFirstPlatformFoundationHybrid.h>
#import "MobileFirstBanking.h"
#import "MenuViewController.h"

#define NAV_BAR_TINT_COLOR  [UIColor colorWithRed:0.0/255.0 green:179.0/255.0 blue:217.0/255.0 alpha:1]
#define NAV_BAR_TEXT_FONT   [UIFont fontWithName:@"Helvetica Neue" size:20]
#define NAV_BAR_TEXT_COLOR  [UIColor whiteColor]


@interface HybridScreenViewController : CDVViewController <WLActionReceiver, UIAlertViewDelegate>{
	
}

@end
