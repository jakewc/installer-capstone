//
//  PumpViewController.m
//  Enabler Pump Manager
//
//  Created by ITL on 27/05/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import "PumpViewController.h"
#import "PumpWidgetView.h"
#import "UIButton+ButtonLayout.h"
#import "Common.h"
#import "ImageNames.h"

#define BUTTON_AUTH @"Authorise"
#define BUTTON_STOP @"Stop"
#define BUTTON_BLOCK @"Block"
#define BUTTON_UNBLOCK @"Unblock"

extern ENBForecourt *_forecourt;

@implementation PumpViewController {
    IBOutlet ScrollView *pumpWidgetView;
    __weak IBOutlet UIButton *btnAuthorise;
    __weak IBOutlet UIButton *btnStop;
    __weak IBOutlet UIButton *btnBlock;
    __weak IBOutlet UITableView *transTable;
    
    BOOL pumpBlocked;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [btnAuthorise centerImageAndTitle];
    [btnBlock centerImageAndTitle];
    [btnStop centerImageAndTitle];
    
    // Add forecourt delegation
    [_forecourt addDelegate:self];
    
    transTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [transTable reloadData];
    [_currentPump addDelegate:self];
    [self loadButtons];
    // Do any additional setup after loading the view.
    pumpWidgetView.delegate = self;
    pumpWidgetView.dataSource = self;
    pumpWidgetView.orientation = ScrollViewOrientationHorizontal;
    
    // preload the specific pump
    [pumpWidgetView initializeWithItemNumber:_currentIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Load button based on current pump status
 */
- (void)loadButtons {
    pumpBlocked = _currentPump.isBlocked;
    if (pumpBlocked) {
        [btnBlock setTitle:BUTTON_UNBLOCK forState:UIControlStateNormal];
        [btnBlock setImage:[UIImage imageNamed:PUMPDETAILSBUTTON_UNBLOCK]
                  forState:UIControlStateNormal];
        [btnBlock setBackgroundColor:[UIColor colorWithRed:170 / 255.0
                                                     green:226 / 255.0
                                                      blue:60 / 255.0
                                                     alpha:1]];
    } else {
        [btnBlock setTitle:BUTTON_BLOCK forState:UIControlStateNormal];
        [btnBlock setImage:[UIImage imageNamed:PUMPDETAILSBUTTON_BLOCK]
                  forState:UIControlStateNormal];
        [btnBlock setBackgroundColor:[UIColor colorWithRed:134 / 255.0
                                                     green:134 / 255.0
                                                      blue:134 / 255.0
                                                     alpha:1]];
    }
}

#pragma mark - Scroll delegate
- (CGSize)itemSizeInScrollView:(ScrollView *)scrollView {
    return CGSizeMake(pumpWidgetView.bounds.size.width,
                      pumpWidgetView.bounds.size.height);
}

- (UIView *)scrollView:(ScrollView *)scrollView
    cellForItemAtIndex:(NSInteger)index {
    PumpWidgetView *pumpWidgetUI =
    (PumpWidgetView *)[pumpWidgetView dequeueReuseableCellFromIndex:index];
    
    if ((NSObject *)pumpWidgetUI == [NSNull null]) {
        pumpWidgetUI = [[PumpWidgetView alloc]
                        initWithFrame:CGRectMake(0, 0, pumpWidgetView.bounds.size.width,
                                                 pumpWidgetView.bounds.size.height)];
        [pumpWidgetUI setPump:[_forecourt.pumps getByIndex:(int)index]];
    }
    
    return pumpWidgetUI;
}

- (NSInteger)numberOfItemsInScrollView:(ScrollView *)scrollView {
    return _forecourt.pumps.count;
}

- (void)didScrollToItem:(NSInteger)itemNumber
           inScrollView:(ScrollView *)scrollView {
    _currentPump = [_forecourt.pumps getByIndex:(int)(itemNumber)];
    [self loadButtons];
    [_currentPump addDelegate:self];
    [transTable reloadData];
}

#pragma mark - Click operations
- (IBAction)ClickAuth:(id)sender {
    int result = [_currentPump authoriseNoLimitsWithClientActivtity:@"IOS"
                                                    ClientReference:@"IOS Client"
                                                        AttendantID:-1];
    if (result != 0) {
        [self showAlertWithMessage:[ENBForecourt getResultString:result]];
    }
}

- (IBAction)ClickStop:(id)sender {
    int result = [_currentPump stop];
    if (result == 0) {
        pumpBlocked = YES;
        [btnBlock setTitle:BUTTON_UNBLOCK forState:UIControlStateNormal];
        [btnBlock setImage:[UIImage imageNamed:PUMPDETAILSBUTTON_UNBLOCK]
                  forState:UIControlStateNormal];
        [btnBlock setBackgroundColor:[UIColor colorWithRed:170 / 255.0
                                                     green:226 / 255.0
                                                      blue:60 / 255.0
                                                     alpha:1]];
    } else {
        [self showAlertWithMessage:[ENBForecourt getResultString:result]];
    }
}

- (IBAction)ClickBlock:(id)sender {
    int result;
    if (pumpBlocked) {
        result = [_currentPump setBlock:NO ReasonMessage:@"IOS UnBlock"];
        if (result == 0) {
            [btnBlock setTitle:BUTTON_BLOCK forState:UIControlStateNormal];
            [btnBlock setImage:[UIImage imageNamed:PUMPDETAILSBUTTON_BLOCK]
                      forState:UIControlStateNormal];
            [btnBlock setBackgroundColor:[UIColor colorWithRed:134 / 255.0
                                                         green:134 / 255.0
                                                          blue:134 / 255.0
                                                         alpha:1]];
            pumpBlocked = NO;
        }
    } else {
        result = [_currentPump setBlock:YES ReasonMessage:@"IOS Block"];
        if (result == 0) {
            [btnBlock setTitle:BUTTON_UNBLOCK forState:UIControlStateNormal];
            [btnBlock setImage:[UIImage imageNamed:PUMPDETAILSBUTTON_UNBLOCK]
                      forState:UIControlStateNormal];
            [btnBlock setBackgroundColor:[UIColor colorWithRed:170 / 255.0
                                                         green:226 / 255.0
                                                          blue:60 / 255.0
                                                         alpha:1]];
            pumpBlocked = YES;
        }
    }
    
    if (result != 0) {
        [self showAlertWithMessage:[ENBForecourt getResultString:result]];
    }
}

#pragma mark - Click Effect
- (IBAction)buttonTouchEffect:(UIButton *)sender {
    [sender setAlpha:0.8];
}

- (IBAction)buttonTouchFinish:(UIButton *)sender {
    [sender setAlpha:1];
}

#pragma mark - Forecourt Event
- (void)onServerEvent {
    // pop the previous page, otherwise a phantom page will display
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Pump Events
- (void)OnTransactionEvent:(ENBPump *)pump
                 EventType:(ENBTransactionEventType)eventType
             TransactionID:(NSInteger)transactionId
               Transaction:(ENBTransaction *)trans {
    if (pump) {
        if (pump.ID == _currentPump.ID) {
            _currentPump = pump;
            switch (eventType) {
                case ENBTransactionEventTypeStacked:
                case ENBTransactionEventTypeCleared: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [transTable reloadData];
                    });
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)OnStatusDidChangeEvent:(ENBPump *)pump
                     EventType:(ENBPumpStatusEventType)eventType {
    if (pump) {
        if (pump.ID == _currentPump.ID) {
            _currentPump = pump;
            if (eventType == ENBPumpStatusEventTypeBlocked) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadButtons];
                });
            }
        }
    }
}

