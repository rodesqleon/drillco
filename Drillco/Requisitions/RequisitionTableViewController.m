//
//  RequisitionTableViewController.m
//  Drillco
//
//  Created by rodrigoe on 08-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import "RequisitionTableViewController.h"
#import "RequisitionCell.h"
#import "Reachability.h"

typedef void(^myCompletion) (BOOL);

@interface RequisitionTableViewController ()
@property (weak, nonatomic) IBOutlet UITableView *requisitionTableView;
@property (weak, nonatomic) IBOutlet UILabel *username_lbl;
@property (nonatomic) UIActivityIndicatorView *spinner;
@property (nonatomic) UIRefreshControl *refreshControl;

@end

@implementation RequisitionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Req." style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.requisitionTableView registerNib:[UINib nibWithNibName:@"RequisitionCellView_style_1" bundle:nil] forCellReuseIdentifier:@"RequisitionIdentifier"];
    self.requisitionTableView.dataSource = self;
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(goForRequisitions)
                  forControlEvents:UIControlEventValueChanged];
    [self.requisitionTableView addSubview:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"Requisiciones";
    self.username_lbl.text = self.username;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    self.spinner.color = [UIColor lightGrayColor];
    self.spinner.center=self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    [self goForRequisitions];
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

- (void) goForRequisitions{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [self.spinner stopAnimating];
        [self.spinner hidesWhenStopped];
        [self requisitionAlert:@"Favor revise su conexión a internet."];
    }else{
        
        [self dbCallRequisition:^(BOOL finished){
            if(finished){
                NSLog(@"success");
                [self dbCallRequisitionType:^(BOOL finished){
                    if(finished){
                        NSLog(@"success");
                        [self dbCallRequisitionLimit:^(BOOL finished) {
                            if(finished){
                                [self.spinner stopAnimating];
                                [self.spinner hidesWhenStopped];
                                [self reloadData];
                            }else{
                                [self.spinner stopAnimating];
                                [self.spinner hidesWhenStopped];
                                [self requisitionAlert:@"Un error ha ocurrido, favor tire hacía abajo para refrescar."];
                            }
                        }];
                    }else{
                        NSLog(@"finished");
                        [self.spinner stopAnimating];
                        [self.spinner hidesWhenStopped];
                        [self requisitionAlert:@"Un error ha ocurrido, favor tire hacía abajo para refrescar."];
                    }
                }];
            }else{
                NSLog(@"finished");
                [self.spinner stopAnimating];
                [self.spinner hidesWhenStopped];
                [self requisitionAlert:@"Un error ha ocurrido, favor tire hacía abajo para refrescar."];
            }
        }];
    }
    [self.refreshControl endRefreshing];
}

- (void) reloadData {
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Última actualización: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }

    
    if([self.requisition count] > 0){
        self.requisitionTableView.backgroundView = nil;
        self.requisitionTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }else{
        [self.spinner stopAnimating];
        [self.spinner hidesWhenStopped];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = @"No existen requisiciones pendientes.";
        messageLabel.textColor = [UIColor grayColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Helvética Neue" size:20];
        [messageLabel sizeToFit];
        
        self.requisitionTableView.backgroundView = messageLabel;
        self.requisitionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    [self.requisitionTableView reloadData];
    
}

- (void) dbCallRequisitionDetialId:(NSString *) requisitionId Block:(myCompletion) dbBlock {
    [self connect];
    NSString * sql = [NSString stringWithFormat:@"select pl.LINE_NO as [LINEA], pl.PART_ID as [CODIGO PRODUCTO], (case isnull(p.description,'') when '' then CONVERT(VARCHAR(200),CONVERT(VARBINARY(200),pb.bits)) else p.DESCRIPTION end) as [PRODUCTO], pl.ORDER_QTY as [CANTIDAD], pl.UNIT_PRICE as [PRECIO UNITARIO], pl.ORDER_QTY * pl.UNIT_PRICE as [TOTAL FINAL] from PURC_REQ_LINE pl,PURC_REQ_LN_BINARY pb, PART p where pl.PURC_REQ_ID = '%@' and pl.PURC_REQ_ID *= pb.PURC_REQ_ID and pl.LINE_NO *= pb.PURC_REQ_LINE_NO and pl.PART_ID *= p.id order by pl.line_no", requisitionId];
    [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
        if (results) {
            self.requisition_detail = results;
            [[SQLClient sharedInstance] disconnect];
            if(self.requisition){
                dbBlock(YES);
            }
            
        }
    }];
    
}

- (void) dbCallRequisition:(myCompletion) dbBlock{
    [self connect];
    NSString * sql = [NSString stringWithFormat:@"select P.ID, v.NAME, P.VENDOR_ID, pr.CURRENCY_ID, P.DESIRED_RECV_DATE, PR.AMOUNT from PURC_REQUISITION p, VENDOR v, PURC_REQ_CURR pr where pr.currency_id = P.CURRENCY_ID and p.ASSIGNED_TO = '%@' and p.STATUS = 'I' and p.VENDOR_ID = v.ID and p.ID = pr.PURC_REQ_ID order by P.REQUISITION_DATE", self.username];
    [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
        if (results) {
            self.requisition = results[0];
            [[SQLClient sharedInstance] disconnect];
            if(self.requisition){
                dbBlock(YES);
            }
        }
    }];
}

