//
//  RequisitionDetailViewController.m
//  Drillco
//
//  Created by rodrigoe on 08-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//
#import "RequisitionDetailViewController.h"
#import "RequisitionDetailCell.h"
#import "SupplierViewController.h"
#import "ProductDetialViewController.h"
#import "RequisitionApproveViewController.h"
#import "RequisitionDeclineViewController.h"
#import "Reachability.h"

typedef void(^myCompletion) (BOOL);
typedef void(^my2Completion) (BOOL);

@interface RequisitionDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *requisitionDetailTableView;
@property (weak, nonatomic) IBOutlet UILabel *providerName_lbl;
@property (nonatomic) NSString * productName;
@property (nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) BOOL connection;
@property (nonatomic) NSMutableArray *supplierTotal;
@property (nonatomic) NSArray *supplier_result;
@end

@implementation RequisitionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Detalle" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.requisitionDetailTableView registerNib:[UINib nibWithNibName:@"RequisitionDetailCellView_style_1" bundle:nil] forCellReuseIdentifier:@"RequisitionDetailIdentifier"];
    self.requisitionDetailTableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.title = [NSString stringWithFormat:@"Detalle Nº%@",self.requisition_id];
    self.providerName_lbl.text = [self.provider_name uppercaseString];
    [self connect];

}


- (void) reloadData{
    

}

- (void) requisitionAlert:(NSString *) text{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Detalle requisición"
                                 message:text
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                }];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dbCallProduct:(myCompletion) dbBlock{
    [self connect];
    NSString * sql = [NSString stringWithFormat:@"select top 5 P.ID as [NUM REQUISICION], v.NAME as [NOMBRE PROVEEDOR], P.VENDOR_ID as [RUT], P.CURRENCY_ID as [MONEDA], P.DESIRED_RECV_DATE as [FEC DESEADA], pl.UNIT_PRICE as [PRECIO UNIT] from PURC_REQUISITION p, VENDOR v, PURC_REQ_LINE pl, PART pa where p.STATUS = 'C' and p.VENDOR_ID = v.ID and p.ID = pl.PURC_REQ_ID and pa.ID = pl.PART_ID and pa.DESCRIPTION = '%@' order by p.desired_recv_date desc,p.id,pl.LINE_NO", self.productName];
    [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
        if (results) {
            self.results = results[0];
            [[SQLClient sharedInstance] disconnect];
            if(self.results){
                dbBlock(YES);
            }
            
        }
    }];
}

- (void) dbCallSupplier:(myCompletion) dbBlock{
    [self connect];
    NSString *sql = [NSString stringWithFormat:@"select top 5 p.ID, p.total_amt_ordered, P.REQUISITION_DATE, v.NAME from PURC_REQUISITION p, VENDOR v where p.vendor_id = v.id and p.status = 'C' and v.NAME = '%@' order by REQUISITION_DATE", self.provider_name];
    [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
        if (results) {
            self.results = results[0];
            dbBlock(YES);
        }
    }];
}

