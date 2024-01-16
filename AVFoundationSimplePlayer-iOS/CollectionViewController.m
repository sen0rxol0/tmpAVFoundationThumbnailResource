/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The primary view controller for this app.
*/

#import "CollectionViewController.h"
#import "AAPLPlayerViewController.h"
#import "Cell.h"
#import "Task.h"




//NSString *kMediaManifestURL = @"https://gist.githubusercontent.com/sen0rxol0/0b28c8a6bf4b6a632115fe85daa19a6b/raw/81a5f5f1eb5499a17d3e840753703a117cc290c4/mediamanifest.json";
NSString *kMediaManifestURL = @"http://localhost:1337/mediamanifest.json";
NSString *kCellID = @"collectionCell";      // UICollectionViewCell storyboard id

// Private properties
@interface CollectionViewController ()

@property NSMutableArray *loadedMediaManifest;

@end

@implementation CollectionViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.loadedMediaManifest) {
        
        [NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [self fetchMediaManifest];
        }];
    }
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)fetchMediaManifest {
    __weak CollectionViewController *weakSelf = self;
    
    NSURL* url = [NSURL URLWithString:kMediaManifestURL];
    NSURLSessionDataTask *mediaTask = [[NSURLSession sharedSession]
          dataTaskWithURL:url
          completionHandler:^(NSData* data, NSURLResponse* _Nullable response, NSError* _Nullable error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showAlertWithMessage:@"ERROR: Media server is not available!"];
                    });
                    return;
                }
        
                if ([data length] > 0) {
//                        NSLog(@"HERE! GOT RESPONSE FROM MEDIA SERVER.");
                    [weakSelf loadMediaManifestWithData:data];
                }
    }];
    [mediaTask resume];
}

- (void)loadMediaManifestWithData:(NSData *)jsonData
{
    NSDictionary *manifestDataDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    NSArray *assetsArray = (NSArray *)[manifestDataDict objectForKey:@"movies"];
    
    for (NSDictionary *assetDict in assetsArray) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        for (NSString *key in assetDict) {
            
            if ([@"title" isEqual:key]) {
                [dict setValue:(NSString *)assetDict[key] forKey:key];
            } else if ([@"media_url" isEqual:key]) {
//                [dict setValue:[NSURL URLWithString:assetDict[@"mediaURL"]] forKey:@"url"];
            } else if ([@"thumbnail_url" isEqual:key]) {
                NSData *thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:assetDict[key]]];
                [dict setValue:thumbnailData forKey:@"thumbnail"];
            }
            
//            NSLog(@"Value: %@ for key: %@", (id)assetDict[key], key);
        }
        
        NSString *tmpMediaURL = @"http://devimages.apple.com.edgekey.net/samplecode/avfoundationMedia/AVFoundationQueuePlayer_Progressive.mov";
        [dict setValue:[NSURL URLWithString:tmpMediaURL]  forKey:@"url"];
        
        if (!self.loadedMediaManifest) {
            self.loadedMediaManifest = [[NSMutableArray alloc] init];
        }
        
        [self.loadedMediaManifest addObject:dict];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

// MARK: UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.loadedMediaManifest count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
        Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
        //NSLog([NSString stringWithFormat:@"%ld", (long)indexPath.row]);
        //NSLog([NSString stringWithFormat:@"%@", [self.loadedMedia objectAtIndex:(long)indexPath.row]]);
        NSDictionary *mediaDict = [self.loadedMediaManifest objectAtIndex:(long)indexPath.row];

        UIImage *thumbnail = [UIImage imageWithData:mediaDict[@"thumbnail"]];
        cell.label.text = mediaDict[@"title"];
        cell.image.image = thumbnail;
//        cell.backgroundView = [[UIImageView alloc] initWithImage:thumbnail];
        return cell;
}

// the user tapped a collection item, set properties on the view controller
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPlayer"])
    {
        //NSLog(@"HERE!");
        NSIndexPath *selectedIndexPath = [self.collectionView indexPathsForSelectedItems][0];
        NSDictionary *selectedMedia = [self.loadedMediaManifest objectAtIndex:(long)selectedIndexPath.row];

        //NSURL *selectedMediaURL = selectedMedia[@"url"];
        
        NSString *bundleFullPath = [[NSBundle mainBundle] bundlePath];
        NSString *exec = [NSString stringWithFormat:@"%@/TorrentRunner/TorrentRunner", bundleFullPath];
        NSArray *args = [NSArray arrayWithObjects:@"magnet", [NSString stringWithFormat:@"\"%@\"", selectedMedia[@"tid"]], nil];
        
        NSThread *torrentThread = nil;
        torrentThread = [[NSThread alloc]
                         initWithBlock:^{
            Task *task = [[Task alloc] init];
            [task spawnTask:exec withArguments:args];
        }];
        // Set 2MB of stack space for the thread.
//        [torrentThread setStackSize:2*1024*1024];
        [torrentThread start];
        
        [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
            
            //NSURL *url = [NSURL URLWithString:@"file:///var/mobile/Downloads/"];
            NSURL *selectedMediaURL = nil;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *downloadsDirectoryContents = [fileManager contentsOfDirectoryAtPath:@"/private/var/mobile/Downloads/" error:nil];
        
            for (NSString *downloadContent in downloadsDirectoryContents) {
                NSLog(@"Download directory content: %@", downloadContent);
                if ([downloadContent containsString:selectedMedia[@"title"]]) {
                    NSArray *mediaDirectoryContents = [fileManager contentsOfDirectoryAtPath:downloadContent error:nil];
                    
                    for (NSString *mediaContent in mediaDirectoryContents) {
                        
                        NSLog(@"Media directory content: %@", mediaContent);
                        
                        if ([mediaContent containsString:@".mp4"]) {
                            selectedMediaURL = [NSURL URLWithString:[NSString stringWithFormat:@"file:///private/var/mobile/Downloads/%@/%@", downloadContent, mediaContent]];
                        }
                    }
                }
            }
  
            
            AAPLPlayerViewController *playerViewController = [segue destinationViewController];
            playerViewController.mediaURL = selectedMediaURL;
        }];
    }
}

//- (void)shellCommand:(NSString *)command
//{
//        NSString *c = [NSString stringWithFormat:@"%s >> /var/.shellCommandLog 2>&1", [command UTF8String]];
//        Task *task = [[Task alloc] init];
//        [task spawnTask:@"/var/jb/bin/bash" withArguments:[NSArray arrayWithObjects:@"-c", c, nil]];
//}

@end