#pragma mark - UITable Delegates
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"cell"];
    }
    
    ENBTransaction *trans =
    [_currentPump.transactionStack getByIndex:(int)indexPath.row];
    
    cell.textLabel.text = [NSString
                           stringWithFormat:@"%@: %@ %@,%@ %@", trans.deliveryData.grade.name,
                           [Common getLocaleCurrencySymbol],
                           trans.deliveryData.money,
                           [Common getGradeUnitFromTransaction:trans],
                           trans.deliveryData.quantity];
    
    cell.detailTextLabel.text =
    [NSString stringWithFormat:@"Hose:%d, Unit Price:%@", trans.hose.number,
     trans.deliveryData.unitPrice];
    [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return _currentPump.transactionStack.count;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    return @"Stacked Deliveries";
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 33;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIView *clearRoundedCornerView =
    [[UIView alloc] initWithFrame:CGRectMake(0, 3, cell.frame.size.width,
                                             cell.frame.size.height - 6)];
    clearRoundedCornerView.backgroundColor = [UIColor whiteColor];
    clearRoundedCornerView.layer.masksToBounds = NO;
    clearRoundedCornerView.layer.cornerRadius = 3.0;
    
    [cell.contentView addSubview:clearRoundedCornerView];
    [cell.contentView sendSubviewToBack:clearRoundedCornerView];
}

#pragma mark - Support Functions
- (void)showAlertWithMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Results"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}
@end
