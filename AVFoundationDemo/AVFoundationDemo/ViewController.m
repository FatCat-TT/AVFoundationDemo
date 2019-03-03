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

- (IBAction)onVideoQueueBtnClick:(id)sender {
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:VIDEO1 withExtension:nil];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:VIDEO2 withExtension:nil];
    AVAsset *asset1 = [AVAsset assetWithURL:url1];
    AVAsset *asset2 = [AVAsset assetWithURL:url2];
    AVPlayerItem *item = [[VideoQueue new] makePlayerItemWithAssets:@[asset1, asset2]];
    [self play:item];
}

- (IBAction)onVideosMultipathBtnClick:(id)sender {
    //构造一个 w=980*2  h=548的 左边是1.mov 右边是2.mov的视频
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:VIDEO1 withExtension:nil];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:VIDEO2 withExtension:nil];
    
    MultipathAsset *asset1 = [[MultipathAsset alloc] init];
    asset1.asset = [AVAsset assetWithURL:url1];
    asset1.origin = CGPointZero;
    
    MultipathAsset *asset2 = [[MultipathAsset alloc] init];
    asset2.asset = [AVAsset assetWithURL:url2];
    asset2.origin = CGPointMake(980, 0);
    
    AVPlayerItem *item = [[VideoMultipath new] makePlayerItemWithAssets:@[asset1, asset2] size:CGSizeMake(980 * 2, 548)];
    [self play:item];
}

- (IBAction)onVideoWatermarkBtnClick:(id)sender {
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:VIDEO1 withExtension:nil];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:WATERMARK withExtension:nil];
    AVAsset *asset1 = [AVAsset assetWithURL:url1];
    AVAsset *asset2 = [AVAsset assetWithURL:url2];
    
    AVPlayerItem *item = [[VideoWatermark new] makePlayerItemWithAsset:asset1 andWatermark:asset2];
    [self play:item];
}@end
