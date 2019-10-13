//
//  LoginViewController.m
//  Enabler Pump Manager
//
//  Created by ITL on 20/05/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "ForecourtViewController.h"
#import "SiteViewController.h"
#import "ImageNames.h"
#import "UIButton+ButtonLayout.h"

#define TERMINALNAME @"IOS Pump Manager"
#define TABBAR_ID @"MainBoard"
#define LOGIN_TIMEOUT 15.0

@interface LoginViewController ()
@property(weak, nonatomic) IBOutlet UITextField *txtServerAddress;
@property(weak, nonatomic) IBOutlet UITextField *txtTerminalID;
@property(weak, nonatomic) IBOutlet UITextField *txtTerminalPassword;
@property(weak, nonatomic) IBOutlet UIButton *btnLogin;

@end
/**
 *  Global variable to be shared by the app
 */
ENBForecourt *_forecourt;

#define KEYBOARD_HEIGH 270

@implementation LoginViewController {
    // The rotation of a processing view
    float rotation;
    
    //  Indicate if the Keyboard needs to be relocated
    float keyboardMoved;
    
    // A processing view
    UIAlertView *processView;
    
     //  Timer for the processing view
    NSTimer *timer;
}

/**
 *  Setup background color
 *
 *  @return
 */
- (CAGradientLayer *)backgroundGradient {
    UIColor *colorbottom = [UIColor colorWithRed:(0 / 255.0)
                                           green:(48 / 255.0)
                                            blue:(70 / 255.0)
                                           alpha:1.0];
    UIColor *colorTop = [UIColor colorWithRed:(0 / 255.0)
                                        green:(84 / 255.0)
                                         blue:(112 / 255.0)
                                        alpha:1.0];
    
    NSArray *colors =
    [NSArray arrayWithObjects:(id)colorTop.CGColor, colorbottom.CGColor, nil];
    
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *backgroundLayer = [CAGradientLayer layer];
    backgroundLayer.colors = colors;
    backgroundLayer.locations = locations;
    
    return backgroundLayer;
}