- (void) dbApproveRequisition:(myCompletion) dbBlock{
    if(self.connection){
    //NSString *sql = [NSString stringWithFormat:@"UPDATE PURC_REQUISITION set STATUS = 'V', ASSIGNED_TO = 'FPADILLA', APP1_DATE = getdate(), APP2_DATE = getdate(), USER_10 = 'APP_MOVIL' where ID = '%@'; update purc_req_line set line_status = 'V' where purc_req_id = '%@'; UPDATE TASK SET USER_ID = 'FPADILLA', STATUS = 'P' WHERE EC_ID = '%@' AND SEQ_NO = 1 AND SUB_TYPE = 'AT';", self.requisition_id, self.requisition_id, self.requisition_id];
    NSString *sql = [NSString stringWithFormat:@"UPDATE PURC_REQUISITION set STATUS = 'V', ASSIGNED_TO = 'GRIVERA', APP1_DATE = getdate(), APP2_DATE = getdate(), USER_9 = '%@', USER_10 = 'APP_MOVIL' where ID = '%@'; update purc_req_line set line_status = 'V' where purc_req_id = '%@'; select top 1 task_no,seq_no from TASK where EC_ID = '%@' order by seq_no desc UPDATE TASK SET USER_ID = 'GRIVERA', STATUS = 'P' WHERE EC_ID = '%@' AND SEQ_NO = 1 AND SUB_TYPE = 'AT' UPDATE TASK SET COMPLETED_DATE = getdate(), STATUS_EFF_DATE = getdate(), STATUS = 'C' WHERE EC_ID = '%@' AND SEQ_NO > 1 insert TASK (TYPE, TASK_NO, SEQ_NO, USER_ID, SUB_TYPE, EC_ID, STATUS, COMPLETED_DATE) select TYPE, TASK_NO, SEQ_NO + 1, '%@', '%@', EC_ID, 'C', GETDATE() from task where ec_id = '%@' and SEQ_NO = 1 and SUB_TYPE = 'AT';", self.username, self.requisition_id, self.requisition_id, self.requisition_id, self.requisition_id, self.requisition_id, self.username, self.requisition_type, self.requisition_id];
    [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
            dbBlock(YES);
    }];
    }else{
        dbBlock(NO);
    }
    
}

- (void) dbDeclineRequisition:(myCompletion) dbBlock{
    if(self.connection){
    NSString *sql = [NSString stringWithFormat:@"UPDATE PURC_REQUISITION set STATUS = 'X', ASSIGNED_TO = 'GRIVERA', APP1_DATE = getdate(), APP2_DATE = getdate(), USER_9 = '%@', USER_10 = 'APP_MOVIL' where ID = '%@'; update purc_req_line set line_status = 'X' where purc_req_id = '%@'; select top 1 task_no,seq_no from TASK where EC_ID = '%@' order by seq_no desc UPDATE TASK SET USER_ID = 'GRIVERA', STATUS = 'P' WHERE EC_ID = '%@' AND SEQ_NO = 1 AND SUB_TYPE = 'AT' UPDATE TASK SET COMPLETED_DATE = getdate(), STATUS_EFF_DATE = getdate(), STATUS = 'C' WHERE EC_ID = '%@' AND SEQ_NO > 1 insert TASK (TYPE, TASK_NO, SEQ_NO, USER_ID, SUB_TYPE, EC_ID, STATUS, COMPLETED_DATE) select TYPE, TASK_NO, SEQ_NO + 1, '%@', '%@', EC_ID, 'C', GETDATE() from task where ec_id = '%@' and SEQ_NO = 1 and SUB_TYPE = 'AT';", self.username, self.requisition_id, self.requisition_id, self.requisition_id, self.requisition_id, self.requisition_id, self.username, self.requisition_type, self.requisition_id];
    [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
         dbBlock(YES);
    }];
    }else{
        dbBlock(NO);
    }

}

-(void)dbTaskNumberByRequisitionId:(myCompletion) dbBlock{
        NSString *sql = [NSString stringWithFormat:@"select TASK_NO from TASK where USER_ID = 'GRIVERA' AND EC_ID = '%@'", self.requisition_id];
        [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
            if(results[0]){
                NSDictionary *dict = [results[0] objectAtIndex:0];
                self.task_no = [dict[@"TASK_NO"] description];
            }
            dbBlock(YES);
        }];
}

-(void) dbAfterApprove:(myCompletion) dbBlock{
    if(self.connection){
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
        NSString *date_now = [[dateFormatter stringFromDate:[NSDate date]] description];
        NSString *comment = [NSString stringWithFormat:@"%@ - %@ STATUS APPROVED x MOVIL REQ/%@ TASK/%@", self.username, date_now, self.requisition_id, self.task_no];
        NSString *sql = [NSString stringWithFormat:@"insert TASK_BINARY (TASK_TYPE,TASK_NO,SEQ_NO,TYPE,BITS,BITS_LENGTH) values ('REQ','%@',1,'D','%@', DATALENGTH('%@'))", self.task_no, comment, comment];
        [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
            dbBlock(YES);
        }];
    }else{
        dbBlock(NO);
    }
}

