//
//  VWWCollectionTableViewCell.h
//  VWWImgur
//
//  Created by Zakk Hoyt on 10/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VWWCollectionTableViewCell : UITableViewCell
@property (nonatomic, strong) UIImage *assetImage;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;

@end
