//
//  VWWAssetCollectionViewCell.m
//  VWWImgur
//
//  Created by Zakk Hoyt on 10/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWAssetCollectionViewCell.h"

@interface VWWAssetCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *assetImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@end

@implementation VWWAssetCollectionViewCell
-(void)setAssetImage:(UIImage *)assetImage{

    self.assetImageView.image = assetImage;
}
-(void)setSelected:(BOOL)selected{
    super.selected = selected;
    self.selectedImageView.hidden = !selected;
}
@end
