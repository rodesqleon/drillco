//
//  RequisitionTableViewController.h
//  Drillco
//
//  Created by rodrigoe on 08-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLClient.h"

@interface RequisitionTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SQLClientDelegate>
@property (nonatomic) NSString * username;
@property (nonatomic) NSArray * requisition;
@end
