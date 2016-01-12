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

#import "LoginScreenViewController.h"
#import "HybridScreenViewController.h"
#import "MobileFirstBanking.h"

@import LocalAuthentication;

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define TEXT_FONT [UIFont fontWithName:@"Helvetica-Light" size:24]
#define TEXT_COLOR [UIColor grayColor]


@interface LoginScreenViewController(){
	HybridScreenViewController *hybridViewController;
	SPLockScreen *lockScreen;
    CGSize logoSize;
}

@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) UIImageView *logoImageView;
@property (nonatomic, retain) UIImageView *labelImageView;

@end

@implementation LoginScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		CGRect appWindowBounds = [[[[UIApplication sharedApplication] delegate] window] bounds];

		_backgroundImageView = [[UIImageView alloc] initWithFrame:appWindowBounds];
		_backgroundImageView.image = [UIImage imageNamed:@"mountain_background"];
		
        
        UIImage *logoImage = [UIImage imageNamed:@"mfbanking_logo"];
        
        float sizeFactor = 0.24;
        logoSize = CGSizeMake(logoImage.size.width*sizeFactor, logoImage.size.height*sizeFactor);
        
        UIGraphicsBeginImageContextWithOptions(logoSize, NO, 0.0);
        [logoImage drawInRect:CGRectMake(0, 0, logoSize.width, logoSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        logoImage = newImage;
        
        
        _logoImageView = [[UIImageView alloc] initWithImage:logoImage];
		
		[[WL sharedInstance] initializeWebFrameworkWithDelegate:self];
		[[WL sharedInstance] addActionReceiver:self];
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	[self.view addSubview:_backgroundImageView];
	[self.view addSubview:_logoImageView];

	[self startAnimation];
}
-(void)startAnimation{
	CGRect appWindowBounds = [[[[UIApplication sharedApplication] delegate] window] bounds];

    int boxHeight = 140;
    int boxWidth = appWindowBounds.size.width;
    
    float x = (boxWidth - logoSize.width) /2;
    
    float y = (boxHeight - logoSize.height) / 2;
    
    _logoImageView.frame = CGRectMake(x, y, logoSize.width, logoSize.height);
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, boxWidth, boxHeight)];
    [view setBackgroundColor:LIGHT_BLUE];
    
    
    [self.view addSubview:view];
    [self.view bringSubviewToFront:_logoImageView];
    
    // completion
    [self tryLoginWithTouch];
	
}

-(void)tryLoginWithTouch{
	[self performSelectorOnMainThread:@selector(showLoginScreen) withObject:self waitUntilDone:nil];
	LAContext *laContext = [[LAContext alloc] init];
	if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]){
		
		[laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Use TouchID to login" reply:^(BOOL success, NSError *error) {
			if (success){
				NSLog(@"TouchID validation success");
				[self performSelectorOnMainThread:@selector(loginSuccess) withObject:self waitUntilDone:nil];
			} else {
				NSLog(@"TouchID validation failure");
			}
		}];
		
	} else {
	}
	
}

-(void)showLoginScreen{
	
	UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, 320, 50)];
	textLabel.text = @"Enter code to begin";
	textLabel.textColor = TEXT_COLOR;
	textLabel.textAlignment = NSTextAlignmentCenter;

    UIFont *font = [UIFont fontWithName:@"TrebuchetMS" size:24];
    textLabel.font = font;
	[self.view addSubview:textLabel];

	
	lockScreen = [[SPLockScreen alloc] initWithDelegate:self];
	[lockScreen setFrame:CGRectMake(0, 240, 320, 500)];
	[self.view addSubview:lockScreen];

}

-(void)wlInitWebFrameworkDidCompleteWithResult:(WLWebFrameworkInitResult *)result
{
    if ([result statusCode] == WLWebFrameworkInitResultSuccess) {
		
		hybridViewController = [[HybridScreenViewController alloc] init];
		hybridViewController.view.frame = self.navigationController.view.bounds;
    } else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"WL INITIALIZATION ERROR"
															message:[result message]
														   delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
    }
}

-(void)viewWillAppear:(BOOL)animated{
	self.navigationController.navigationBar.hidden = YES;
}

-(void)lockScreen:(SPLockScreen *)lockScreen didEndWithPattern:(NSNumber *)patternNumber{
	if ([patternNumber integerValue] == VALID_PATTERN){
		[self loginSuccess];
	}
}

-(void)onActionReceived:(NSString *)action withData:(NSDictionary *)data{
	if ([action isEqualToString:@"LogoutButtonClicked"]){
		[self performSelectorOnMainThread:@selector(onLogoutButtonClicked) withObject:nil waitUntilDone:YES];
	}
}

-(void)loginSuccess{
	NSLog(@"loginSuccess");
	[self.navigationController pushViewController:hybridViewController animated:YES];
}

-(void)onLogoutButtonClicked{
	NSLog(@"onLogoutButtonClicked");
	[self.navigationController popViewControllerAnimated:YES];
	hybridViewController = [[HybridScreenViewController alloc] init];
	hybridViewController.view.frame = self.navigationController.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
