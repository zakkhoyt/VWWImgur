//
//  VWWCollectionTableViewCell.m
//  VWWImgur
//
//  Created by Zakk Hoyt on 10/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWCollectionTableViewCell.h"

@interface VWWCollectionTableViewCell ()
@property (nonatomic, weak) IBOutlet UIImageView *assetImageView;
@end

@implementation VWWCollectionTableViewCell

-(void)layoutSubviews{
    [super layoutSubviews];
    self.groupLabel.layer.cornerRadius = 4.0;
    self.groupLabel.layer.masksToBounds = YES;

    self.countLabel.layer.cornerRadius = 4.0;
    self.countLabel.layer.masksToBounds = YES;
}
-(void)setAssetImage:(UIImage *)assetImage{
    self.assetImageView.image = assetImage;
    
}
@end
