//
//  VideoWaterMarkHelper.m
//  AVFoundationDemo
//
//  Created by 是不是傻呀你 on 2019/4/23.
//  Copyright © 2019 是不是傻呀你. All rights reserved.
//

#import "VideoWaterMarkHelper.h"

@implementation VideoWaterMarkHelper
/// 图片静态水印
- (CombineAsset *)makeVideoWithAsset:(AVAsset *)asset andImg:(UIImage *)image {
    CGSize videoSize = asset.naturalSize;
    CGSize wmSize = CGSizeMake(100, 100);
    CGFloat fps = 30;
    
    ///第一步 构造一个Compostion
    AVMutableComposition *comp = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [comp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    ///第二步 插入背景视频
    AVAssetTrack *assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    CMTimeRange bgRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    NSError *error;
    [videoTrack insertTimeRange:bgRange ofTrack:assetTrack atTime:kCMTimeZero error:&error];
    NSAssert(!error, @"插入新视频有问题");
    fps = assetTrack.nominalFrameRate;
    
    ///第三步 构造一个水印的Layer 放置到右下角，计算一下位置
    CALayer *animLayer = [CALayer layer];
    animLayer.contents = (__bridge id)image.CGImage;
    animLayer.contentsGravity = kCAGravityResizeAspect;
    animLayer.frame = CGRectMake(videoSize.width - wmSize.width, videoSize.height - wmSize.height, wmSize.width, wmSize.height);
    
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    //因为layer的坐标系和视频的坐标系的冲突会导致y轴反向，需要下面这句调整y轴
    parentLayer.geometryFlipped = YES;
    //视频所在的layer层
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = parentLayer.bounds;
    //这里先后顺序起到了谁在下面谁在上面的作用
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:animLayer];
    
    ///第四步 构造Instruction和LayerInstruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = bgRange;
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    instruction.layerInstructions = @[layerInstruction];
    
    ///第五步 构造一个AnimationTool
    AVVideoCompositionCoreAnimationTool *animTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    ///第六步 构造videoComposition
    AVMutableVideoComposition *videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    videoComp.animationTool = animTool;
    videoComp.instructions = @[instruction];
    ///这里直接用了asset的帧率，没需求的话就直接写30，帧率越高越耗时
    videoComp.frameDuration = CMTimeMake(1, fps);
    
    /// 返回结果
    CombineAsset *result = [[CombineAsset alloc] init];
    result.comp = comp;
    result.videoComp = videoComp;
    result.animLayer = animLayer;
    return result;
}

/// 图片动画水印
- (CombineAsset *)makeVideoWithAsset:(AVAsset *)asset andAnimImg:(UIImage *)image {
    CombineAsset *result = [self makeVideoWithAsset:asset andImg:image];
    CALayer *animLayer = result.animLayer;
    
    //设置从右下方移动到左上方动画
    CGRect frame = animLayer.frame;
    CGPoint beginCenter = CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2);
    CGPoint endCenter = CGPointMake(frame.size.width / 2, frame.size.height / 2);

    CABasicAnimation *anim = [CABasicAnimation animation];
    anim.keyPath = @"position";
    anim.fromValue = [NSValue valueWithCGPoint:beginCenter];
    anim.toValue = [NSValue valueWithCGPoint:endCenter];
    anim.beginTime = AVCoreAnimationBeginTimeAtZero;//视频用这个时间
    anim.duration = result.videoDuration;
    anim.repeatCount = HUGE_VALF;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    
    
    [animLayer addAnimation:anim forKey:@"moveAnimLayer"];
    return result;
}

