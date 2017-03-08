//
//  RequisitionListViewController.h
//  Drillco
//
//  Created by Rodrigo Esquivel on 07-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLClient.h"
@interface RequisitionListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SQLClientDelegate>
@property (weak, nonatomic) IBOutlet UITableView *requisition_tableview;
@property (nonatomic) NSString * username;

@end
