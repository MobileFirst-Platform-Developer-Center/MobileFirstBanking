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

#import "MenuViewController.h"
#import "MobileFirstBanking.h"
#import <IBMMobileFirstPlatformFoundationHybrid/IBMMobileFirstPlatformFoundationHybrid.h>

#define BACKGROUND_COLOR [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:40.0/255.0 alpha:0.94]
#define light_blue [UIColor colorWithRed:0.0/255.0 green:179.0/255.0 blue:217.0/255.0 alpha:1]
#define TEXT_FONT [UIFont fontWithName:@"HelveticaNeue" size:14.0]
#define TEXT_COLOR [UIColor colorWithRed:0.0 green:(179.0/255.0) blue:(217.0/255.0) alpha:1]
#define KEY_BUTTON_ID @"buttonId"
#define ACTION_NATIVE_BUTTON_CLICKED @"nativeButtonClicked"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        
        [self.view setBackgroundColor:BACKGROUND_COLOR];
        
        UIView *buttonAccountPage = [self createButtonViewAtTopOffset:0 side:NO title:@"Accounts" buttonTag:1];
        UIView *buttonTransactionPage = [self createButtonViewAtTopOffset:0 side:YES title:@"Transactions" buttonTag:2];
        UIView *buttonCheckDeposit = [self createButtonViewAtTopOffset:140 side:NO title:@"Check Deposit" buttonTag:3];
        UIView *buttonAppointmentButton = [self createButtonViewAtTopOffset:140 side:YES title:@"Find ATM" buttonTag:4];
        UIView *buttonFindATMPage = [self createButtonViewAtTopOffset:280 side:NO title:@"Appointments" buttonTag:5];
        UIView *buttonLogout = [self createButtonViewAtTopOffset:280 side:YES title:@"Logout" buttonTag:6];
        
        [self.view addSubview:buttonAccountPage];
        [self.view addSubview:buttonTransactionPage];
        [self.view addSubview:buttonCheckDeposit];
        [self.view addSubview:buttonAppointmentButton];
        [self.view addSubview:buttonFindATMPage];
        [self.view addSubview:buttonLogout];
        
        [self.view setHidden:YES];
        
    }
    
    return self;
}


-(UIView*) createButtonViewAtTopOffset:(int)asdasd side:(BOOL)side title:(NSString*)title buttonTag:(int)buttonTag{
    
    int menuHeight = self.view.frame.size.height;
    int menuWidth = self.view.frame.size.width;
    
    int cellHeight = menuHeight / 3;
    int cellWidth = menuWidth/2;
    
    int rowIndex = (buttonTag - 1) / 2;
    int columnIndex = (buttonTag + 1) % 2;
    
    int topOffset = rowIndex * cellHeight;
    
    int leftOffset = columnIndex * 160;
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(leftOffset, topOffset, cellWidth, cellHeight)];
    [buttonView setTag:buttonTag];
    
    float buttonWidth = cellWidth*0.45;
    
    float buttonOffset = (cellWidth - buttonWidth) / 2.0;
    
    
    // icon
    NSString *imageName = [NSString stringWithFormat:@"menu_icon-0%d", buttonTag];
    UIImage *buttonImage = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:buttonImage];
    
    [imageView setFrame:CGRectMake(buttonOffset, (buttonOffset / 1.5) , buttonWidth, buttonWidth)];
    [buttonView addSubview:imageView];
    
    // Label
    UILabel *label = [[UILabel alloc] init];
    [label setText:title];
    [label setTextColor:TEXT_COLOR];
    
    UIFont *font = [UIFont fontWithName:@"TrebuchetMS" size:14];
    [label setFont:font];
    
    int labelYOffset = imageView.frame.origin.y + buttonWidth + 5;

    [label setFrame:CGRectMake(0, labelYOffset, cellWidth, 30)];
    
    [label setTextAlignment:NSTextAlignmentCenter];
    [buttonView addSubview:label];
    
    //  cell borders
    buttonView.layer.borderColor = light_blue.CGColor;
    buttonView.layer.borderWidth = MENU_BUTTON_BORDER_WIDTH;
    
    // Gesture recognizer
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(buttonClicked:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    
    [buttonView addGestureRecognizer:tapGestureRecognizer];

    
    return buttonView;
    
}


-(void)show{
    [self.view setHidden:NO];
    
}

-(void)hide{
    [self.view setHidden:YES];
}

-(void)toggle{
    CATransition *animation = [CATransition animation];
    
    [animation setDuration:1];
    [animation setType:kCATransitionPush];

    if(self.view.hidden) {
        [animation setSubtype:kCATransitionFromTop];
    }
    else {
        [animation setSubtype:kCATransitionFromBottom];
        [animation setDuration:0.5f];
    }

    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.view layer] addAnimation:animation forKey:@"MenuViewController"];
    [self.view setHidden:!self.view.hidden];
    
}

-(IBAction)buttonClicked:(UITapGestureRecognizer*)sender{
    NSDictionary *data;
    
    switch ([sender.view tag]) {
            
        case 1:
            data = [NSDictionary dictionaryWithObject:@"PageAccount" forKey:KEY_BUTTON_ID];
            break;
        case 2:
            data = [NSDictionary dictionaryWithObject:@"PageTransaction" forKey:KEY_BUTTON_ID];
            break;
        case 3:
            data = [NSDictionary dictionaryWithObject:@"PageCheckDeposit" forKey:KEY_BUTTON_ID];
            break;
        case 4:
            data = [NSDictionary dictionaryWithObject:@"PageFindATM" forKey:KEY_BUTTON_ID];
            break;
        case 5:
            data = [NSDictionary dictionaryWithObject:@"PageAppointment" forKey:KEY_BUTTON_ID];
            break;
        case 6:
            data = [NSDictionary dictionaryWithObject:@"Logout" forKey:KEY_BUTTON_ID];
            break;
        default:
            data = [NSDictionary dictionary];
            break;
    }
    
    [[WL sharedInstance] sendActionToJS:ACTION_NATIVE_BUTTON_CLICKED withData:data];
    [self toggle];
    
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