- (void) dbCallRequisitionType:(myCompletion) dbBlock{
    [self connect];
    NSString * sql = [NSString stringWithFormat:@"SELECT (CASE GROUP_ID WHEN 'APRO1' THEN 'A1' WHEN 'APRO2' THEN 'A2' END) as TYPE FROM GROUP_USER WHERE USER_ID = '%@'", self.username];
    [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
        if (results) {
            NSDictionary *type = [results[0] objectAtIndex:0];
            self.requisition_type = type[@"TYPE"];
            [[SQLClient sharedInstance] disconnect];
            if(self.requisition_type){
                dbBlock(YES);
            }
            
        }
    }];
}

- (void) dbCallRequisitionLimit:(myCompletion) dbBlock{
    [self connect];
    NSString * sql = [NSString stringWithFormat:@"select CAST(REPLACE(PROFILE_STRING,'Limit=','') AS numeric) AS LIMIT from USER_PGM_AUTHORITY where USER_ID = '%@' AND PROFILE_STRING is not null and PROGRAM_ID = 'VMREQENT'", self.username];
    [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
        if (results) {
            NSDictionary *dict = [results[0] objectAtIndex:0];
            self.requisition_limit = dict[@"LIMIT"];
            [[SQLClient sharedInstance] disconnect];
            if(self.requisition_type){
                dbBlock(YES);
            }
            
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) checkRequisitonByLimit{
    if(self.requisition_limit){
        NSMutableArray *filter_requisiton = [NSMutableArray new];
        for(int i = 0 ; i < [self.requisition count] ; i++){
            NSDictionary * dict  = [self.requisition objectAtIndex:i];
            if([dict[@"AMOUNT"] floatValue] <= [self.requisition_limit floatValue]){
                [filter_requisiton addObject:self.requisition[i]];
            }
        }
        self.requisition = filter_requisiton;
        return [self.requisition count];
    }else{
        return [self.requisition count];
    }
}

#pragma mark - Table view data source
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self checkRequisitonByLimit];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RequisitionCell *cell = [self.requisitionTableView dequeueReusableCellWithIdentifier:@"RequisitionIdentifier" forIndexPath:indexPath];
    if(!cell){
        cell = [self.requisitionTableView dequeueReusableCellWithIdentifier:@"RequisitionIdentifier" forIndexPath:indexPath];
    }
    NSDictionary *requisitions = [self.requisition objectAtIndex:indexPath.row];
    cell.requisition_ID.text = requisitions[@"ID"];
    cell.requisition_VENDOR_ID.text = requisitions[@"VENDOR_ID"];
    cell.requisition_CURRENCY_ID.text = [requisitions[@"CURRENCY_ID"] stringByAppendingString:[NSString stringWithFormat:@" %@",[self formatterAmount:requisitions[@"AMOUNT"]]]];
   
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"dd/MM/yyyy"]; // Date formater
    NSString *date = [dateformate stringFromDate:requisitions[@"DESIRED_RECV_DATE"]];
    
    cell.requisition_DESIRED_RECV_DATE.text = date;
    cell.requisition_NAME.text = [[requisitions[@"NAME"] description] uppercaseString];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *requisitions = [self.requisition objectAtIndex:indexPath.row];
    self.info = requisitions;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    self.spinner.color = [UIColor lightGrayColor];
    self.spinner.center=self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    [self dbCallRequisitionDetialId:self.info[@"ID"] Block:^(BOOL finished){
        if(finished){
            NSLog(@"success");
            [self.spinner stopAnimating];
            [self.spinner hidesWhenStopped];
            [self didRequisitionDetail];
        }else{
            NSLog(@"finished");
            [self.spinner stopAnimating];
            [self.spinner hidesWhenStopped];
            [self requisitionAlert:@"Un error ha ocurrido, intente nuevamente."];
        }
    }];
    [self.requisitionTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) didRequisitionDetail{
    self.requisitionDetail_vc = [[RequisitionDetailViewController alloc] initWithNibName:@"RequisitionDetailView_style_1" bundle:nil];
    self.requisitionDetail_vc.requisitionDetail = self.requisition_detail[0];
    self.requisitionDetail_vc.provider_name = self.info[@"NAME"];
    self.requisitionDetail_vc.requisition_id = self.info[@"ID"];
    self.requisitionDetail_vc.requisition_type = self.requisition_type;
    self.requisitionDetail_vc.username = self.username;
    [[self navigationController] pushViewController:self.requisitionDetail_vc animated:YES];
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
#pragma mark - Formatter
- (NSString *)formatterAmount:(NSString *)amount{
    NSNumber *number = @([amount intValue]);
    NSString *str = [NSNumberFormatter localizedStringFromNumber:number numberStyle:NSNumberFormatterCurrencyPluralStyle];
    return [str stringByReplacingOccurrencesOfString:@","
                                          withString:@"."];
}



@end
