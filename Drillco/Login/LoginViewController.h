//
//  LoginViewController.h
//  Drillco
//
//  Created by Rodrigo Esquivel on 06-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLClient.h"
#import "LoginAdminViewController.h"
#import "RequisitionListViewController.h"


@interface LoginViewController : UIViewController <SQLClientDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username_txt;
@property (weak, nonatomic) IBOutlet UITextField *password_txt;
@property (nonatomic) LoginAdminViewController *loginAdmin_vc;
@property (nonatomic) RequisitionListViewController *requisitionList_vc;

@end
