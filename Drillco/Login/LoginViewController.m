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
NSString * const db = @"Drilprue";

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    if(self.username_txt.text.length > 0 && self.password_txt.text.length > 0){
        NSString *query = [@"SELECT * FROM DRILL_MAE_USUARIO_MOVIL WHERE id='" stringByAppendingString:[NSString stringWithFormat:@"%@' AND password='%@'", self.username_txt.text, self.password_txt.text]];
        SQLClient* client = [SQLClient sharedInstance];
        client.delegate = self;
        [client connect:host username:user password:pass database:db completion:^(BOOL success) {
            if (success)
            {
                [client execute:query completion:^(NSArray* results) {
                [self didLogin:results];
                [client disconnect];
                }];
            }
            else{
                NSLog(@"An error ocurr");
            }
        }];
    }else{
        //ALERT
    }
}

- (void)didLogin:(NSArray *)results{
    if([results count] > 0){
        if([results[0] count] > 0){
            [self goToRequisitionList];
        }else{
            NSLog(@"Usuario inválido");
        }
    }else{
        NSLog(@"Usuario inválido");
    }
}
- (IBAction)goToAdminLogin:(id)sender {
    self.loginAdmin_vc = [[LoginAdminViewController alloc] initWithNibName:@"LoginAdminView_style_1"bundle:nil];
    [[self navigationController] pushViewController:self.loginAdmin_vc animated:YES];
}

- (void)goToRequisitionList{
    NSString *query = [NSString stringWithFormat:@"select P.ID, v.NAME, P.VENDOR_ID, pr.CURRENCY_ID, P.DESIRED_RECV_DATE, PR.AMOUNT from PURC_REQUISITION p, VENDOR v, PURC_REQ_CURR pr where pr.currency_id = P.CURRENCY_ID and p.ASSIGNED_TO = 'FPADILLA' and p.STATUS = 'I' and p.VENDOR_ID = v.ID and p.ID = pr.PURC_REQ_ID order by P.REQUISITION_DATE"];
    SQLClient* client = [SQLClient sharedInstance];
    client.delegate = self;
    [client connect:host username:user password:pass database:db completion:^(BOOL success) {
        if (success)
        {
            [client execute:query completion:^(NSArray* results) {
                self.requisitionList_vc = [[RequisitionTableViewController alloc] initWithNibName:@"RequisitionListView_style_1" bundle:nil];
                self.requisitionList_vc.username = self.username_txt.text;
                self.requisitionList_vc.requisition = results[0];
                [[self navigationController] pushViewController:self.requisitionList_vc animated:YES];
                [client disconnect];
                
            }];
        }
        else{
            NSLog(@"An error ocurr");
        }
    }];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //hides keyboard when another part of layout was touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - SQLClientDelegate

//Required
- (void)error:(NSString*)error code:(int)code severity:(int)severity
{
    /*NSLog(@"Error #%d: %@ (Severity %d)", code, error, severity);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];*/
}

//Optional
- (void)message:(NSString*)message
{
    NSLog(@"Message: %@", message);
}


@end
