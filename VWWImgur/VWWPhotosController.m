//
//  VWWPhotosController.m
//  VWWImgur
//
//  Created by Zakk Hoyt on 10/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWPhotosController.h"
#import "VWWBlocks.h"


@implementation VWWPhotosController



- (instancetype)init{
    self = [super init];
    if (self) {
        [self authenticateWithCompletionBlock:^{
            self.imageManager = [[PHCachingImageManager alloc]init];
        }];
    }
    return self;
}

-(void)authenticateWithCompletionBlock:(VWWEmptyBlock)completionBlock{
    switch([PHPhotoLibrary authorizationStatus]){
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusAuthorized:
            completionBlock();
            break;
        
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusNotDetermined:
        default:{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                completionBlock();
            }];
        }
    }
    
}


@end
