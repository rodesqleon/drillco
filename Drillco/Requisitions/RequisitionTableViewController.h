//
//  RequisitionTableViewController.h
//  Drillco
//
//  Created by rodrigoe on 08-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLClient.h"
#import "RequisitionDetailViewController.h"


@interface RequisitionTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSString * username;
@property (nonatomic) NSString * requisition_id;
@property (strong, nonatomic) NSArray * requisition;
@property (strong, nonatomic) NSArray * requisition_detail;
@property (nonatomic) NSDictionary * info;
@property (nonatomic) RequisitionDetailViewController * requisitionDetail_vc;
@property (nonatomic) NSString *requisition_type;
@property (nonatomic) NSString *requisition_limit;
@end
