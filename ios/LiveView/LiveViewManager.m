//
//  LiveViewManager.m
//  hlwintlive
//
//  Created by shwetech on 25/09/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "LiveViewManager.h"
#import <React/RCTViewManager.h>
#import "LiveView.h"
@implementation LiveViewManager
RCT_EXPORT_MODULE()
- (UIView *)view
{
  //  NSLog(@"RNFILTER: %f %f", self.view.frame.size.width, self.view.frame.size.height);
  return [[LiveView alloc] initWithBridge:self.bridge];
}

RCT_EXPORT_VIEW_PROPERTY(broadcastName, NSString);
RCT_EXPORT_VIEW_PROPERTY(broadcasting, BOOL);
RCT_EXPORT_VIEW_PROPERTY(frontCamera, BOOL);
RCT_EXPORT_VIEW_PROPERTY(onBroadcastStart, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBroadcastFail, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBroadcastStatusChange, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBroadcastEventReceive, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBroadcastErrorReceive, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBroadcastVideoEncoded, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onBroadcastStop, RCTDirectEventBlock);
- (dispatch_queue_t) methodQueue {
  return dispatch_get_main_queue();
}

- (NSArray *) customDirectEventTypes {
  return @[@"onBroadcastStart",
           @"onBroadcastFail",
           @"onBroadcastStatusChange",
           @"onBroadcastEventReceive",
           @"onBroadcastErrorReceive",
           @"onBroadcastVideoEncoded",
           @"onBroadcastStop"];
}

@end
