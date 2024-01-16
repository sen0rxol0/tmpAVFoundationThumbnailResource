/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    View controller containing a player view and basic playback controls.
*/

#import "AAPLPlayerViewController.h"
#import "AAPLPlayerView.h"
#import "Spawn.h"




// Private properties
@interface AAPLPlayerViewController ()
{
    AVPlayer *_player;
    AVURLAsset *_asset;
    id<NSObject> _timeObserverToken;
    AVPlayerItem *_playerItem;
}

@property AVPlayerItem *playerItem;

@property (readonly) AVPlayerLayer *playerLayer;

@end

@implementation AAPLPlayerViewController

#pragma mark MARK: - View Handling

/*
	KVO context used to differentiate KVO callbacks for this class versus other
	classes in its class hierarchy.
*/
static void *AssetKVOContext = &AssetKVOContext;
static void *DurationKVOContext = &DurationKVOContext;
static void *StatusKVOContext = &StatusKVOContext;
static void *RateKVOContext = &RateKVOContext;

- (void)viewWillAppear:(BOOL)animated {
            [super viewWillAppear:animated];
                
    
            NSLog(@"Selected media title: %@", self.selectedMedia[@"title"]);
            NSLog(@"Selected media tid: %@", self.selectedMedia[@"tid"]);
    
            NSString *bundleFullPath = [[NSBundle mainBundle] bundlePath];
            NSString *exec = [bundleFullPath stringByAppendingString:@"/TorrentRunner/TorrentRunner"];
            NSArray *args = [NSArray arrayWithObjects:@"magnet", self.selectedMedia[@"tid"], nil];
            
            Spawn *spawn = [[Spawn alloc] init];
    
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 
                [spawn spawnTask:exec withArguments:args];

            });
            // SHOW LOADER HERE
            [NSTimer scheduledTimerWithTimeInterval:15 repeats:NO block:^(NSTimer * _Nonnull timer) {
            
                NSString *downloadsDirectory =@"/private/var/mobile/Downloads/";
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSArray *downloadsDirectoryContents = [fileManager contentsOfDirectoryAtPath:downloadsDirectory error:nil];
                
                NSURL *selectedMediaURL = nil;
                
                for (NSString *downloadContent in downloadsDirectoryContents) {

                    if ([downloadContent rangeOfString:self.selectedMedia[@"title"]].length) {
                        NSLog(@"FOUND MEDIA DIRECTORY BY TITLE: %@", downloadContent);
                        
                        NSArray *mediaDirectoryContents = [fileManager contentsOfDirectoryAtPath:[downloadsDirectory stringByAppendingString:downloadContent] error:nil];
                        
                        for (NSString *mediaContent in mediaDirectoryContents) {
                            
                            if ([mediaContent rangeOfString:@".mp4"].length) {
                                NSLog(@"FOUND MEDIA FILE: %@", mediaContent);
                                selectedMediaURL = [NSURL fileURLWithPath:[downloadsDirectory stringByAppendingFormat:@"%@/%@", downloadContent, mediaContent]];
                            }
                        }
                    }
                }
                
                self.asset = [AVURLAsset assetWithURL:selectedMediaURL];
//                self.asset = [AVURLAsset URLAssetWithURL:selectedMediaURL options:nil];
            }];
            
            /*
                Update the UI when these player properties change.
            
                Use the context parameter to distinguish KVO for our particular observers and not
                those destined for a subclass that also happens to be observing these properties.
            */
            [self addObserver:self forKeyPath:@"asset" options:NSKeyValueObservingOptionNew context:AssetKVOContext];
            [self addObserver:self forKeyPath:@"player.currentItem.duration" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:DurationKVOContext];
            [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:StatusKVOContext];
            [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:RateKVOContext];

            self.playerView.playerLayer.player = self.player;

            // Use a weak self variable to avoid a retain cycle in the block.
            AAPLPlayerViewController __weak *weakSelf = self;
            _timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                                           queue:dispatch_get_main_queue()
                                                                      usingBlock:^(CMTime time) {
                weakSelf.timeSlider.value = CMTimeGetSeconds(time);
            }];
    
            AVRoutePickerView *routerPickerView = [[AVRoutePickerView alloc]
                                                   initWithFrame:CGRectMake(CGRectGetMidX([self.avRouterPickerView bounds]), 0, 64, 64)];
            routerPickerView.activeTintColor = [UIColor clearColor];
            routerPickerView.delegate = self;
            [self.avRouterPickerView addSubview:routerPickerView];
}

