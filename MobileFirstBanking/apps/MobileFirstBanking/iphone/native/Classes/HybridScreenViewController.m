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

#import "HybridScreenViewController.h"
#import <IBMMobileFirstPlatformFoundationHybrid/IBMMobileFirstPlatformFoundationHybrid.h>
#import "ValidatePinViewController.h"

@import EventKit;

@import LocalAuthentication;


@interface HybridScreenViewController () {
    UIActivityIndicatorView *activityView;
    UIBarButtonItem *barButtonItem;
    UIView *menuBar;
    UIImage *menuButtonImage;
    MenuViewController *menuViewController;
    
    BOOL menuVisible;
}

@end

@implementation HybridScreenViewController {
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.startPage = [[WL sharedInstance] mainHtmlFilePath];
        
        int menuBarPadding = 10;
        
        barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                         style:UIBarButtonItemStyleDone
                                                        target:self
                                                        action:@selector(backButtonClicked)];
        
        
        barButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem = barButtonItem;
        
        
        menuButtonImage = [UIImage imageNamed:@"menu_icon.png"];
        float newImageWidth = menuButtonImage.size.width * 0.65;
        CGSize newSize = CGSizeMake(newImageWidth, newImageWidth);
        
        
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [menuButtonImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        menuButtonImage = newImage;
        
        CGFloat menuButtonHeight = menuButtonImage.size.height;
        
        menuVisible = NO;
        menuViewController = [[MenuViewController alloc] initWithFrame:CGRectMake((-1*MENU_BUTTON_BORDER_WIDTH),64,320,self.view.frame.size.height-menuButtonHeight-64-(menuBarPadding*2)+(MENU_BUTTON_BORDER_WIDTH*6))];
        [self.view addSubview:menuViewController.view];
        

        int menuBarY = self.view.frame.origin.y + self.view.frame.size.height - menuButtonHeight - (menuBarPadding*2) + 1;
        CGRect menuBarFrame = CGRectMake(0, menuBarY, 320, menuButtonHeight + (menuBarPadding*2));
        menuBar = [[UIView alloc] initWithFrame:menuBarFrame];
        menuBar.backgroundColor = LIGHT_GRAY;
        
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setImage:menuButtonImage forState:UIControlStateNormal];
        menuButton.frame = CGRectMake(0, menuBarPadding, 320, menuButtonHeight);
        [menuBar addSubview:menuButton];
        [menuButton addTarget:self action:@selector(menuButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self.view addSubview:menuBar];
        [menuBar setHidden:YES];
        
        [[WL sharedInstance] addActionReceiver:self];
    }
    
    
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.webView setBackgroundColor:[UIColor whiteColor]];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

-(void)createAppointment:(NSDictionary *)data {
    
    NSString *dateString = [data valueForKey:@"date"];
    NSString *timeString = [data valueForKey:@"time"];
    NSString *locationString = [data valueForKey:@"location"];
    
    
    EKEventStore *store = [[EKEventStore alloc] init];
    
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = @"MobileFirst Banking Appointment";
        
        NSString *fullDate = [[NSString alloc] initWithFormat:@"%@ %@", dateString, timeString];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd kk:mm"];
        NSDate *dateObj = [formatter dateFromString:fullDate];
        
        event.location = locationString;
        
        event.startDate = dateObj;
        event.endDate = [event.startDate dateByAddingTimeInterval:60*60];
        [event setCalendar:[store defaultCalendarForNewEvents]];
        NSError *err = nil;
        
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        
        
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEEE MMMM d, YYYY 'at' hh:mm a"];
        NSString *dateString = [dateFormat stringFromDate:date];
        
        NSString * message = [[NSString alloc] initWithFormat:@"Your Appointment has been scheduled for %@ in our %@ branch", dateString, locationString];
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:event.title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[WL sharedInstance] performSelectorOnMainThread:@selector(sendActionToJS:) withObject:@"calendarEventReceived" waitUntilDone:NO];
}


