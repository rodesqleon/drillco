//
//  ProductDetialViewController.h
//  Drillco
//
//  Created by rodrigoe on 09-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetialViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) NSString * productName;
@property (nonatomic) NSArray * products;
@end
