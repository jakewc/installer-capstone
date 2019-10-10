//
//  SiteViewController.m
//  Enabler Pump Manager
//
//  Created by ITL on 20/05/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import "SiteViewController.h"
#import "LoginViewController.h"
#import "UIButton+ButtonLayout.h"
#import "ImageNames.h"

#define PUMPVIEWMARGIN 5
#define ITL_WEB @"http://www.integration.co.nz"
@import EnablerApi;

extern ENBForecourt* _forecourt;

typedef enum {
    SAUnblock,
    SAStopAll,
    SAWeb,
    SALogout,
} SiteActions;

@interface SiteViewController ()
@property(weak, nonatomic) IBOutlet UITableView* actionTable;
@end

/**
 *  Using a table view to store all site control options, so later on we can add
 * more functions
 */
@implementation SiteViewController {
    // Operation Images
    NSMutableArray* actionImages;
    
    // Operation Title
    NSMutableArray* actionTitles;
    
    // Operation Background
    NSMutableArray* actionBackgroundColor;
    
    // Processing view indicate the operation is processing
    UIAlertView* processView;
    
    NSTimer* processTimer;
    
    float rotation;
    
    // Another thread uses to handle operation requests
    dispatch_queue_t commandQueue;
    
    SiteActions siteActions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _actionTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Do any additional setup after loading the view.
    actionBackgroundColor = [[NSMutableArray alloc] init];
    [self initActions];
    commandQueue = dispatch_queue_create("commandQueue", DISPATCH_QUEUE_SERIAL);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initActions {
    // add to image set
    actionImages = [[NSMutableArray alloc] init];
    [actionImages addObject:[UIImage imageNamed:SITECONTROL_UNBLOCKALL]];
    [actionImages addObject:[UIImage imageNamed:SITECONTROL_STOPALL]];
    [actionImages addObject:[UIImage imageNamed:SITECONTROL_WEB]];
    [actionImages addObject:[UIImage imageNamed:LOGOUT_LOGOUT]];
    
    // add to title set
    actionTitles = [[NSMutableArray alloc] init];
    [actionTitles addObject:[NSString stringWithFormat:@"Unblock All Pumps"]];
    [actionTitles addObject:[NSString stringWithFormat:@"Stop All Pumps"]];
    [actionTitles addObject:[NSString stringWithFormat:@"Go to the ITL Website"]];
    [actionTitles addObject:[NSString stringWithFormat:@"Logout"]];
    
    // add to background color set
    // unblock
    [actionBackgroundColor addObject:[UIColor colorWithRed:170 / 255.0
                                                     green:226 / 255.0
                                                      blue:60 / 255.0
                                                     alpha:1]];
    // stop
    [actionBackgroundColor addObject:[UIColor colorWithRed:255 / 255.0
                                                     green:60 / 255.0
                                                      blue:21 / 255.0
                                                     alpha:1]];
    // web
    [actionBackgroundColor addObject:[UIColor colorWithRed:0 / 255.0
                                                     green:84 / 255.0
                                                      blue:112 / 255.0
                                                     alpha:1]];
    // logout
    [actionBackgroundColor addObject:[UIColor grayColor]];
}

#pragma mark - Table view delegate
- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {
    return actionTitles.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell =
    [tableView dequeueReusableCellWithIdentifier:@"cell"
                                    forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.imageView setImage:[actionImages objectAtIndex:indexPath.row]];
    cell.textLabel.text = [actionTitles objectAtIndex:indexPath.row];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    if (indexPath.row >= 2) {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return self.view.frame.size.height / (actionTitles.count * 2);
}

- (void)tableView:(UITableView*)tableView
didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell =
    (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    [cell setAlpha:0.8];
    
    [self performSelector:@selector(deselected) withObject:nil afterDelay:0.5];
    
    __block int result = 0;
    [self showProcessingView];
    
    dispatch_async(commandQueue, ^{
        switch ((SiteActions)indexPath.row) {
            case SAUnblock:
                for (int index = 0; index < _forecourt.pumps.count; index++) {
                    result =
                    [[_forecourt.pumps getByIndex:index] setBlock:NO
                                                    ReasonMessage:@"unblock pump"];
                }
                
                if (result != 0) {
                    [self showAlertWithMessage:@"Pumps are not all unblocked"];
                }
                break;
                
            case SAStopAll:
                result = [_forecourt stop];
                if (result != 0) {
                    [self showAlertWithMessage:@"Pumps are not all stopped"];
                }
                break;
                
            case SAWeb: {
                siteActions = SAWeb;
                UIAlertView* alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Go to ITL Website?"
                                          message:@"Send the application into background will "
                                          @"close the connection with Pump Server"
                                          delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Go", nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alertView show];
                });
            } break;
            case SALogout: {
                siteActions = SALogout;
                UIAlertView* alertView =
                [[UIAlertView alloc] initWithTitle:@"Logout?"
                                           message:nil
                                          delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 otherButtonTitles:@"Yes", nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alertView show];
                });
            } break;
            default:
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissProcessingView:indexPath.row];
        });
    });
}