-(void) dbAfterDecline:(myCompletion) dbBlock{
    if(self.connection){
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
        NSString *date_now = [[dateFormatter stringFromDate:[NSDate date]] description];
        NSString *comment = [NSString stringWithFormat:@"%@ - %@ STATUS CANCELLED x MOVIL REQ/%@ TASK/%@", self.username, date_now, self.requisition_id, self.task_no];
        NSString *sql = [NSString stringWithFormat:@"insert TASK_BINARY (TASK_TYPE,TASK_NO,SEQ_NO,TYPE,BITS,BITS_LENGTH) values ('REQ','%@',1,'D','%@', DATALENGTH('%@'))", self.task_no, comment, comment];
        [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
            dbBlock(YES);
        }];
    }else{
        dbBlock(NO);
    }
}

- (IBAction)goToSupplier:(id)sender {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    self.spinner.color = [UIColor lightGrayColor];
    self.spinner.center=self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    if (networkStatus == NotReachable) {
        [self.spinner stopAnimating];
        [self.spinner hidesWhenStopped];
        [self requisitionAlert:@"Favor revise su conexión a internet."];
    }else{
    [self dbCallSupplier:^(BOOL finished){
            if(finished){
                NSLog(@"success");
                [self.spinner stopAnimating];
                [self.spinner hidesWhenStopped];
                [self didSelectSupplier];
            }else{
                NSLog(@"finished");
                [self.spinner stopAnimating];
                [self.spinner hidesWhenStopped];
                [self requisitionAlert:@"Un error ha ocurrido, favor intente nuevamente."];
            }
        }];
    }

}

- (void) didSelectSupplier{
    
    [self preloadTotalAmount];
}

- (void)preloadTotalAmount{
    self.supplierTotal = [NSMutableArray new];
    SupplierViewController *supplier_vc = [[SupplierViewController alloc] initWithNibName:@"SupplierView_style_1" bundle:nil];
    supplier_vc.supplierName = self.provider_name;
    self.supplier_result =  self.results;
    supplier_vc.supplier_result = self.results;
    [self callTotalAmountForRequisitionBlock:^(BOOL finished){
        if(finished){
            NSLog(@"success");
            supplier_vc.supplierTotal = self.supplierTotal;
            [[self navigationController] pushViewController:supplier_vc animated:YES];
        }else{
            NSLog(@"finished");
            [self.spinner stopAnimating];
            [self.spinner hidesWhenStopped];
        }
    }];

}

- (void) dbCallTotalAmountForEachNum:(NSString *) requisitionId Block:(myCompletion) dbBlock {
    [self connect];
    NSString * sql = [NSString stringWithFormat:@"select pl.ORDER_QTY * pl.UNIT_PRICE as [TOTAL_FINAL] from PURC_REQ_LINE pl,PURC_REQ_LN_BINARY pb, PART p where pl.PURC_REQ_ID = '%@' and pl.PURC_REQ_ID *= pb.PURC_REQ_ID and pl.LINE_NO *= pb.PURC_REQ_LINE_NO and pl.PART_ID *= p.id order by pl.line_no", requisitionId];
    [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
        if (results) {
            self.totalAmountByRequisition = results;
            NSLog(@"%@", self.totalAmountByRequisition);
            [[SQLClient sharedInstance] disconnect];
            if(self.totalAmountByRequisition){
                dbBlock(YES);
            }
            
        }
    }];
}

- (void) callTotalAmountForRequisitionBlock:(myCompletion) dbBlock{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    
    if (networkStatus == NotReachable) {
        [self.spinner stopAnimating];
        [self.spinner hidesWhenStopped];
        [self requisitionAlert:@"Favor revise su conexión a internet."];
    }else{
        [self blockToDoMore:^(BOOL finished) {
            if(finished){
                    dbBlock(YES);
            }else{
                
            }
        }];
    }

}

