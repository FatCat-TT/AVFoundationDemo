//
//  ViewController.m
//  AVFoundationDemo
//
//  Created by 是不是傻呀你 on 2019/3/3.
//  Copyright © 2019 是不是傻呀你. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>
#import "VideoQueue.h"
#import "VideoMultipath.h"
#import "VideoWatermark.h"

#define VIDEO1 @"1.mov"
#define VIDEO2 @"2.mov"
#define WATERMARK @"3.mov"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)play:(AVPlayerItem *)item {
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
    vc.player = player;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)export:(AVPlayerItem *)item name:(NSString *)name {
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:item.asset presetName:AVAssetExportPresetHighestQuality];
    if (item.videoComposition) {
        [session setVideoComposition:item.videoComposition];
    }
    NSString *outPath = [NSTemporaryDirectory() stringByAppendingString:name];
    [session setOutputURL:[NSURL fileURLWithPath:outPath]];
    [session setOutputFileType:AVFileTypeQuickTimeMovie];
    [session exportAsynchronouslyWithCompletionHandler:^{
        if (session.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"outpath= %@", outPath);
        } else {
            NSLog(@"error= %@",session.error.description);
        }
    }];
}

- (IBAction)onVideoQueueBtnClick:(id)sender {
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:VIDEO1 withExtension:nil];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:VIDEO2 withExtension:nil];
    AVAsset *asset1 = [AVAsset assetWithURL:url1];
    AVAsset *asset2 = [AVAsset assetWithURL:url2];
    AVPlayerItem *item = [[VideoQueue new] makePlayerItemWithAssets:@[asset1, asset2]];
    
//    [self play:item];
    [self export:item name:@"result1.mov"];
}

- (IBAction)onVideosMultipathBtnClick:(id)sender {
    //构造一个 w=980*3 h=548*3
    NSMutableArray *videos = [NSMutableArray array];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:VIDEO1 withExtension:nil];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            MultipathAsset *asset = [[MultipathAsset alloc] init];
            asset.asset = [AVAsset assetWithURL:url];
            asset.origin = CGPointMake(i * 980, j * 548);
            [videos addObject:asset];
        }
    }
    CGSize videoSize = CGSizeMake(980 * 3, 548 * 3);
    
    AVPlayerItem *item = [[VideoMultipath new] makePlayerItemWithAssets:videos size:videoSize];
//    [self play:item];
    [self export:item name:@"result2.mov"];
}

- (IBAction)onVideoWatermarkBtnClick:(id)sender {
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:VIDEO1 withExtension:nil];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:WATERMARK withExtension:nil];
    AVAsset *asset1 = [AVAsset assetWithURL:url1];
    AVAsset *asset2 = [AVAsset assetWithURL:url2];
    
    AVPlayerItem *item = [[VideoWatermark new] makePlayerItemWithAsset:asset1 andWatermark:asset2];
//    [self play:item];
    [self export:item name:@"result3.mov"];
}


@end