-(void)onActionReceived:(NSString *)action withData:(NSDictionary *)data{
    
    SEL selectorToCall = nil;
    id objToSend = nil;
    
    [[self.webView scrollView] setScrollEnabled:YES];
    
    if([action isEqualToString:@"showDashboard"]) {
        [[self.webView scrollView] setScrollEnabled:NO];
        selectorToCall = @selector(showDashboard:);
        objToSend = data;
    } else if([action isEqualToString:@"showSecondaryPage"]) {
        selectorToCall = @selector(showSecondaryPage:);
        objToSend = data;
        
    } else if([action isEqualToString:@"createAppointment"]) {
        selectorToCall = @selector(createAppointment:);
        objToSend = data;
    } else if ([action isEqualToString:@"startActivityViewSpinner"]){
        selectorToCall = @selector(toggleActivityViewSpinner:);
        objToSend = [NSNumber numberWithBool:YES];
    } else if ([action isEqualToString:@"stopActivityViewSpinner"]){
        selectorToCall = @selector(toggleActivityViewSpinner:);
    } else if ([action isEqualToString:@"getTransferPin"]){
        selectorToCall = @selector(getTransferPin);
    } else if ([action isEqualToString:@"LogoutButtonClicked"]){
        selectorToCall = @selector(onLogout);
    }
    
    if (nil != selectorToCall){
        [self performSelectorOnMainThread:selectorToCall withObject:objToSend waitUntilDone:NO];
    }
}

-(void)onLogout{
    [[WL sharedInstance] removeActionReceiver:self];
}

-(void)showDashboard:(NSDictionary*)data {
    self.webView.scrollView.scrollEnabled = NO;
    barButtonItem.title = @"";
    barButtonItem.enabled = NO;
    
    [[[self navigationController] navigationBar] setHidden:YES];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [menuBar setHidden:YES];
    
    [[WL sharedInstance] sendActionToJS:@"showStatusBar"];
}

-(void)showSecondaryPage:(NSDictionary*)data {
    NSString *title = [[data objectForKey:@"title"] uppercaseString];
    
    [self setTitle:title];
    
    [barButtonItem setTitle:@"Back"];
    [barButtonItem setEnabled:YES];
    
    [menuBar setHidden:NO];
    
    [[[self webView] scrollView] setScrollEnabled:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[[self navigationController] navigationBar] setHidden:NO];
    
        [[WL sharedInstance] sendActionToJS:@"hideStatusBar"];
}


-(void)startActivityViewSpinner{
    [self setNeedsStatusBarAppearanceUpdate];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    [activityView setFrame:CGRectMake(280, 25, 32, 32)];
    
    [[[self navigationController] view] addSubview:activityView];
    
    [activityView startAnimating];
}

-(void)toggleActivityViewSpinner:(id)enabled{
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (enabled){
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.frame = CGRectMake(280, 25, 32, 32);
        [self.navigationController.view addSubview:activityView];
        [activityView startAnimating];
    } else {
        [activityView removeFromSuperview];
    }
}

-(void)toggleWebScrolling:(BOOL)enabled{
    if (enabled){
        self.webView.scrollView.scrollEnabled = YES;
    } else{
        self.webView.scrollView.scrollEnabled = NO;
    }
}

-(void)getTransferPin{
    
    LAContext *laContext = [[LAContext alloc] init];
    if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]){
        
        [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Use TouchID to confirm the transaction" reply:^(BOOL success, NSError *error) {
            if (success){
                [[WL sharedInstance] sendActionToJS:@"transferPinValidationSuccess"];
            } else {
                [self performSelectorOnMainThread:@selector(showPinConfirmationScreen) withObject:self waitUntilDone:nil];
            }
        }];
        
    } else {
        [self performSelectorOnMainThread:@selector(showPinConfirmationScreen) withObject:self waitUntilDone:nil];
    }
    
}

-(void)showPinConfirmationScreen{
    ValidatePinViewController *validatePinViewController = [[ValidatePinViewController alloc] init];
    [self.view addSubview:validatePinViewController.view];
}

-(void)menuButtonClicked{
    [menuViewController toggle];
}

-(void)backButtonClicked{
    [[WL sharedInstance] sendActionToJS:@"nativeBackButtonClicked"];
    [menuViewController hide];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