- (void) blockToDoMore:(my2Completion) dbBlock{
    NSString *requisition_id;
    for(int i = 0 ; i < [self.results count] ; i++){
        NSDictionary *supplier = [self.results objectAtIndex:i];
        requisition_id = supplier[@"ID"] ;
        [self dbCallTotalAmountForEachNum:requisition_id Block:^(BOOL finished){
            if(finished){
                NSLog(@"success");
                float total = 0.0;
                for(int j = 0 ; j < [self.totalAmountByRequisition[0] count] ; j++){
                    NSDictionary *dict = [self.totalAmountByRequisition[0] objectAtIndex:j];
                    total += [dict[@"TOTAL_FINAL"] floatValue];
                }
                NSString *totalAmount = [NSString stringWithFormat:@"%.02f", total];
                NSMutableDictionary * dict = [NSMutableDictionary new];
                [dict setValue:totalAmount forKey:@"total"];
                [self.supplierTotal addObject:dict];
                if([self.supplier_result count] == [self.supplierTotal count]){
                    dbBlock(YES);
                }
            }else{
                NSLog(@"finished");
            }
        }];
    }
    
    

}

- (void) didSelectProduct{
    ProductDetialViewController *product_vc = [[ProductDetialViewController alloc] initWithNibName:@"ProductDetialView_style_1" bundle:nil];
    product_vc.productName = self.productName;
    product_vc.products = self.results;
    [[self navigationController] pushViewController:product_vc animated:YES];
}
- (IBAction)declineRequisition:(id)sender {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Requisición"
                                 message:@"¿Desea rechazar esta requisición?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"SI"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                                    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                                    
                                    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                                    self.spinner.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
                                    self.spinner.color = [UIColor lightGrayColor];
                                    self.spinner.center=self.view.center;
                                    [self.view addSubview:self.spinner];
                                    [self.spinner startAnimating];
                                    if (networkStatus == NotReachable) {
                                        [self.spinner stopAnimating];
                                        [self.spinner hidesWhenStopped];
                                        [self requisitionAlert:@"Favor revise su conexión a internet."];
                                    }else{
                                        [self dbDeclineRequisition:^(BOOL finished){
                                            if(finished){
                                                NSLog(@"success");
                                                [self.spinner stopAnimating];
                                                [self.spinner hidesWhenStopped];
                                                [self didDeclineRequisition];
                                            }else{
                                                [self.spinner stopAnimating];
                                                [self.spinner hidesWhenStopped];
                                                [self requisitionAlert:@"Un error ha ocurrido, favor intente nuevamente."];
                                            }
                                        }];
                                    }
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"CANCELAR"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    
    [alert addAction:noButton];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)approveRequisition:(id)sender {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Requisición"
                                 message:@"¿Desea aprobar esta requisición?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"SI"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                                    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                                    
                                    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                                    self.spinner.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
                                    self.spinner.color = [UIColor lightGrayColor];
                                    self.spinner.center=self.view.center;
                                    [self.view addSubview:self.spinner];
                                    [self.spinner startAnimating];
                                    
                                    if (networkStatus == NotReachable) {
                                        [self.spinner stopAnimating];
                                        [self.spinner hidesWhenStopped];
                                        [self requisitionAlert:@"Favor revise su conexión a internet."];
                                    }else{
                                        [self dbApproveRequisition:^(BOOL finished){
                                            if(finished){
                                                NSLog(@"success");
                                                [self.spinner stopAnimating];
                                                [self.spinner hidesWhenStopped];
                                                [self didApproveRequisition];
                                            }else{
                                                [self.spinner stopAnimating];
                                                [self.spinner hidesWhenStopped];
                                                [self requisitionAlert:@"Un error ha ocurrido, favor intente nuevamente."];
                                            }
                                        }];
                                    }
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"CANCELAR"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    
    [alert addAction:noButton];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) didApproveRequisition{
    [self dbTaskNumberByRequisitionId:^(BOOL finished) {
        if(finished){
            [self dbAfterApprove:^(BOOL finished_0){
                if(finished_0){
                    RequisitionApproveViewController *approve_vc = [[RequisitionApproveViewController alloc] initWithNibName:@"RequisitionApproveView_style_1" bundle:nil];
                    [[self navigationController] pushViewController:approve_vc animated:YES];
                }else{
                    [self requisitionAlert:@"Un error ha ocurrido, favor intente nuevamente."];
                }
            }];
        }else{
            [self requisitionAlert:@"Un error ha ocurrido, favor intente nuevamente."];
        }
    }];
    
}

