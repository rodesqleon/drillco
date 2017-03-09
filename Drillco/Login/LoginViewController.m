//
//  LoginViewController.m
//  Drillco
//
//  Created by Rodrigo Esquivel on 06-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@end
NSString * const host = @"200.72.13.150";
NSString * const user = @"sa";
NSString * const pass = @"13871388";
NSString * const db = @"Drillprus";

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self connect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.translucent = NO;

}

- (IBAction)doLogin:(id)sender {
    //if(self.username_txt.text.length > 0 && self.password_txt.text.length > 0){
        [self execute:[@"SELECT * FROM DRILL_MAE_USUARIO_MOVIL WHERE id='" stringByAppendingString:[NSString stringWithFormat:@"%@' AND password='%@'", self.username_txt.text, self.password_txt.text]] Flow:@"login"];
    //}else{
        //ALERT
    //}
}

- (void)didLogin:(NSArray *)results{
    if([results count] > 0){
        if([results[0] count] > 0){
            [self execute:[NSString stringWithFormat:@"select P.ID, v.NAME, P.VENDOR_ID, pr.CURRENCY_ID, P.DESIRED_RECV_DATE, PR.AMOUNT from PURC_REQUISITION p, VENDOR v, PURC_REQ_CURR pr where pr.currency_id = P.CURRENCY_ID and p.ASSIGNED_TO = 'HSEBASTI' and p.STATUS = 'I' and p.VENDOR_ID = v.ID and p.ID = pr.PURC_REQ_ID order by P.REQUISITION_DATE"] Flow:@"requisitionlist"];
        }else{
            NSLog(@"Usuario inválido");
        }
    }else{
        NSLog(@"Usuario inválido");
    }
}

- (void)didRequisitionList:(NSArray *)results{
    self.requisitionList_vc = [[RequisitionTableViewController alloc] initWithNibName:@"RequisitionListView_style_1" bundle:nil];
    self.requisitionList_vc.username = self.username_txt.text;
    self.requisitionList_vc.requisition = results[0];
    [[self navigationController] pushViewController:self.requisitionList_vc animated:YES];
}

- (IBAction)goToAdminLogin:(id)sender {
    self.loginAdmin_vc = [[LoginAdminViewController alloc] initWithNibName:@"LoginAdminView_style_1"bundle:nil];
    [[self navigationController] pushViewController:self.loginAdmin_vc animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //hides keyboard when another part of layout was touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
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
        if([flow isEqualToString:@"login"]){
            [self didLogin:self.results];
        }else{
            [self didRequisitionList:self.results];
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