- (void)viewDidAppear:(BOOL)animated {
    CAGradientLayer *bgLayer = [self backgroundGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults *connectionData = [NSUserDefaults standardUserDefaults];
    
    [_btnLogin.layer setCornerRadius:6];
    
    _txtServerAddress.text = [connectionData objectForKey:@"server"];
    _txtTerminalID.text = [connectionData objectForKey:@"id"];
    _txtTerminalPassword.text = [connectionData objectForKey:@"password"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Initialize the Forecourt
 *
 *  @return Return YES when a forecourt is initialized
 */
- (BOOL)initForecourt {
    _forecourt = [[ENBForecourt alloc] init];
    [_forecourt addDelegate:self];
    if (_forecourt) {
        return YES;
    } else
        return NO;
}

/**
 *  Anmination of the loading image
 *
 *  @param sender UIImage View
 */
- (void)change:(id)sender {
    rotation += 0.1;
    UIImageView *view = (UIImageView *)[sender userInfo];
    
    if (rotation > 2) {
        rotation = 0;
    }
    
    view.transform = CGAffineTransformMakeRotation(M_PI * rotation);
}

#pragma mark - Click Operations
- (IBAction)clickLogin:(id)sender {
    // Valid inputs ?
    if (_txtServerAddress.text.length <= 0 || _txtTerminalID.text.length <= 0 ||
        _txtTerminalPassword.text.length <= 0) {
        return;
    }
    
    [_btnLogin setBackgroundColor:[UIColor colorWithRed:39 / 255.0
                                                  green:170 / 255.0
                                                   blue:225 / 255.0
                                                  alpha:1]];
    
    // Show a "Connecting..." alert view with logon spinner
    processView = [[UIAlertView alloc] initWithTitle:@"Connecting..."
                                           message:nil
                                          delegate:self
                                 cancelButtonTitle:nil
                                 otherButtonTitles:nil];
    
    // Add spinner to alert view
    UIImageView *imageView =
    [[UIImageView alloc] initWithImage:[UIImage imageNamed:LOGON_SPINNER]];
    
    [imageView setContentMode:UIViewContentModeCenter];
    
    [processView setValue:imageView forKey:@"accessoryView"];
    
    timer = [NSTimer timerWithTimeInterval:0.1
                                    target:self
                                  selector:@selector(change:)
                                  userInfo:imageView
                                   repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    [processView show];
    
    // reset the Enabler API forecourt
    _forecourt = nil;
    
    // Alloc and set delegates
    if (![self initForecourt]) {
        return;
    }
    
    // Set up a timer to monitor the login process
    NSTimer *timeoutCounter =
    [NSTimer timerWithTimeInterval:LOGIN_TIMEOUT
                            target:self
                          selector:@selector(errorOccured)
                          userInfo:nil
                           repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timeoutCounter
                              forMode:NSRunLoopCommonModes];
    
    // Use the Enabler Forecourt ConnecttoServer method with an asynchronous
    // completion to connect to pump server
    // this allows us to show the Connecting... spinner while the login is
    // running.
    [_forecourt
     connectToServer:_txtServerAddress.text
     withTerminalID:[_txtTerminalID.text intValue]
     withTerminalName:TERMINALNAME
     withPassword:_txtTerminalPassword.text
     setToFallback:YES
     Completion:^(int result) {
         
         // Stop Logon error timer
         [timeoutCounter invalidate];
         
         [timer invalidate];
         
         // The completion is not running on GUI/main thread so dispatch on
         // to it
         dispatch_sync(dispatch_get_main_queue(), ^{
             
             [processView dismissWithClickedButtonIndex:0 animated:YES];
             
             // reset the button color
             [_btnLogin setBackgroundColor:[UIColor colorWithRed:0
                                                           green:125 / 255.0
                                                            blue:177 / 255.0
                                                           alpha:1]];
             
             NSUserDefaults *connectionData =
             [NSUserDefaults standardUserDefaults];
             
             if (result == 0) {
                 // Set inputs as default data
                 [connectionData setObject:_txtServerAddress.text
                                    forKey:@"server"];
                 [connectionData setObject:_txtTerminalID.text forKey:@"id"];
                 [connectionData setObject:_txtTerminalPassword.text
                                    forKey:@"password"];
                 
                 [connectionData synchronize];
                 
                 [self authorisedLogin];
             } else {
                 processView = [[UIAlertView alloc]
                              initWithTitle:[ENBForecourt getResultString:result]
                              message:nil
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
                 [processView show];
             }
             
         });
         
     }];
}

#pragma mark Complete Login
/**
 *  Launch main screen when login request has been authorized
 */
- (void)authorisedLogin {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app setForecourt:_forecourt];
    [app setIsConnected:YES];
    
    [self presentViewController:app.tabbarController animated:YES completion:nil];
}

/**
 *  Handle login exception/timeout
 */
- (void)errorOccured {
    if (processView) {
        if (timer) {
            [timer invalidate];
        }
        [processView dismissWithClickedButtonIndex:0 animated:YES];
    }
    
    processView = [[UIAlertView alloc] initWithTitle:@"Error Occured"
                                           message:nil
                                          delegate:self
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@"OK", nil];
    
    [processView show];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UI Text Delegate
/**
 *  Dismiss the keyboard
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtServerAddress) {
        [self.txtTerminalID becomeFirstResponder];
    }
    
    if (textField == self.txtTerminalPassword) {
        [textField resignFirstResponder];
        [self clickLogin:_btnLogin];
    }
    
    return YES;
}

/**
 *  Before start editing, check if the view needs to be moved
 *
 *  @param textField selected textField
 */
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.frame.origin.y + textField.frame.size.height >=
        KEYBOARD_HEIGH) {
        [self relocatedKeyboard:YES
                      MoveAbout:textField.frame.origin.y +
         textField.frame.size.height - KEYBOARD_HEIGH];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self relocatedKeyboard:NO MoveAbout:0];
}

#pragma mark Help methods
/**
 *  Relocating keyboard
 *
 *  @param relocate Yes for relocate the keyboard based on the MoveAbout value
 *  @param distance move range
 */
- (void)relocatedKeyboard:(BOOL)relocate MoveAbout:(float)distance {
    CGRect rect = self.view.frame;
    
    if (relocate) {
        rect.origin.y -= distance;
        [self replaceTopConstraintOnObject:self.topLayoutGuide
                              withConstant:-distance];
    } else {
        if (keyboardMoved > 0) {
            rect.origin.y = distance;
            [self replaceTopConstraintOnObject:self.topLayoutGuide
                                  withConstant:keyboardMoved];
        }
    }
    
    keyboardMoved = distance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

/**
 *  Use a light version of the status bar
 *
 */
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

/**
 *  Update Contraint for moving the view
 *
 *  @param object   compare object
 *  @param constant constant value
 */
- (void)replaceTopConstraintOnObject:(id)object withConstant:(float)constant {
    [self.view.constraints
     enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint,
                                  NSUInteger index, BOOL *stop) {
         if (constraint.firstItem == object || constraint.secondItem == object) {
             constraint.constant += constant;
         }
     }];
}

@end
