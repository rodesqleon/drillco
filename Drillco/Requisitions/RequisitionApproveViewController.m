//
//  RequisitionApproveViewController.m
//  Drillco
//
//  Created by Rodrigo Esquivel on 11-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import "RequisitionApproveViewController.h"

@interface RequisitionApproveViewController ()

@end

@implementation RequisitionApproveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Estado";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Req."
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(handleBack:)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar.backItem setTitle:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleBack:(id)sender {
    int viewsToPop = 2;
    [self.navigationController popToViewController: self.navigationController.viewControllers[self.navigationController.viewControllers.count-viewsToPop-1] animated:YES];

}

@end