/// 视频水印 可以直接播放
- (CombineAsset *)makeVideoWithAsset:(AVAsset *)asset andVideo:(AVAsset *)watermark {
    CGSize videoSize = asset.naturalSize;
    CGSize wmSize = watermark.naturalSize;
    CGFloat fps = 30;
    
    /// 第一步 构造comp和2条轨道，插入视频
    AVMutableComposition *comp = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [comp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *wmTrack = [comp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //插入背景视频
    AVAssetTrack *assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    CMTimeRange bgRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    NSError *error;
    [videoTrack insertTimeRange:bgRange ofTrack:assetTrack atTime:kCMTimeZero error:&error];
    NSAssert(!error, @"插入新视频有问题");
    fps = assetTrack.nominalFrameRate;
    
    //插入水印
    AVAssetTrack *watermarkTrack = [watermark tracksWithMediaType:AVMediaTypeVideo].firstObject;
    CMTimeRange wmRange = CMTimeRangeMake(kCMTimeZero, watermark.duration);
    [wmTrack insertTimeRange:wmRange ofTrack:watermarkTrack atTime:kCMTimeZero error:&error];
    NSAssert(!error, @"插入水印视频有问题");
    
    ///第二步 构造Instruction和layerInstruction
    AVMutableVideoCompositionLayerInstruction *videoLayerIns = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [videoLayerIns setTransform:asset.preferredTransform atTime:kCMTimeZero];
    
    AVMutableVideoCompositionLayerInstruction *wmLayerIns = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:wmTrack];
    //移到右下角
    CGAffineTransform wmTrans = CGAffineTransformMakeTranslation(videoSize.width - wmSize.width, videoSize.height - wmSize.height);
    [wmLayerIns setTransform:wmTrans atTime:kCMTimeZero];
    
    //前后顺序决定了谁上谁下 前面的在上面
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = bgRange;
    instruction.layerInstructions = @[wmLayerIns, videoLayerIns];
    ///第三步 构造VideoComposition
    AVMutableVideoComposition *videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.instructions = @[instruction];
    videoComp.frameDuration = CMTimeMake(1, fps);
    videoComp.renderSize = videoSize;
    
    //
    CombineAsset *result = [[CombineAsset alloc] init];
    result.comp = comp;
    result.videoComp = videoComp;
    return result;
}

/// 视频动画水印 可以直接播放
- (CombineAsset *)makeVideoWithAsset:(AVAsset *)asset andAnimVideo:(AVAsset *)watermark {
    CGSize videoSize = asset.naturalSize;
    CGSize wmSize = watermark.naturalSize;
    CMTimeRange bgRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    
    CombineAsset *result = [self makeVideoWithAsset:asset andVideo:watermark];
    
    //给LayerInstruction添加右下角到左上角动画
    AVVideoCompositionInstruction *instruction = (AVVideoCompositionInstruction *)result.videoComp.instructions.firstObject;
    AVMutableVideoCompositionLayerInstruction *wmLayerIns = (AVMutableVideoCompositionLayerInstruction *)instruction.layerInstructions.firstObject;
    
    CGAffineTransform wmBeginTrans = CGAffineTransformMakeTranslation(videoSize.width - wmSize.width, videoSize.height - wmSize.height);
    CGAffineTransform wmEndTrans = CGAffineTransformIdentity;
    [wmLayerIns setTransformRampFromStartTransform:wmBeginTrans toEndTransform:wmEndTrans timeRange:bgRange];
    return result;
}

- (CombineAsset *)makeVideoWithAsset:(AVAsset *)asset andScaleAnimVideo:(AVAsset *)watermark {
    /// 使用的是多路的方法，并不比自己写instruction和layerInstruction简单，主要只有2段视频，在少视频的时候直接自己控制ins和layerIns会更简便一些
    CGSize videoSize = asset.naturalSize;
    CGSize wmSize = watermark.naturalSize;
    CGFloat fps = 30;
    CGFloat startX,startY,endX,endY;
    CGFloat scale = 1.2;
    
    startX = videoSize.width / 2 - wmSize.width / 2;
    startY = videoSize.height / 2 - wmSize.height / 2;
    endX = videoSize.width / 2 - wmSize.width * scale / 2;
    endY = videoSize.height / 2 - wmSize.height * scale / 2;
    
    AVMutableComposition *comp = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *bgTrack = [comp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *wmTrack = [comp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTimeRange bgRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    AVAssetTrack *bgAssetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    [bgTrack insertTimeRange:bgRange ofTrack:bgAssetTrack atTime:kCMTimeZero error:nil];

    CMTimeRange wmRange = CMTimeRangeMake(kCMTimeZero, watermark.duration);
    AVAssetTrack *wmAssetTrack = [watermark tracksWithMediaType:AVMediaTypeVideo].firstObject;
    [wmTrack insertTimeRange:wmRange ofTrack:wmAssetTrack atTime:kCMTimeZero error:nil];
    
    AVMutableVideoComposition *videoComp = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:comp];
    videoComp.renderSize = videoSize;
    videoComp.frameDuration = CMTimeMake(1, fps);
    
    for (AVMutableVideoCompositionInstruction *instruction in videoComp.instructions) {
        [self adjustInstructionLayers:instruction];
        for (AVMutableVideoCompositionLayerInstruction *layerIns in instruction.layerInstructions) {
            if (layerIns.trackID == 1) {
                [layerIns setTransform:asset.preferredTransform atTime:kCMTimeZero];
            } else {
                CGAffineTransform startTrans = CGAffineTransformMakeTranslation(startX, startY);
                CGAffineTransform endTrans =  CGAffineTransformMakeTranslation(endX, endY);
                endTrans = CGAffineTransformScale(endTrans, scale, scale);
                //使用wmRange就会在结束时不再显示，使用bgRange会保留最后一帧
                [layerIns setTransformRampFromStartTransform:startTrans toEndTransform:endTrans timeRange:wmRange];
            }
        }
    }
    
    CombineAsset *result = [[CombineAsset alloc] init];
    result.comp = comp;
    result.videoComp = videoComp;
    return result;
}

- (void)adjustInstructionLayers:(AVMutableVideoCompositionInstruction *)instruction {
    NSArray *layerInstructions = instruction.layerInstructions;
    layerInstructions = [layerInstructions sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        AVMutableVideoCompositionLayerInstruction *layerIns1 = obj1;
        AVMutableVideoCompositionLayerInstruction *layerIns2 = obj2;
        if (layerIns1.trackID < layerIns2.trackID) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    instruction.layerInstructions = layerInstructions;
    for (AVMutableVideoCompositionLayerInstruction *layerIns in layerInstructions) {
        NSLog(@"test:%d", layerIns.trackID);
    }
}
@end
