//
//  MultipathAsset.h
//  AVFoundationDemo
//
//  Created by 是不是傻呀你 on 2019/3/2.
//  Copyright © 2019 是不是傻呀你. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface MultipathAsset : NSObject
@property (nonatomic) AVAsset *asset;
@property (nonatomic) CGPoint origin;

- (CGSize)size;
@end
