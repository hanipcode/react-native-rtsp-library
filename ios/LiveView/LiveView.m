//
//  LiveView.m
//  hlwintlive
//
//  Created by shwetech on 25/09/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/UIView+React.h>
#import "LiveView.h"
#import "LFLiveKit.h"

@interface LiveView()<LFLiveSessionDelegate>
@property (nonatomic, weak) RCTBridge *bridge;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) LFLiveDebug *debugInfo;
@property (nonatomic, strong) LFLiveSession *session;
@property (nonatomic, copy) RCTDirectEventBlock onBroadcastStart;
@property (nonatomic, copy) RCTDirectEventBlock onBroadcastFail;
@property (nonatomic, copy) RCTDirectEventBlock onBroadcastStatusChange;
@property (nonatomic, copy) RCTDirectEventBlock onBroadcastEventReceive;
@property (nonatomic, copy) RCTDirectEventBlock onBroadcastErrorReceive;
@property (nonatomic, copy) RCTDirectEventBlock onBroadcastVideoEncoded;
@property (nonatomic, copy) RCTDirectEventBlock onBroadcastStop;

@property (nonatomic, strong) NSString *broadcastName;
@property (nonatomic, assign) BOOL broadcasting;
@property (nonatomic, assign) BOOL frontCamera;
@end

@implementation LiveView
inline static NSString *formatedSpeed(float bytes, float elapsed_milli) {
  if (elapsed_milli <= 0) {
    return @"N/A";
  }
  
  if (bytes <= 0) {
    return @"0 KB/s";
  }
  
  float bytes_per_sec = ((float)bytes) * 1000.f /  elapsed_milli;
  if (bytes_per_sec >= 1000 * 1000) {
    return [NSString stringWithFormat:@"%.2f MB/s", ((float)bytes_per_sec) / 1000 / 1000];
  } else if (bytes_per_sec >= 1000) {
    return [NSString stringWithFormat:@"%.1f KB/s", ((float)bytes_per_sec) / 1000];
  } else {
    return [NSString stringWithFormat:@"%ld B/s", (long)bytes_per_sec];
  }
}

-(id)initWithBridge: (RCTBridge *)bridge
{
  if ((self = [super init])) {
    self.bridge = bridge;
    [self requestAccessForVideo];
    [self requestAccessForAudio];
    [self addSubview:self.containerView];
  }
  return self;
}

#pragma mark -- subview
- (void)layoutSubviews
{
  [super layoutSubviews];
  self.containerView.frame = self.bounds;
  [self setBackgroundColor:[UIColor blackColor]];
}

- (void)insertReactSubview:(UIView *)view atIndex:(NSInteger)atIndex
{
  [self insertSubview:view atIndex:atIndex + 1];
  [super insertReactSubview:view atIndex:atIndex];
  return;
}

- (void)removeReactSubview:(UIView *)subview
{
  [subview removeFromSuperview];
  [super removeReactSubview:subview];
  if (self.broadcasting) {
    [self.session stopLive];
  }
  return;
}
#pragma mark -- Authorization
- (void)requestAccessForVideo {
  __weak typeof(self) _self = self;
  AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  switch (status) {
    case AVAuthorizationStatusNotDetermined: {
      [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [_self.session setRunning:YES];
          });
        }
      }];
      break;
    }
    case AVAuthorizationStatusAuthorized: {
      dispatch_async(dispatch_get_main_queue(), ^{
        [_self.session setRunning:YES];
      });
      break;
    }
    case AVAuthorizationStatusDenied:
    case AVAuthorizationStatusRestricted:
      
      break;
    default:
      break;
  }
}

- (void)requestAccessForAudio {
  AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
  switch (status) {
    case AVAuthorizationStatusNotDetermined: {
      [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
      }];
      break;
    }
    case AVAuthorizationStatusAuthorized: {
      break;
    }
    case AVAuthorizationStatusDenied:
    case AVAuthorizationStatusRestricted:
      break;
    default:
      break;
  }
}
#pragma mark -- LFStreamingSessionDelegate
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
  NSLog(@"liveStateDidChange: %ld", state);
  switch (state) {
    case LFLiveReady:
      NSLog(@"LiveVIew: Live Changed to Ready");
      break;
    case LFLivePending:
      NSLog(@"LiveView: Live Changed to Pending");
      break;
    case LFLiveStart:
      NSLog(@"LiveView: Live Changed to Start");
      break;
    case LFLiveError:
      NSLog(@"LiveView: Live Has an Error");
      break;
    case LFLiveStop:
      NSLog(@"LiveView: Live Has Stopped");
      break;
    default:
      break;
  }
}

/** live debug info callback */
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo {
  NSLog(@"debugInfo uploadSpeed: %@", formatedSpeed(debugInfo.currentBandwidth, debugInfo.elapsedMilli));
}

