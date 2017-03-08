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

NSString * const khost = @"200.72.13.150";
NSString * const kuser = @"sa";
NSString * const kpass = @"13871388";
NSString * const kdb = @"Drilprue";

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
    if(self.username_txt.text.length > 0 && self.password_txt.text.length > 0){
        NSString *query = [@"SELECT * FROM DRILL_MAE_USUARIO_MOVIL WHERE id='" stringByAppendingString:[NSString stringWithFormat:@"%@' AND password='%@'", self.username_txt.text, self.password_txt.text]];
        SQLClient* client = [SQLClient sharedInstance];
        client.delegate = self;
        [client connect:khost username:kuser password:kpass database:kdb completion:^(BOOL success) {
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
            NSLog(@"Usuario válido");
        }else{
            NSLog(@"Usuario inválido");
        }
    }else{
        NSLog(@"Usuario inválido");
    }
}

#pragma mark - SQLClientDelegate

//Required
- (void)error:(NSString*)error code:(int)code severity:(int)severity
{
    NSLog(@"Error #%d: %@ (Severity %d)", code, error, severity);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

//Optional
- (void)message:(NSString*)message
{
    NSLog(@"Message: %@", message);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //hides keyboard when another part of layout was touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
