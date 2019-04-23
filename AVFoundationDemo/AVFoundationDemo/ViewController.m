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
#import "VideoWaterMarkHelper.h"

#define VIDEO1 @"1.mov"
#define VIDEO2 @"2.mov"
#define VIDEO3 @"3.mov"

#define IMG01 @"a1.png"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma -mark 静态水印
- (IBAction)onImgWMBtnClick:(id)sender {
    NSURL *url = [[NSBundle mainBundle] URLForResource:VIDEO1 withExtension:nil];
    AVAsset *asset = [AVAsset assetWithURL:url];
    UIImage *image = [UIImage imageNamed:@"a1.png"];
    CombineAsset *result = [[VideoWaterMarkHelper new] makeVideoWithAsset:asset andImg:image];
    [self exportCombineAsset:result name:@"图片水印.mov"];
}

- (IBAction)onImgAnimWMBtnClick:(id)sender {
    NSURL *url = [[NSBundle mainBundle] URLForResource:VIDEO1 withExtension:nil];
    AVAsset *asset = [AVAsset assetWithURL:url];
    UIImage *image = [UIImage imageNamed:@"a1.png"];
    CombineAsset *result = [[VideoWaterMarkHelper new] makeVideoWithAsset:asset andAnimImg:image];
    [self exportCombineAsset:result name:@"图片移动水印.mov"];
}

#pragma -mark 视频水印
- (IBAction)onVideoWMBtnClick:(id)sender {
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:VIDEO1 withExtension:nil];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:VIDEO3 withExtension:nil];
    AVAsset *asset1 = [AVAsset assetWithURL:url1];
    AVAsset *asset2 = [AVAsset assetWithURL:url2];
    CombineAsset *result = [[VideoWaterMarkHelper new] makeVideoWithAsset:asset1 andVideo:asset2];
    [self play:result.playerItem];
//    [self exportPlayerItem:item name:@"result3.mov"];
}

- (IBAction)onVideoAnimWMBtnClick:(id)sender {
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:VIDEO1 withExtension:nil];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:VIDEO3 withExtension:nil];
    AVAsset *asset1 = [AVAsset assetWithURL:url1];
    AVAsset *asset2 = [AVAsset assetWithURL:url2];
    
    CombineAsset *result = [[VideoWaterMarkHelper new] makeVideoWithAsset:asset1 andAnimVideo:asset2];
    [self play:result.playerItem];
//    [self exportPlayerItem:item name:@"result3.mov"];
}

#pragma -mark 视频接续+多路+新动画水印
- (IBAction)onVideoQueueBtnClick:(id)sender {
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:VIDEO1 withExtension:nil];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:VIDEO2 withExtension:nil];
    AVAsset *asset1 = [AVAsset assetWithURL:url1];
    AVAsset *asset2 = [AVAsset assetWithURL:url2];
    AVPlayerItem *item = [[VideoQueue new] makePlayerItemWithAssets:@[asset1, asset2]];
    
    [self play:item];
//    [self exportPlayerItem:item name:@"result1.mov"];
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
    [self play:item];
//    [self exportPlayerItem:item name:@"result2.mov"];
}

- (IBAction)onVideoNewAnimBtnClick:(id)sender {
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:VIDEO1 withExtension:nil];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:VIDEO3 withExtension:nil];
    AVAsset *asset1 = [AVAsset assetWithURL:url1];
    AVAsset *asset2 = [AVAsset assetWithURL:url2];
    
    CombineAsset *result = [[VideoWaterMarkHelper new] makeVideoWithAsset:asset1 andScaleAnimVideo:asset2];
    [self play:result.playerItem];
//    [self exportPlayerItem:result.playerItem name:@"result3.mov"];
}

#pragma -mark 导出+播放
- (void)exportWithComp:(AVComposition *)comp videoComp:(AVVideoComposition *)videoComp name:(NSString *)name {
    NSString *outPath = [NSTemporaryDirectory() stringByAppendingString:name];
    [[NSFileManager defaultManager] removeItemAtPath:outPath error:nil];
    
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:comp presetName:AVAssetExportPresetHighestQuality];
    if (videoComp) {
        [session setVideoComposition:videoComp];
    }
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

- (void)exportPlayerItem:(AVPlayerItem *)item name:(NSString *)name {
    [self exportWithComp:(AVComposition *)item.asset videoComp:item.videoComposition name:name];
}

- (void)exportCombineAsset:(CombineAsset *)asset name:(NSString *)name {
    [self exportWithComp:asset.comp videoComp:asset.videoComp name:name];
}

- (void)play:(AVPlayerItem *)item {
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
    vc.player = player;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
