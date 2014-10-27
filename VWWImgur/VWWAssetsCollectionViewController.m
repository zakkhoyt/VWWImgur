//
//  VWWAssetsCollectionViewController.m
//  VWWImgur
//
//  Created by Zakk Hoyt on 10/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWAssetsCollectionViewController.h"
#import "VWWAssetCollectionViewCell.h"
#import "AppDelegate.h"

@interface VWWAssetsCollectionViewController ()
@property (nonatomic) CGSize assetThumbnailSize;

@property (nonatomic, strong) NSMutableArray *cachingIndexes;
@property (nonatomic) CGFloat lastCacheFrameCenter;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *startButton;
@end

@implementation VWWAssetsCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.allowsMultipleSelection = YES;
    self.title = @"Upload Queue";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    if(self.selectedAssets.assets.count && self.assetsFetchResults == nil){
        self.navigationItem.rightBarButtonItem = self.startButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    
    self.assetThumbnailSize = CGSizeMake(self.view.bounds.size.width / 3.0, self.view.bounds.size.width / 3.0);
    

    

    [self.collectionView reloadData];
    [self.collectionView performBatchUpdates:^{
        
    } completion:^(BOOL finished) {
        if(self.assetsFetchResults){
            if(self.assetsFetchResults.count){
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.assetsFetchResults.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            }
        } else {
            if(self.selectedAssets.assets.count){
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedAssets.assets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            }
        }
        [self updateSelectedItems];
    }];
    
    
    

}

-(BOOL)prefersStatusBarHidden{
    return NO;
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
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    VWWPhotosController *photosController = appDelegate.photosController;
    [photosController.imageManager requestImageForAsset:asset targetSize:self.assetThumbnailSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
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
