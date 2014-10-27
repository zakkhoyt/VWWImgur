//
//  VWWCollectionsViewController.m
//  VWWImgur
//
//  Created by Zakk Hoyt on 10/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWCollectionsViewController.h"
#import "AppDelegate.h"
#import "VWWSelectedAssets.h"
#import "VWWAssetsCollectionViewController.h"
#import "VWWCollectionTableViewCell.h"

static NSString *VWWSegueCollectionsToSelect = @"VWWSegueCollectionsToSelect";

@interface VWWCollectionsViewController ()
@property (nonatomic, strong) VWWPhotosController *photosController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *sectionNames;
@property (nonatomic, strong) PHFetchResult * userAlbums;
@property (nonatomic, strong) PHFetchResult * userFavorites;
@property (nonatomic, strong) VWWSelectedAssets *selectedAssets;
@property (nonatomic) CGSize assetThumbnailSize;
@end

@implementation VWWCollectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.photosController = appDelegate.photosController;

    self.assetThumbnailSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height / 4.0);
    self.sectionNames = @[@"", @"", @"Albums"];
    
    self.selectedAssets = [[VWWSelectedAssets alloc]init];
    
    [self fetchCollections];
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self.navigationController setNavigationBarHidden:YES];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:VWWSegueCollectionsToSelect]){
        
        VWWAssetsCollectionViewController *vc = segue.destinationViewController;
        vc.selectedAssets = self.selectedAssets;
        UITableViewCell *cell = (UITableViewCell*)sender;
        vc.title = cell.textLabel.text;
        
        
        PHFetchOptions *options = [[PHFetchOptions alloc]init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        switch (indexPath.section) {
            case 0:{
                vc.assetsFetchResults = nil;
            }
                break;
            case 1:{
                if(indexPath.row == 0){
                    vc.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
                } else {
                    PHAssetCollection *favorites = self.userFavorites[indexPath.row - 1];
                    vc.assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:favorites options:options];
                }
            }
                break;
            case 2:{
                PHAssetCollection *album = self.userAlbums[indexPath.row];
                vc.assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:album options:options];
            }
                break;
            default:
                break;
        }
    }
}


-(void)fetchCollections{
    self.userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    self.userFavorites = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch(section) {
        case 0:
            return 1;
        case 1: // All Photos + Favorites
            return 1 + self.userFavorites.count;
        case 2: // Albums
            return self.userAlbums.count;
        default:
            return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    VWWCollectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VWWCollectionTableViewCell" forIndexPath:indexPath];
    cell.detailTextLabel.text = @"";
    
    

    void (^cleanUp)(PHAsset *asset) = ^(PHAsset *asset){
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.networkAccessAllowed = YES;

        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        VWWPhotosController *photosController = appDelegate.photosController;
        [photosController.imageManager requestImageForAsset:asset targetSize:self.assetThumbnailSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            cell.assetImage = result;
        }];
        
    };
    
    cell.groupLabel.text = @"";
    cell.countLabel.text = @"";
    
    switch(indexPath.section) {
        case 0:{
            // Selected
            cell.groupLabel.text = @"Upload Queue";
            cell.countLabel.text = [NSString stringWithFormat:@"%lu", self.selectedAssets.assets.count];
            if(self.selectedAssets.assets.count){
                cleanUp(self.selectedAssets.assets[self.selectedAssets.assets.count - 1]);
            }
        }
            break;
        case 1:{
            if(indexPath.row == 0){
                // All Photos
                cell.groupLabel.text = @"All Photos";
                PHFetchOptions *options = [[PHFetchOptions alloc]init];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                PHFetchResult *result = [PHAsset fetchAssetsWithOptions:options];
                cell.countLabel.text = [NSString stringWithFormat:@"%lu", result.count];
                [result enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndex:0] options:NSEnumerationConcurrent usingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                    cleanUp(asset);
                }];

                
            } else {
                // Favs
                PHAssetCollection *favorites = self.userFavorites[indexPath.row - 1];
                cell.groupLabel.text = favorites.localizedTitle;
                if(favorites.estimatedAssetCount != NSNotFound){
                    cell.countLabel.text = [NSString stringWithFormat:@"%lu", favorites.estimatedAssetCount];
                }
                
                PHFetchOptions *options = [[PHFetchOptions alloc]init];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:self.userFavorites[indexPath.row - 1] options:options];
                cell.countLabel.text = [NSString stringWithFormat:@"%lu", result.count];
                [result enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndex:0] options:NSEnumerationConcurrent usingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                    cleanUp(asset);
                }];
                
            }
            break;
        }
        case 2:{
            PHAssetCollection *album = self.userAlbums[indexPath.row];
            cell.groupLabel.text = album.localizedTitle;
            if(album.estimatedAssetCount != NSNotFound){
                cell.countLabel.text = [NSString stringWithFormat:@"%lu", album.estimatedAssetCount];
            }

            PHFetchOptions *options = [[PHFetchOptions alloc]init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:self.userAlbums[indexPath.row] options:options];
            [result enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndex:0] options:NSEnumerationConcurrent usingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                cleanUp(asset);
            }];

        }
            break;
        default:
            break;
    }
    return cell;
    
}



#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.assetThumbnailSize.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:VWWSegueCollectionsToSelect sender:cell];
}


@end
