//
//  CombineAsset.m
//  AVFoundationDemo
//
//  Created by 是不是傻呀你 on 2019/4/23.
//  Copyright © 2019 是不是傻呀你. All rights reserved.
//

#import "CombineAsset.h"

@implementation CombineAsset

- (CGFloat)videoDuration {
    return CMTimeGetSeconds(self.comp.duration);
}

- (AVPlayerItem *)playerItem {
    // animationTool不允许播放
    if (self.videoComp.animationTool) return nil;
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:self.comp];
    if (self.videoComp) {
       item.videoComposition = self.videoComp;
    }
    return item;
}
@end
