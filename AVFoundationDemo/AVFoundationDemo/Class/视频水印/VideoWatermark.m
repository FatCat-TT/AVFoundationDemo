//
//  VideoWatermark.m
//  AVFoundationDemo
//
//  Created by 是不是傻呀你 on 2019/3/3.
//  Copyright © 2019 是不是傻呀你. All rights reserved.
//

#import "VideoWatermark.h"

@implementation VideoWatermark

- (AVPlayerItem *)makePlayerItemWithAsset:(AVAsset *)bgAsset andWatermark:(AVAsset *)watermark {
    AVMutableComposition *comp = [AVMutableComposition composition];
    
    CGSize videoSize = bgAsset.naturalSize;
    CGFloat startX = 0;
    CGFloat startY = 0;
    CGFloat endX = 0;
    CGFloat endY = 0;
    CGFloat scale = 1.2;
    
    {
        startX = videoSize.width / 2 - watermark.naturalSize.width / 2;
        startY = videoSize.height / 2 - watermark.naturalSize.height / 2;
        endX = videoSize.width / 2 - watermark.naturalSize.width * scale / 2;
        endY = videoSize.height / 2 - watermark.naturalSize.height * scale / 2;
    }
    
    AVMutableCompositionTrack *bgTrack = [comp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *wmTrack = [comp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    

    CMTimeRange bgRange = CMTimeRangeMake(kCMTimeZero, bgAsset.duration);
    AVAssetTrack *bgAssetTrack = [bgAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    [bgTrack insertTimeRange:bgRange ofTrack:bgAssetTrack atTime:kCMTimeZero error:nil];
    bgTrack.preferredTransform = bgAssetTrack.preferredTransform;
    
    
    CMTimeRange wmRange = CMTimeRangeMake(kCMTimeZero, watermark.duration);
    AVAssetTrack *wmAssetTrack = [watermark tracksWithMediaType:AVMediaTypeVideo].firstObject;
    [wmTrack insertTimeRange:wmRange ofTrack:wmAssetTrack atTime:kCMTimeZero error:nil];
    wmTrack.preferredTransform = wmAssetTrack.preferredTransform;
    
    AVMutableVideoComposition *videoComp = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:comp];
    videoComp.renderSize = videoSize;

    for (AVMutableVideoCompositionInstruction *instruction in videoComp.instructions) {
        [self adjustInstructionLayers:instruction];
        for (AVMutableVideoCompositionLayerInstruction *layerIns in instruction.layerInstructions) {
            if (layerIns.trackID == 1) {
                [layerIns setTransform:bgAsset.preferredTransform atTime:kCMTimeZero];
            } else {
                CGAffineTransform startTrans;
                CGAffineTransform endTrans;
                
                CGAffineTransform trans = watermark.preferredTransform;
                startTrans = CGAffineTransformTranslate(trans, startX, startY);
                
                trans =  CGAffineTransformTranslate(trans, endX, endY);
                endTrans = CGAffineTransformScale(trans, scale, scale);
                
                [layerIns setTransformRampFromStartTransform:startTrans toEndTransform:endTrans timeRange:wmRange];
            }
        }
    }
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:comp];
    item.videoComposition = videoComp;
    return item;
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
