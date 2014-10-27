//
//  VWWAssetsCollectionViewController.h
//  VWWImgur
//
//  Created by Zakk Hoyt on 10/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VWWPhotosController.h"
#import "VWWSelectedAssets.h"

@interface VWWAssetsCollectionViewController : UICollectionViewController
@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) VWWSelectedAssets *selectedAssets;
@end
