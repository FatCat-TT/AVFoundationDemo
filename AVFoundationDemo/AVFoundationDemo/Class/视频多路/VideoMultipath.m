//
//  VideoMultipath.m
//  AVFoundationDemo
//
//  Created by 是不是傻呀你 on 2019/3/2.
//  Copyright © 2019 是不是傻呀你. All rights reserved.
//

#import "VideoMultipath.h"


@implementation VideoMultipath

- (AVPlayerItem *)makePlayerItemWithAssets:(NSArray<MultipathAsset *> *)assets size:(CGSize)size {
    AVMutableComposition *comp = [AVMutableComposition composition];
    
    //记录下 每一个trackID对应的哪个video
    NSMutableDictionary *trackRecord = [NSMutableDictionary dictionary];
    
    for (MultipathAsset *item in assets) {
        AVMutableCompositionTrack *track = [comp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *assetTrack = [item.asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        CMTimeRange range = CMTimeRangeMake(kCMTimeZero, item.asset.duration);
        [track insertTimeRange:range ofTrack:assetTrack atTime:kCMTimeZero error:nil];
        [trackRecord setObject:item forKey:@(track.trackID)];
    }
    
    AVMutableVideoComposition *videoComp = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:comp];
    videoComp.renderSize = size;
    
    for (AVMutableVideoCompositionInstruction *instruction in videoComp.instructions) {
        for (AVMutableVideoCompositionLayerInstruction *layerIns in instruction.layerInstructions) {
            MultipathAsset *video = [trackRecord objectForKey:@(layerIns.trackID)];
            if (video) {
                CGAffineTransform trans = video.asset.preferredTransform;
                trans = CGAffineTransformTranslate(trans, video.origin.x, video.origin.y);
                [layerIns setTransform:trans atTime:kCMTimeZero];
            }
        }
    }
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:comp];
    item.videoComposition = videoComp;
    return item;
}

@end
