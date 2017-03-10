//
//  LoginAdminViewController.m
//  Drillco
//
//  Created by Rodrigo Esquivel on 06-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import "LoginAdminViewController.h"

@interface LoginAdminViewController ()
@end

@implementation LoginAdminViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    // Navigation bar setup
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar.backItem setTitle:@""];
    // Assign textfield delegate
    self.username_txt.delegate = self;
    self.password_txt.delegate = self;
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
}

- (IBAction)doLogin:(id)sender {
    [self execute:[@"select u.USER_ID, d.PASSWORD from DRILL_MAE_USUARIO_MOVIL d, GROUP_USER u where u.USER_ID='" stringByAppendingString:[NSString stringWithFormat:@"%@' AND d.PASSWORD='%@'", self.username_txt.text, self.password_txt.text]] Flow:@"login"];

}

- (void)didLogin:(NSArray *)results{
    if([results count] > 0){
        if([results[0] count] > 0){
            [self execute:[NSString stringWithFormat:@"select P.ID, v.NAME, P.VENDOR_ID, pr.CURRENCY_ID, P.DESIRED_RECV_DATE, PR.AMOUNT from PURC_REQUISITION p, VENDOR v, PURC_REQ_CURR pr where pr.currency_id = P.CURRENCY_ID and p.ASSIGNED_TO = '%@' and p.STATUS = 'I' and p.VENDOR_ID = v.ID and p.ID = pr.PURC_REQ_ID order by P.REQUISITION_DATE", self.username_txt.text] Flow:@"requisitionlist"];
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



- (void)connect
{
    SQLClient* client = [SQLClient sharedInstance];
    self.view.userInteractionEnabled = NO;
    [client connect:@"200.72.13.150" username:@"sa" password:@"13871388" database:@"Drillcoprue" completion:^(BOOL success) {
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
