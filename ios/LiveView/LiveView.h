//
//  LiveView.h
//  hlwintlive
//
//  Created by shwetech on 25/09/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTView.h>
#import <React/RCTBridge.h>

@interface LiveView: UIView
- (id)initWithBridge:(RCTBridge *)bridge;
@end