- (void) didDeclineRequisition{
    [self dbTaskNumberByRequisitionId:^(BOOL finished) {
        if(finished){
            [self dbAfterApprove:^(BOOL finished_0){
                if(finished_0){
                    RequisitionDeclineViewController *decline_vc = [[RequisitionDeclineViewController alloc] initWithNibName:@"RequisitionDeclineView_style_1" bundle:nil];
                    [[self navigationController] pushViewController:decline_vc animated:YES];
                }else{
                    [self requisitionAlert:@"Un error ha ocurrido, favor intente nuevamente."];
                }
            }];
        }else{
            [self requisitionAlert:@"Un error ha ocurrido, favor intente nuevamente."];
        }
    }];
}


#pragma mark - Table view data source
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.requisitionDetail count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RequisitionDetailCell *cell = [self.requisitionDetailTableView dequeueReusableCellWithIdentifier:@"RequisitionDetailIdentifier" forIndexPath:indexPath];
    if(!cell){
        cell = [self.requisitionDetailTableView dequeueReusableCellWithIdentifier:@"RequisitionDetailIdentifier" forIndexPath:indexPath];
    }
    NSDictionary *requisitions = [self.requisitionDetail objectAtIndex:indexPath.row];
    cell.providerName.text = requisitions[@"PRODUCTO"];
    cell.quantity.text = [requisitions[@"CANTIDAD"] description];
    cell.single_amount.text = [self formatterAmount:[requisitions[@"PRECIO UNITARIO"] description]];
    cell.total_amount.text = [self formatterAmount:[requisitions[@"TOTAL FINAL"] description]];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *requisitions = [self.requisitionDetail objectAtIndex:indexPath.row];
    self.productName = requisitions[@"PRODUCTO"];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    self.spinner.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    self.spinner.color = [UIColor lightGrayColor];
    self.spinner.center=self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    if (networkStatus == NotReachable) {
        [self.spinner stopAnimating];
        [self.spinner hidesWhenStopped];
        [self requisitionAlert:@"Favor revise su conexión a internet."];
    }else{
        [self dbCallProduct:^(BOOL finished){
            if(finished){
                NSLog(@"success");
                [self.spinner stopAnimating];
                [self.spinner hidesWhenStopped];
                [self didSelectProduct];
            }else{
                NSLog(@"finished");
                [self.spinner stopAnimating];
                [self.spinner hidesWhenStopped];
                [self requisitionAlert:@"Un error ha ocurrido, favor intente nuevamente."];
            }
        }];
    }
    [self.requisitionDetailTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)connect
{
    SQLClient* client = [SQLClient sharedInstance];
    self.view.userInteractionEnabled = NO;
    [client connect:@"200.72.13.150" username:@"sa" password:@"13871388" database:@"Drilprue" completion:^(BOOL success) {
        self.view.userInteractionEnabled = YES;
        if (success) {
            self.connection = YES;
        }else{
            self.connection = NO;
        }
    }];
}

#pragma mark - SQLClientErrorNotification

- (void)error:(NSNotification*)notification
{
    NSNumber* code = notification.userInfo[SQLClientCodeKey];
    NSString* message = notification.userInfo[SQLClientMessageKey];
    NSNumber* severity = notification.userInfo[SQLClientSeverityKey];
    
    NSLog(@"Error #%@: %@ (Severity %@)", code, message, severity);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

#pragma mark - SQLClientMessageNotification

- (void)message:(NSNotification*)notification
{
    NSString* message = notification.userInfo[SQLClientMessageKey];
    NSLog(@"Message: %@", message);
}

#pragma mark - Formatter
- (NSString *)formatterAmount:(NSString *)amount{
    NSNumber *number = @([amount intValue]);
    NSString *str = [NSNumberFormatter localizedStringFromNumber:number numberStyle:NSNumberFormatterCurrencyPluralStyle];
    return [str stringByReplacingOccurrencesOfString:@","
                                          withString:@"."];
}

@end
