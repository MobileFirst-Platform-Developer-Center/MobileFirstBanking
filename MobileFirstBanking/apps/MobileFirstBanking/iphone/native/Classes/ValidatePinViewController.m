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

#import "ValidatePinViewController.h"
#import <IBMMobileFirstPlatformFoundationHybrid/IBMMobileFirstPlatformFoundationHybrid.h>

#define BACKGROUND_COLOR    [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:220.0/255.0];
#define TEXT_FONT           [UIFont fontWithName:@"Helvetica-Light" size:24]
#define TEXT_COLOR          [UIColor colorWithRed:10.0/255.0 green:10.0/255.0 blue:10.0/255.0 alpha:220.0/255.0];

@interface ValidatePinViewController (){
	SPLockScreen *lockScreen;
	UILabel *attemptsLeftLabel;
	int attemptsLeft;
}
@end

@implementation ValidatePinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		attemptsLeft = 3;
		self.view.backgroundColor = BACKGROUND_COLOR;
		
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 320, 50)];
		textLabel.font = TEXT_FONT;
		textLabel.textAlignment = NSTextAlignmentCenter;
		textLabel.textColor = TEXT_COLOR;

		textLabel.text = @"draw pattern to confirm";
		[self.view addSubview:textLabel];
		
		attemptsLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 450, 320, 50)];
		attemptsLeftLabel.font = TEXT_FONT;
		attemptsLeftLabel.textAlignment = NSTextAlignmentCenter;
		attemptsLeftLabel.textColor = TEXT_COLOR;
		attemptsLeftLabel.text = @"three attempts left";
		[self.view addSubview:attemptsLeftLabel];
        
		lockScreen = [[SPLockScreen alloc] initWithDelegate:self];
		lockScreen.frame = CGRectMake(0, 180, 320, 500);
		[self.view addSubview:lockScreen];
    }
    return self;
}

-(void)lockScreen:(SPLockScreen *)lockScreen didEndWithPattern:(NSNumber *)patternNumber{
	if ([patternNumber integerValue] == VALID_PATTERN){
		[self.view removeFromSuperview];
		[[WL sharedInstance] sendActionToJS:@"transferPinValidationSuccess"];
	} else {
		attemptsLeft--;
		attemptsLeftLabel.text = (attemptsLeft == 2) ? @"two attempts left" : @"last attempt";
	}
	
	if (attemptsLeft == 0){
		[self.view removeFromSuperview];
		[[WL sharedInstance] sendActionToJS:@"transferPinValidationFailure"];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
