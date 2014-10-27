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

static NSString *VWWSegueCollectionsToSelect = @"VWWSegueCollectionsToSelect";

@interface VWWCollectionsViewController ()
@property (nonatomic, strong) VWWPhotosController *photosController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *sectionNames;
@property (nonatomic, strong) PHFetchResult * userAlbums;
@property (nonatomic, strong) PHFetchResult * userFavorites;
@property (nonatomic, strong) VWWSelectedAssets *selectedAssets;
@end

@implementation VWWCollectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.photosController = appDelegate.photosController;
    
    self.sectionNames = @[@"", @"", @"Albums"];
    
    self.selectedAssets = [[VWWSelectedAssets alloc]init];
    
    [self fetchCollections];
    [self.tableView reloadData];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VWWAssetCollectionTableViewCell" forIndexPath:indexPath];
    cell.detailTextLabel.text = @"";
    
    switch(indexPath.section) {
        case 0:{
            // Selected
            cell.textLabel.text = @"Upload Queue";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", self.selectedAssets.assets.count];
        }
            break;
        case 1:{
            if(indexPath.row == 0){
                // All Photos
                cell.textLabel.text = @"All Photos";
            } else {
                // Favs
                PHAssetCollection *favorites = self.userFavorites[indexPath.row - 1];
                cell.textLabel.text = favorites.localizedTitle;
                if(favorites.estimatedAssetCount != NSNotFound){
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", favorites.estimatedAssetCount];
                }
            }
            break;
        }
        case 2:{
            PHAssetCollection *album = self.userAlbums[indexPath.row];
            cell.textLabel.text = album.localizedTitle;
            if(album.estimatedAssetCount != NSNotFound){
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", album.estimatedAssetCount];
            }
            
        }
            break;
        default:
            break;
    }
    return cell;
    
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:VWWSegueCollectionsToSelect sender:cell];
}


@end
