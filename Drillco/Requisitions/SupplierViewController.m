//
//  SupplierViewController.m
//  Drillco
//
//  Created by rodrigoe on 08-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import "SupplierViewController.h"
#import "SupplierCell.h"
#import "ProductMoreDetailViewController.h"
#import "Reachability.h"

typedef void(^myCompletion) (BOOL);

@interface SupplierViewController ()
@property (weak, nonatomic) IBOutlet UITableView *supplierDetailTableView;
@property (nonatomic) UIActivityIndicatorView *spinner;


@end

@implementation SupplierViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Proveedor";
    [self.supplierDetailTableView registerNib:[UINib nibWithNibName:@"SupplierViewCell_style_1" bundle:nil] forCellReuseIdentifier:@"SupplierIdentifier"];
    self.supplierDetailTableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.supplierName_lbl.text = self.supplierName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) dbCallProductDetailId:(NSString *) requisitionId Block:(myCompletion) dbBlock {
    [self connect];
    NSString * sql = [NSString stringWithFormat:@"select pl.LINE_NO as [LINEA], pl.PART_ID as [CODIGO PRODUCTO], (case isnull(p.description,'') when '' then CONVERT(VARCHAR(200),CONVERT(VARBINARY(200),pb.bits)) else p.DESCRIPTION end) as [PRODUCTO], pl.ORDER_QTY as [CANTIDAD], pl.UNIT_PRICE as [PRECIO UNITARIO], pl.ORDER_QTY * pl.UNIT_PRICE as [TOTAL FINAL] from PURC_REQ_LINE pl,PURC_REQ_LN_BINARY pb, PART p where pl.PURC_REQ_ID = '%@' and pl.PURC_REQ_ID *= pb.PURC_REQ_ID and pl.LINE_NO *= pb.PURC_REQ_LINE_NO and pl.PART_ID *= p.id order by pl.line_no", requisitionId];
    [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
        if (results) {
            self.results = results;
            [[SQLClient sharedInstance] disconnect];
            if(self.results){
                dbBlock(YES);
            }
            
        }
    }];
    
}

- (void)connect
{
    SQLClient* client = [SQLClient sharedInstance];
    self.view.userInteractionEnabled = NO;
    [client connect:@"200.72.13.150" username:@"sa" password:@"13871388" database:@"Drilprue" completion:^(BOOL success) {
        self.view.userInteractionEnabled = YES;
        if (success) {
            //			[self execute];
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


#pragma mark - Table view data source
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.supplier_result count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SupplierCell *cell = [self.supplierDetailTableView dequeueReusableCellWithIdentifier:@"SupplierIdentifier" forIndexPath:indexPath];
    if(!cell){
        cell = [self.supplierDetailTableView dequeueReusableCellWithIdentifier:@"SupplierIdentifier" forIndexPath:indexPath];
    }
    NSDictionary *supplier = [self.supplier_result objectAtIndex:indexPath.row];
    NSLog(@"%@", supplier);
    
    cell.requisitionNumber.text = [supplier[@"ID"] description];
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"dd/MM/yyyy"]; // Date formater
    NSString *date = [dateformate stringFromDate:supplier[@"REQUISITION_DATE"]];
    cell.requisitionDate.text = date;
    cell.requisitionTotal.text = [self formatterAmount:[supplier[@"total_amt_ordered"] description]];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *product = [self.supplier_result objectAtIndex:indexPath.row];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    self.spinner.color = [UIColor lightGrayColor];
    self.spinner.center=self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        [self.spinner stopAnimating];
        [self.spinner hidesWhenStopped];
        [self requisitionAlert:@"Favor revise su conexión a internet."];
    }else{
        [self dbCallProductDetailId:product[@"ID"] Block:^(BOOL finished){
            if(finished){
                NSLog(@"success");
                [self.spinner stopAnimating];
                [self.spinner hidesWhenStopped];
                [self didProductDetail];
            }else{
                NSLog(@"finished");
                [self.spinner stopAnimating];
                [self.spinner hidesWhenStopped];
                [self requisitionAlert:@"Un error ha ocurrido, intente nuevamente."];
            }
        }];
    }
    [self.supplierDetailTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) requisitionAlert:(NSString *) text{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Requisiciones"
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

- (void) didProductDetail{
    ProductMoreDetailViewController *productDetail_vc = [[ProductMoreDetailViewController alloc] initWithNibName:@"ProductMoreDetailView_style_1" bundle:nil];
    productDetail_vc.results = self.results[0];
    [[self navigationController] pushViewController:productDetail_vc animated:YES];

}

#pragma mark - Formatter
- (NSString *)formatterAmount:(NSString *)amount{
    NSNumber *number = @([amount intValue]);
    NSString *str = [NSNumberFormatter localizedStringFromNumber:number numberStyle:NSNumberFormatterCurrencyPluralStyle];
    return [str stringByReplacingOccurrencesOfString:@","
                                          withString:@"."];
}
@end
