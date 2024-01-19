/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	View controller containing a player view and basic playback controls.
*/

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <CoreMedia/CMTime.h>
#import <UIKit/UIKit.h>

@class AAPLPlayerView;

@interface AAPLPlayerViewController : UIViewController <AVRoutePickerViewDelegate>

@property (readonly) AVPlayer *player;
@property AVURLAsset *asset;

@property NSDictionary *selectedMedia;

@property CMTime currentTime;
@property (readonly) CMTime duration;
@property float rate;

@property (weak) IBOutlet UISlider *timeSlider;
@property (weak) IBOutlet UILabel *startTimeLabel;
@property (weak) IBOutlet UILabel *durationLabel;
@property (weak) IBOutlet UIButton *rewindButton;
@property (weak) IBOutlet UIButton *playPauseButton;
@property (weak) IBOutlet UIButton *fastForwardButton;
@property (weak) IBOutlet AAPLPlayerView *playerView;
@property (weak) IBOutlet UIView *playerControlsView;
@property (weak) IBOutlet UIView *avRouterPickerView;

@property (weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

