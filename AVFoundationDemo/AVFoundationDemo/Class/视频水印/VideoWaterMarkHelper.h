//
//  VideoWaterMarkHelper.h
//  AVFoundationDemo
//
//  Created by 是不是傻呀你 on 2019/4/23.
//  Copyright © 2019 是不是傻呀你. All rights reserved.
//

#import "CombineAsset.h"
#import <UIKit/UIKit.h>

@interface VideoWaterMarkHelper : NSObject

/// 图片静态水印 不能直接播放只能导出，想实时播放得换个方式
- (CombineAsset *)makeVideoWithAsset:(AVAsset *)asset andImg:(UIImage *)image;

/// 图片动画水印 不能直接播放只能导出，想实时播放得换个方式
- (CombineAsset *)makeVideoWithAsset:(AVAsset *)asset andAnimImg:(UIImage *)image;


/// 视频水印 可以直接播放
- (CombineAsset *)makeVideoWithAsset:(AVAsset *)asset andVideo:(AVAsset *)watermark;

/// 视频动画水印 可以直接播放
- (CombineAsset *)makeVideoWithAsset:(AVAsset *)asset andAnimVideo:(AVAsset *)watermark;

/// 视频中心放大水印 可以直接播放
- (CombineAsset *)makeVideoWithAsset:(AVAsset *)asset andScaleAnimVideo:(AVAsset *)watermark;
@end


