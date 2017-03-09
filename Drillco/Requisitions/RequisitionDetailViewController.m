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

@interface RequisitionDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *requisitionDetailTableView;
@property (weak, nonatomic) IBOutlet UILabel *providerName_lbl;
@property (nonatomic) NSString * productName;
@end

@implementation RequisitionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"Detalle Nº%@",self.requisition_id];
    [self.requisitionDetailTableView registerNib:[UINib nibWithNibName:@"RequisitionDetailCellView_style_1" bundle:nil] forCellReuseIdentifier:@"RequisitionDetailIdentifier"];
    self.requisitionDetailTableView.dataSource = self;
    [self connect];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar.backItem setTitle:@""];
    self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"Detalle Nº%@",self.requisition_id];

    self.providerName_lbl.text = self.provider_name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToSupplier:(id)sender {
    [self execute:[NSString stringWithFormat:@"select top 5 p.ID, p.total_amt_ordered, P.REQUISITION_DATE, v.NAME from PURC_REQUISITION p, VENDOR v where p.vendor_id = v.id and p.status = 'C' and v.NAME = '%@' order by REQUISITION_DATE", self.provider_name] Flow:@"supplier"];
}

- (void) didSelectSupplier{
    SupplierViewController *supplier_vc = [[SupplierViewController alloc] initWithNibName:@"SupplierView_style_1" bundle:nil];
    supplier_vc.supplierName = self.provider_name;
    supplier_vc.supplier_result = self.results[0];
    [[self navigationController] pushViewController:supplier_vc animated:YES];
}

- (void) didSelectProduct{
    ProductDetialViewController *product_vc = [[ProductDetialViewController alloc] initWithNibName:@"ProductDetialView_style_1" bundle:nil];
    product_vc.productName = self.productName;
    product_vc.products = self.results[0];
    [[self navigationController] pushViewController:product_vc animated:YES];
}

#pragma mark - Table view data source
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.requisitionDetail count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RequisitionDetailCell *cell = [self.requisitionDetailTableView dequeueReusableCellWithIdentifier:@"RequisitionDetailIdentifier" forIndexPath:indexPath];
    if(!cell){
        cell = [self.requisitionDetailTableView dequeueReusableCellWithIdentifier:@"RequisitionDetailIdentifier" forIndexPath:indexPath];
    }
    NSDictionary *requisitions = [self.requisitionDetail objectAtIndex:indexPath.row];
    cell.providerName.text = requisitions[@"PRODUCTO"];
    cell.quantity.text = [requisitions[@"CANTIDAD"] description];
    cell.single_amount.text = [requisitions[@"PRECIO UNITARIO"] description];
    cell.total_amount.text = [requisitions[@"TOTAL FINAL"] description];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *requisitions = [self.requisitionDetail objectAtIndex:indexPath.row];
    self.productName = requisitions[@"PRODUCTO"];
    [self execute:[NSString stringWithFormat:@"select top 5 P.ID as [N° REQUISICION], v.NAME as [NOMBRE PROVEEDOR], P.VENDOR_ID as [RUT], P.CURRENCY_ID as [MONEDA], P.DESIRED_RECV_DATE as [FEC DESEADA], pl.UNIT_PRICE as [PRECIO UNIT] from PURC_REQUISITION p, VENDOR v, PURC_REQ_LINE pl, PART pa where p.STATUS = 'C' and p.VENDOR_ID = v.ID and p.ID = pl.PURC_REQ_ID and pa.ID = pl.PART_ID and pa.DESCRIPTION = '%@' order by p.desired_recv_date desc,p.id,pl.LINE_NO", self.productName] Flow:@"product"];
    [self.requisitionDetailTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)connect
{
    SQLClient* client = [SQLClient sharedInstance];
    self.view.userInteractionEnabled = NO;
    [client connect:@"200.72.13.150" username:@"sa" password:@"13871388" database:@"Drillco" completion:^(BOOL success) {
        self.view.userInteractionEnabled = YES;
        if (success) {
            //			[self execute];
        }
    }];
}

- (void)execute:(NSString*)sql Flow:(NSString*)flow
{
    if (![SQLClient sharedInstance].isConnected) {
        [self connect];
        return;
    }
    
    self.view.userInteractionEnabled = NO;
    [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
        self.view.userInteractionEnabled = YES;
        self.results = results;
        if([flow isEqualToString:@"supplier"]){
            [self didSelectSupplier];
        }else{
            [self didSelectProduct];
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

@end