- (void)tableView:(UITableView*)tableView
  willDisplayCell:(UITableViewCell*)cell
forRowAtIndexPath:(NSIndexPath*)indexPath {
    // add spaces between each cell
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIView* clearRoundedCornerView = [[UIView alloc]
                                      initWithFrame:CGRectMake(0, PUMPVIEWMARGIN, cell.frame.size.width,
                                                               cell.frame.size.height - PUMPVIEWMARGIN * 2)];
    clearRoundedCornerView.tag = -1;
    clearRoundedCornerView.backgroundColor =
    [actionBackgroundColor objectAtIndex:indexPath.row];
    clearRoundedCornerView.layer.masksToBounds = NO;
    clearRoundedCornerView.layer.cornerRadius = 3.0;
    
    [cell.contentView addSubview:clearRoundedCornerView];
    [cell.contentView sendSubviewToBack:clearRoundedCornerView];
}

#pragma mark - Support Function
- (void)showAlertWithMessage:(NSString*)message {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Stop Results"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

/**
 *  Dismiss the touch effect
 */
- (void)deselected {
    UITableViewCell* cell = (UITableViewCell*)[_actionTable
                                               cellForRowAtIndexPath:[_actionTable indexPathForSelectedRow]];
    
    [cell setAlpha:1];
}

#pragma mark Animation
- (void)showProcessingView {
    processView = [[UIAlertView alloc] initWithTitle:@"Processing..."
                                             message:nil
                                            delegate:self
                                   cancelButtonTitle:nil
                                   otherButtonTitles:nil];
    
    rotation = 0;
    
    UIImageView* imageView =
    [[UIImageView alloc] initWithImage:[UIImage imageNamed:LOGON_SPINNER]];
    
    [imageView setContentMode:UIViewContentModeCenter];
    
    [processView setValue:imageView forKey:@"accessoryView"];
    
    processTimer = [NSTimer timerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(changeAnimation:)
                                           userInfo:imageView
                                            repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:processTimer forMode:NSRunLoopCommonModes];
    
    [processView show];
}

/**
 *  Dismiss the process view
 *
 *  @param index Command index
 */
- (void)dismissProcessingView:(NSInteger)index {
    [processView dismissWithClickedButtonIndex:index animated:YES];
    // Release the timer
    [processTimer invalidate];
}

- (void)changeAnimation:(id)sender {
    rotation += 0.1;
    UIImageView* view = (UIImageView*)[sender userInfo];
    
    if (rotation > 2) {
        rotation = 0;
    }
    
    view.transform = CGAffineTransformMakeRotation(M_PI * rotation);
}

#pragma mark - Alert delegate
- (void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex > 0) {
        switch (siteActions) {
            case SALogout:
                [self logout];
                break;
            case SAWeb:
                [[UIApplication sharedApplication]
                 openURL:[NSURL URLWithString:ITL_WEB]];
            default:
                break;
        }
    }
}

- (void)logout {
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app setIsConnected:NO];
    int result;
    
    if ([_forecourt isConnected]) {
        result = [_forecourt disconnectWithMessage:@"Disconnected"];
        if (result == 0) {
            app.tabbarController.selectedIndex = 0;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end
