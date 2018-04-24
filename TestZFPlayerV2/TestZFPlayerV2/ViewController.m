//
//  ViewController.m
//  TestZFPlayerV2
//
//  Created by 黄卫 on 2018/4/23.
//  Copyright © 2018年 huangwei. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry/Masonry.h>
#import <ZFDownload/ZFDownloadManager.h>
#import "ZFPlayer.h"

#import "ViewController.h"

@interface ViewController ()<ZFPlayerDelegate>
@property (strong, nonatomic) UIView *playerFatherView;
@property (strong, nonatomic) ZFPlayerView *playerView;
/** 离开页面时候是否在播放 */
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) ZFPlayerModel *playerModel;
@property (nonatomic, strong) UIView *bottomView;
@property (strong, nonatomic) UIButton *backBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.zf_prefersNavigationBarHidden = YES;
    
     self.playerFatherView = [[UIView alloc] init];
     [self.view addSubview:self.playerFatherView];
     [self.playerFatherView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.mas_equalTo(20);
     make.leading.trailing.mas_equalTo(0);
     // 这里宽高比16：9,可自定义宽高比
     make.height.mas_equalTo(self.playerFatherView.mas_width).multipliedBy(9.0f/16.0f);
     }];
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(10);
        make.height.with.mas_equalTo(40);
    }];
    
    [self.playerView pause];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // pop回来时候是否自动播放
    if (self.navigationController.viewControllers.count == 2 && self.playerView && self.isPlaying) {
        self.isPlaying = NO;
        self.playerView.playerPushedOrPresented = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // push出下一级页面时候暂停
    if (self.navigationController.viewControllers.count == 3 && self.playerView && !self.playerView.isPauseByUser)
    {
        self.isPlaying = YES;
        //        [self.playerView pause];
        self.playerView.playerPushedOrPresented = YES;
    }
}

// 返回值要必须为NO
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    // 这里设置横竖屏不同颜色的statusbar
    // if (ZFPlayerShared.isLandscape) {
    //    return UIStatusBarStyleDefault;
    // }
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return ZFPlayerShared.isStatusBarHidden;
}

#pragma mark - ZFPlayerDelegate

- (void)zf_playerBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)zf_playerShareAction{
    NSLog(@"--------zf_playerShareAction-----------");
}

-(void)zf_playerCommentAction{
    NSLog(@"--------zf_playerCommentAction-----------");
}

-(void)zf_playerPraiseAction{
    NSLog(@"--------zf_playerPraiseAction-----------");
}

- (void)zf_playerDownload:(NSString *)url {
    [self.playerView pause];
    
    // 此处是截取的下载地址，可以自己根据服务器的视频名称来赋值
    NSString *name = [url lastPathComponent];
    [[ZFDownloadManager sharedDownloadManager] downFileUrl:url filename:name fileimage:nil];
    // 设置最多同时下载个数（默认是3）
    [ZFDownloadManager sharedDownloadManager].maxCount = 4;
}

- (void)zf_playerControlViewWillShow:(UIView *)controlView isFullscreen:(BOOL)fullscreen {
    //    self.backBtn.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.backBtn.alpha = 0;
    }];
}

- (void)zf_playerControlViewWillHidden:(UIView *)controlView isFullscreen:(BOOL)fullscreen {
    //    self.backBtn.hidden = fullscreen;
    [UIView animateWithDuration:0.25 animations:^{
        self.backBtn.alpha = !fullscreen;
    }];
}

#pragma mark - Getter

- (ZFPlayerModel *)playerModel {
    if (!_playerModel) {
        _playerModel                  = [[ZFPlayerModel alloc] init];
        _playerModel.title            = @"这里设置视频标题";
        _playerModel.videoURL         = [NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
//        _playerModel.placeholderImage = [UIImage imageNamed:@"loading_bgView1"];
        _playerModel.placeholderImageURLString = @"http://img.wdjimg.com/image/video/447f973848167ee5e44b67c8d4df9839_0_0.jpeg";
        _playerModel.fatherView       = self.playerFatherView;
        //        _playerModel.resolutionDic = @{@"高清" : self.videoURL.absoluteString,
        //                                       @"标清" : self.videoURL.absoluteString};
    }
    return _playerModel;
}

- (ZFPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[ZFPlayerView alloc] init];
        
        /*****************************************************************************************
         *   // 指定控制层(可自定义)
         *   // ZFPlayerControlView *controlView = [[ZFPlayerControlView alloc] init];
         *   // 设置控制层和播放模型
         *   // 控制层传nil，默认使用ZFPlayerControlView(如自定义可传自定义的控制层)
         *   // 等效于 [_playerView playerModel:self.playerModel];
         ******************************************************************************************/
        [_playerView playerControlView:nil playerModel:self.playerModel];
        
        // 设置代理
        _playerView.delegate = self;
        
        //（可选设置）可以设置视频的填充模式，内部设置默认（ZFPlayerLayerGravityResizeAspect：等比例填充，直到一个维度到达区域边界）
        // _playerView.playerLayerGravity = ZFPlayerLayerGravityResize;
        
        // 打开下载功能（默认没有这个功能）
        _playerView.hasDownload    = YES;
        
        // 打开预览图
        _playerView.hasPreviewView = YES;
        
        //        _playerView.forcePortrait = YES;
        /// 默认全屏播放
        //        _playerView.fullScreenPlay = YES;
        
    }
    return _playerView;
}

#pragma mark - Action

- (void)backClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)playNewVideo:(UIButton *)sender {
    self.playerModel.title            = @"这是新播放的视频";
    self.playerModel.videoURL         = [NSURL URLWithString:@"http://baobab.wdjcdn.com/1456665467509qingshu.mp4"];
    // 设置网络封面图
    self.playerModel.placeholderImageURLString = @"http://img.wdjimg.com/image/video/447f973848167ee5e44b67c8d4df9839_0_0.jpeg";
    // 从xx秒开始播放视频
    // self.playerModel.seekTime         = 15;
    [self.playerView resetToPlayNewVideo:self.playerModel];
}


@end
