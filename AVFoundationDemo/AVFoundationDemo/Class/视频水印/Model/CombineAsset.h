//
//  CombineAsset.h
//  AVFoundationDemo
//
//  Created by 是不是傻呀你 on 2019/4/23.
//  Copyright © 2019 是不是傻呀你. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CombineAsset : NSObject

@property (nonatomic) AVComposition *comp;
@property (nonatomic) AVVideoComposition *videoComp;

@property (nonatomic) CALayer *animLayer;

- (CGFloat)videoDuration;

- (AVPlayerItem *)playerItem;
@end