- (void)viewDidDisappear:(BOOL)animated {
            [super viewDidDisappear:animated];

            if (_timeObserverToken) {
                [self.player removeTimeObserver:_timeObserverToken];
                _timeObserverToken = nil;
            }

            [self.player pause];

            [self removeObserver:self forKeyPath:@"asset" context:AssetKVOContext];
            [self removeObserver:self forKeyPath:@"player.currentItem.duration" context:DurationKVOContext];
            [self removeObserver:self forKeyPath:@"player.currentItem.status" context:StatusKVOContext];
            [self removeObserver:self forKeyPath:@"player.rate" context:RateKVOContext];
}


- (void)routePickerViewWillBeginPresentingRoutes:(AVRoutePickerView *)routePickerView {
    NSLog(@"AirPlay %@",[routePickerView valueForKey:@"airPlayActive"]);
}

- (void)routePickerViewDidEndPresentingRoutes:(AVRoutePickerView *)routePickerView {
    NSLog(@"AirPlay %@",[routePickerView valueForKey:@"airPlayActive"]);
}

- (void)showAlertWithMessage:(NSString *)message {
          UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
          UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
              
          }];
          [alert addAction:defaultAction];
          [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark MARK: - Properties

// Will attempt load and test these asset keys before playing
+ (NSArray *)assetKeysRequiredToPlay {
            return @[ @"playable", @"hasProtectedContent" ];
}

- (AVPlayer *)player {
            if (!_player)
                _player = [[AVPlayer alloc] init];
            return _player;
}

- (CMTime)currentTime {
            return self.player.currentTime;
}
- (void)setCurrentTime:(CMTime)newCurrentTime {
            [self.player seekToTime:newCurrentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (CMTime)duration {
            return self.player.currentItem ? self.player.currentItem.duration : kCMTimeZero;
}

- (float)rate {
            return self.player.rate;
}
- (void)setRate:(float)newRate {
    self.player.rate = newRate;
}

- (AVPlayerLayer *)playerLayer {
    return self.playerView.playerLayer;
}

- (AVPlayerItem *)playerItem {
    return _playerItem;
}

- (void)setPlayerItem:(AVPlayerItem *)newPlayerItem {

    if (_playerItem != newPlayerItem) {
        _playerItem = newPlayerItem;
    
        // If needed, configure player item here before associating it with a player
        // (example: adding outputs, setting text style rules, selecting media options)
        
//        [self.player setAllowsExternalPlayback:YES];
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    }
}

#pragma mark MARK: - Asset Loading

- (void)setPlayerItemWithAsset:(AVURLAsset *)newAsset
{
    if (newAsset != self.asset) {
        /*
            self.asset has already changed! No point continuing because
            another newAsset will come along in a moment.
        */
        return;
    }

    /*
        Test whether the values of each of the keys we need have been
        successfully loaded.
    */
    for (NSString *key in self.class.assetKeysRequiredToPlay) {
        NSError *error = nil;
        if ([newAsset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {

            NSString *message = [NSString localizedStringWithFormat:NSLocalizedString(@"error.asset_key_%@_failed.description",
                                                                                      @"Can't use this AVAsset because one of it's keys failed to load"), key];

            [self handleErrorWithMessage:message error:error];

            return;
        }
    }

    // We can't play this asset.
    if (!newAsset.playable || newAsset.hasProtectedContent) {
        NSString *message = NSLocalizedString(@"error.asset_not_playable.description",
                                              @"Can't use this AVAsset because it isn't playable or has protected content");

        [self handleErrorWithMessage:message error:nil];
        return;
    }

    /*
        We can play this asset. Create a new AVPlayerItem and make it
        our player's current item.
    */
    self.playerItem = [AVPlayerItem playerItemWithAsset:newAsset];
}

- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)newAsset
{

    /*
        Using AVAsset now runs the risk of blocking the current thread
        (the main UI thread) whilst I/O happens to populate the
        properties. It's prudent to defer our work until the properties
        we need have been loaded.
    */
    
    [newAsset loadValuesAsynchronouslyForKeys:self.class.assetKeysRequiredToPlay
                            completionHandler:^{

        /*
            The asset invokes its completion handler on an arbitrary queue.
            To avoid multiple threads using our internal state at the same time
            we'll elect to use the main thread at all times, let's dispatch
            our handler to the main queue.
        */
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setPlayerItemWithAsset:newAsset];
        });
    }];
}

#pragma mark MARK: - IBActions

- (IBAction)playPauseButtonWasPressed:(UIButton *)sender {
    if (self.player.rate != 1.0) {
        // not playing foward so play
        if (CMTIME_COMPARE_INLINE(self.currentTime, ==, self.duration)) {
            // at end so got back to begining
            self.currentTime = kCMTimeZero;
        }
        [self.player play];
    } else {
        // playing so pause
        [self.player pause];
    }
}

- (IBAction)rewindButtonWasPressed:(UIButton *)sender {
    self.rate = MAX(self.player.rate - 2.0, -2.0); // rewind no faster than -2.0
}

- (IBAction)fastForwardButtonWasPressed:(UIButton *)sender {
    self.rate = MIN(self.player.rate + 2.0, 2.0); // fast forward no faster than 2.0
}

- (IBAction)timeSliderDidChange:(UISlider *)sender {
    self.currentTime = CMTimeMakeWithSeconds(sender.value, 1000);
}

#pragma mark MARK: - KV Observation

// Update our UI when player or player.currentItem changes
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if ((context != AssetKVOContext) && (context != DurationKVOContext) && (context != StatusKVOContext) && (context != RateKVOContext)) {
        // KVO isn't for us.
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if ([keyPath isEqualToString:@"asset"]) {
        if (self.asset) {
            [self asynchronouslyLoadURLAsset:self.asset];
        }
    }
    else if ([keyPath isEqualToString:@"player.currentItem.duration"]) {

        // Update timeSlider and enable/disable controls when duration > 0.0

        // Handle NSNull value for NSKeyValueChangeNewKey, i.e. when player.currentItem is nil
        NSValue *newDurationAsValue = change[NSKeyValueChangeNewKey];
        CMTime newDuration = [newDurationAsValue isKindOfClass:[NSValue class]] ? newDurationAsValue.CMTimeValue : kCMTimeZero;
        BOOL hasValidDuration = CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
        double newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;

        self.timeSlider.maximumValue = newDurationSeconds;
        self.timeSlider.value = hasValidDuration ? CMTimeGetSeconds(self.currentTime) : 0.0;
        self.rewindButton.enabled = hasValidDuration;
        self.playPauseButton.enabled = hasValidDuration;
        self.fastForwardButton.enabled = hasValidDuration;
        self.timeSlider.enabled = hasValidDuration;
        self.startTimeLabel.enabled = hasValidDuration;
        self.durationLabel.enabled = hasValidDuration;
        int wholeMinutes = (int)trunc(newDurationSeconds / 60);
        self.durationLabel.text = [NSString stringWithFormat:@"%d:%02d", wholeMinutes, (int)trunc(newDurationSeconds) - wholeMinutes * 60];

    }
    else if ([keyPath isEqualToString:@"player.rate"]) {
        // Update playPauseButton image

        double newRate = [change[NSKeyValueChangeNewKey] doubleValue];
        UIImage *buttonImage = (newRate == 1.0) ? [UIImage imageNamed:@"PauseButton"] : [UIImage imageNamed:@"PlayButton"];
        [self.playPauseButton setImage:buttonImage forState:UIControlStateNormal];

    }
    else if ([keyPath isEqualToString:@"player.currentItem.status"]) {
        // Display an error if status becomes Failed

        // Handle NSNull value for NSKeyValueChangeNewKey, i.e. when player.currentItem is nil
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = [newStatusAsNumber isKindOfClass:[NSNumber class]] ? newStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;
        
        if (newStatus == AVPlayerItemStatusFailed) {
            [self handleErrorWithMessage:self.player.currentItem.error.localizedDescription error:self.player.currentItem.error];
        }

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// Trigger KVO for anyone observing our properties affected by player and player.currentItem
+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"duration"]) {
        return [NSSet setWithArray:@[ @"player.currentItem.duration" ]];
    } else if ([key isEqualToString:@"currentTime"]) {
        return [NSSet setWithArray:@[ @"player.currentItem.currentTime" ]];
    } else if ([key isEqualToString:@"rate"]) {
        return [NSSet setWithArray:@[ @"player.rate" ]];
    } else {
        return [super keyPathsForValuesAffectingValueForKey:key];
    }
}

#pragma mark MARK: - Error Handling

- (void)handleErrorWithMessage:(NSString *)message error:(NSError *)error {
    NSLog(@"Error occured with message: %@, error: %@.", message, error);
    NSString *alertTitle = NSLocalizedString(@"alert.error.title", @"Alert title for errors");
    NSString *defaultAlertMesssage = NSLocalizedString(@"error.default.description", @"Default error message when no NSError provided");
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:alertTitle message:message ?: defaultAlertMesssage preferredStyle:UIAlertControllerStyleAlert];

    NSString *alertActionTitle = NSLocalizedString(@"alert.error.actions.OK", @"OK on error alert");
    UIAlertAction *action = [UIAlertAction actionWithTitle:alertActionTitle style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
