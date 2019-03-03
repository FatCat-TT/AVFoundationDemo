//
//  VideoQueue.m
//  AVFoundationDemo
//
//  Created by 是不是傻呀你 on 2019/3/2.
//  Copyright © 2019 是不是傻呀你. All rights reserved.
//

#import "VideoQueue.h"

@implementation VideoQueue

- (AVPlayerItem *)makePlayerItemWithAssets:(NSArray<AVAsset *> *)assets {
    AVMutableComposition *comp = [AVMutableComposition composition];
    AVMutableCompositionTrack *track = [comp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    for (AVAsset *asset in assets) {
        AVAssetTrack *assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        CMTimeRange assetRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        [track insertTimeRange:assetRange ofTrack:assetTrack atTime:kCMTimeZero error:nil];
    }
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:comp];
    return item;
}



@end
