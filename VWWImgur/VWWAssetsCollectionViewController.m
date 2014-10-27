//
//  VWWAssetsCollectionViewController.m
//  VWWImgur
//
//  Created by Zakk Hoyt on 10/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWAssetsCollectionViewController.h"
#import "VWWAssetCollectionViewCell.h"


@interface VWWAssetsCollectionViewController ()
@property (nonatomic) CGSize assetThumbnailSize;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) NSMutableArray *cachingIndexes;
@property (nonatomic) CGFloat lastCacheFrameCenter;
@end

@implementation VWWAssetsCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.allowsMultipleSelection = YES;

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    // Calculate Thumbnail Size
//    let scale = UIScreen.mainScreen().scale
//    let cellSize = (collectionViewLayout as UICollectionViewFlowLayout).itemSize
//    assetThumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
//    
//    collectionView!.reloadData()
//    updateSelectedItems()
//    resetCache()
//    CGFloat scale = [UIScreen mainScreen].scale;
    self.assetThumbnailSize = CGSizeMake(self.view.bounds.size.width / 3.0, self.view.bounds.size.width / 3.0);
    
    self.imageManager = [[PHCachingImageManager alloc]init];
    

    [self.collectionView reloadData];
    [self updateSelectedItems];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark Private methods

-(PHAsset*)currentAssetAtIndexPath:(NSIndexPath*)indexPath{
    if(self.assetsFetchResults){
        return self.assetsFetchResults[indexPath.item];
    } else {
        return self.selectedAssets.assets[indexPath.item];
    }
    return nil;
}
-(void)updateSelectedItems{
    if(self.assetsFetchResults){
        for(PHAsset *asset in self.selectedAssets.assets){
            NSUInteger index = [self.assetsFetchResults indexOfObject:asset];
            if(index != NSNotFound){
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }
        }
    } else {
        for(NSUInteger index = 0; index < self.selectedAssets.assets.count; index++){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
}
#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(self.assetsFetchResults){
        return self.assetsFetchResults.count;
    } else {
        return self.selectedAssets.assets.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VWWAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VWWAssetCollectionViewCell" forIndexPath:indexPath];
  
    PHAsset *asset = [self currentAssetAtIndexPath:indexPath];

    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.networkAccessAllowed = YES;
    [self.imageManager requestImageForAsset:asset targetSize:self.assetThumbnailSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        cell.assetImage = result;
    }];

    return cell;
}

#pragma mark UICollectionViewFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.assetThumbnailSize;
}

#pragma mark UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *asset = [self currentAssetAtIndexPath:indexPath];
    [self.selectedAssets.assets addObject:asset];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *asset = [self currentAssetAtIndexPath:indexPath];
    [self.selectedAssets.assets removeObject:asset];
    if(self.assetsFetchResults == nil){
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
}

@end
