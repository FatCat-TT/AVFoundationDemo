//
//  VideoWatermark.h
//  AVFoundationDemo
//
//  Created by 是不是傻呀你 on 2019/3/3.
//  Copyright © 2019 是不是傻呀你. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface VideoWatermark : NSObject

- (AVPlayerItem *)makePlayerItemWithAsset:(AVAsset *)asset andWatermark:(AVAsset *)watermark;

@end