/** callback socket errorcode */
- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
  NSLog(@"errorCode: %ld", errorCode);
}

#pragma mark -- Getter Setter
- (LFLiveSession *)session {
  if (!_session) {
    /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/
    /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/
    /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/
    
    
    /***   默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏 ***/
    LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
    videoConfiguration.videoSize = CGSizeMake(720, 1280);
    videoConfiguration.videoBitRate = 800*1024;
    videoConfiguration.videoMaxBitRate = 1000*1024;
    videoConfiguration.videoMinBitRate = 500*1024;
    videoConfiguration.videoFrameRate = 15;
    videoConfiguration.videoMaxKeyframeInterval = 30;
//    videoConfiguration.landscape = NO;
    videoConfiguration.autorotate = NO;
    videoConfiguration.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoConfiguration.sessionPreset = LFCaptureSessionPreset540x960;
    _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:videoConfiguration captureType:LFLiveCaptureDefaultMask];
    
    /**    自己定制单声道  */
    /*
     LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
     audioConfiguration.numberOfChannels = 1;
     audioConfiguration.audioBitrate = LFLiveAudioBitRate_64Kbps;
     audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
     _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
     */
    
    /**    自己定制高质量音频96K */
    /*
     LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
     audioConfiguration.numberOfChannels = 2;
     audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
     audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
     _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
     */
    
    /**    自己定制高质量音频96K 分辨率设置为540*960 方向竖屏 */
    
    /*
     LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
     audioConfiguration.numberOfChannels = 2;
     audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
     audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
     LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
     videoConfiguration.videoSize = CGSizeMake(540, 960);
     videoConfiguration.videoBitRate = 800*1024;
     videoConfiguration.videoMaxBitRate = 1000*1024;
     videoConfiguration.videoMinBitRate = 500*1024;
     videoConfiguration.videoFrameRate = 24;
     videoConfiguration.videoMaxKeyframeInterval = 48;
     videoConfiguration.orientation = UIInterfaceOrientationPortrait;
     videoConfiguration.sessionPreset = LFCaptureSessionPreset540x960;
     _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
     */
    
    
    /**    自己定制高质量音频128K 分辨率设置为720*1280 方向竖屏 */
    
    /*
     LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
     audioConfiguration.numberOfChannels = 2;
     audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
     audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
     LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
     videoConfiguration.videoSize = CGSizeMake(720, 1280);
     videoConfiguration.videoBitRate = 800*1024;
     videoConfiguration.videoMaxBitRate = 1000*1024;
     videoConfiguration.videoMinBitRate = 500*1024;
     videoConfiguration.videoFrameRate = 15;
     videoConfiguration.videoMaxKeyframeInterval = 30;
     videoConfiguration.landscape = NO;
     videoConfiguration.sessionPreset = LFCaptureSessionPreset360x640;
     _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
     */
    
    
    /**    自己定制高质量音频128K 分辨率设置为720*1280 方向横屏  */
    
    /*
     LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
     audioConfiguration.numberOfChannels = 2;
     audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
     audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
     LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
     videoConfiguration.videoSize = CGSizeMake(1280, 720);
     videoConfiguration.videoBitRate = 800*1024;
     videoConfiguration.videoMaxBitRate = 1000*1024;
     videoConfiguration.videoMinBitRate = 500*1024;
     videoConfiguration.videoFrameRate = 15;
     videoConfiguration.videoMaxKeyframeInterval = 30;
     videoConfiguration.landscape = YES;
     videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
     _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
     */
    
    _session.delegate = self;
    _session.showDebugInfo = NO;
    _session.preView = self;
    
    /*本地存储*/
    //        _session.saveLocalVideo = YES;
    //        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
    //        unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    //        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    //        _session.saveLocalVideoPath = movieURL;
    
    /*
     UIImageView *imageView = [[UIImageView alloc] init];
     imageView.alpha = 0.8;
     imageView.frame = CGRectMake(100, 100, 29, 29);
     imageView.image = [UIImage imageNamed:@"ios-29x29"];
     _session.warterMarkView = imageView;*/
    
  }
  return _session;
}

- (UIView *)containerView {
  if (!_containerView) {
    _containerView = [UIView new];
    _containerView.frame = self.bounds;
    _containerView.backgroundColor = [UIColor clearColor];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  }
  return _containerView;
}

-(void)setBroadcasting:(BOOL)broadcasting {
  if (self.session) {
    if (broadcasting) {
      LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
      stream.url = [NSString stringWithFormat: @"rtsp://52.221.111.204:1935/live/%@", self.broadcastName];
      NSLog(@"LiveView: current broadcast name is %@", self.broadcastName);
      [self.session startLive:stream];
    }
  } else {
    [self.session stopLive];
  }
  _broadcasting = broadcasting;
}
@end
