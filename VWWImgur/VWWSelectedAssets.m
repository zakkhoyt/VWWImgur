//
//  VWWSelectedAssets.m
//  VWWImgur
//
//  Created by Zakk Hoyt on 10/27/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWSelectedAssets.h"

@interface VWWSelectedAssets ()

@end

@implementation VWWSelectedAssets
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.assets = [[NSMutableArray alloc]init];
    }
    return self;
}
- (instancetype)initWithAsset:(NSArray*)assets{
    self = [super init];
    if (self) {
        self.assets = [[NSMutableArray alloc]initWithArray:assets];
    }
    return self;
}
@end
