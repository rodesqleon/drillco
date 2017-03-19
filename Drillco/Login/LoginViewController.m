//
//  LoginViewController.m
//  Drillco
//
//  Created by Rodrigo Esquivel on 06-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import "LoginViewController.h"
#import "Reachability.h"


typedef void(^myCompletion) (BOOL);

@interface LoginViewController ()
@property (nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Salir" style:UIBarButtonItemStylePlain target:nil action:nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar.backItem setTitle:@""];
    
}



- (void) dbCallLogin:(myCompletion) dbBlock{
    [self connect];
    NSString * sql = [@"select u.USER_ID, d.PASSWORD from DRILL_MAE_USUARIO_MOVIL d, GROUP_USER u where u.USER_ID='" stringByAppendingString:[NSString stringWithFormat:@"%@' AND d.PASSWORD='%@'", self.username_txt.text, self.password_txt.text]];
    [[SQLClient sharedInstance] execute:sql completion:^(NSArray* results) {
        if (results) {
            self.results = results;
            [[SQLClient sharedInstance] disconnect];
            if(self.results){
                dbBlock(YES);
            }
            
        }else{
            dbBlock(NO);
        }
    }];
    
}

- (void) dbCallRequisition:(myCompletion) dbBlock{
    [self connect];
    NSString * sql = [NSString stringWithFormat:@"select P.ID, v.NAME, P.VENDOR_ID, pr.CURRENCY_ID, P.DESIRED_RECV_DATE, PR.AMOUNT from PURC_REQUISITION p, VENDOR v, PURC_REQ_CURR pr where pr.currency_id = P.CURRENCY_ID and p.ASSIGNED_TO = '%@' and p.STATUS = 'I' and p.VENDOR_ID = v.ID and p.ID = pr.PURC_REQ_ID order by P.REQUISITION_DATE", self.username_txt.text];
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

- (void) dbCallRequisitionType:(myCompletion) dbBlock{
    [self connect];
    NSString * sql = [NSString stringWithFormat:@"SELECT (CASE GROUP_ID WHEN 'APRO1' THEN 'A1' WHEN 'APRO2' THEN 'A2' END) as TYPE FROM GROUP_USER WHERE USER_ID = '%@'", self.username_txt.text];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)doLogin:(id)sender {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
 
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
    self.spinner.color = [UIColor lightGrayColor];
    self.spinner.center=self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    self.view.userInteractionEnabled = NO;
    if (networkStatus == NotReachable) {
        self.view.userInteractionEnabled = YES;
        [self.spinner stopAnimating];
        [self.spinner hidesWhenStopped];
        [self loginAlertWithString:@"Favor revise su conexión a internet."];
    } else {
        [self dbCallLogin:^(BOOL finished){
            if(finished){
                NSLog(@"success");
                [self didLogin:self.results];
            }else{
                NSLog(@"finished");
                self.view.userInteractionEnabled = YES;
                [self.spinner stopAnimating];
                [self.spinner hidesWhenStopped];
                [self loginAlertWithString:@"Error inicio de sesión, favor intente nuevamente."];
            }
        }];
    }
    
}

- (void)didLogin:(NSArray *)results{
    
    if([results count] > 0){
        if([results[0] count] > 0){
            [self dbCallRequisition:^(BOOL finished){
                if(finished){
                    NSLog(@"success");
                    self.view.userInteractionEnabled = YES;
                    [self dbCallRequisitionType:^(BOOL finished){
                        if(finished){
                            NSLog(@"success");
                            [self.spinner stopAnimating];
                            [self.spinner hidesWhenStopped];
                            self.view.userInteractionEnabled = YES;
                            
                            [self didRequisitionList:self.results];
                            
                        }else{
                            NSLog(@"finished");
                            [self.spinner stopAnimating];
                            [self.spinner hidesWhenStopped];
                        }
                    }];
                    
                }else{
                    NSLog(@"finished");
                    [self.spinner stopAnimating];
                    [self.spinner hidesWhenStopped];
                }
            }];
        }else{
            [self.spinner stopAnimating];
            [self.spinner hidesWhenStopped ];
            self.view.userInteractionEnabled = YES;
            [self loginAlertWithString:@"Usuario y/o contraseña incorrectas."];
        }
    }else{
        [self.spinner stopAnimating];
        [self.spinner hidesWhenStopped ];
        self.view.userInteractionEnabled = YES;
        [self loginAlertWithString:@"Usuario y/o contraseña incorrectas."];
    }
}

- (void) loginAlertWithString:(NSString *) text{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Inicio de sesión"
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

- (void)didRequisitionList:(NSArray *)results{
    self.requisitionList_vc = [[RequisitionTableViewController alloc] initWithNibName:@"RequisitionListView_style_1" bundle:nil];
    self.requisitionList_vc.username = self.username_txt.text;
    self.requisitionList_vc.requisition = results[0];
    self.requisitionList_vc.requisition_type = self.requisition_type;
    self.username_txt.text = @"";
    self.password_txt.text = @"";
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
    [client connect:@"200.72.13.150" username:@"sa" password:@"13871388" database:@"Drilprue" completion:^(BOOL success) {
        self.view.userInteractionEnabled = YES;
        if (success) {
            
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
