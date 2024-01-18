/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The primary view controller for this app.
*/

#import "CollectionViewController.h"
#import "AAPLPlayerViewController.h"
#import "Cell.h"




//NSString *kMediaManifestURL = @"https://gist.githubusercontent.com/sen0rxol0/0b28c8a6bf4b6a632115fe85daa19a6b/raw/81a5f5f1eb5499a17d3e840753703a117cc290c4/mediamanifest.json";
NSString *kMediaManifestURL = @"http://localhost:1337/mediamanifest.json";
NSString *kCellID = @"collectionCell";      // UICollectionViewCell storyboard id

// Private properties
@interface CollectionViewController ()

@property NSMutableArray *loadedMediaManifest;

@end

@implementation CollectionViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.loadedMediaManifest) {
        
        [NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [self fetchMediaManifest];
        }];
    }
}

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)fetchMediaManifest
{
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
//                        NSLog(@"GOT RESPONSE FROM MEDIA SERVER!");
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

            if ([@"thumbnail_url" isEqual:key]) {
                NSData *thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:assetDict[key]]];
                [dict setValue:thumbnailData forKey:@"thumbnail"];
            } else {
                [dict setValue:(NSString *)assetDict[key] forKey:key];
            }
            
//            NSLog(@"Value: %@ for key: %@", (id)assetDict[key], key);
        }
        
        
        if (!self.loadedMediaManifest) {
            self.loadedMediaManifest = [[NSMutableArray alloc] init];
        }
        
        [self.loadedMediaManifest addObject:dict];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma mark MARK: - UICollectionViewDataSource

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
        
        AAPLPlayerViewController *playerViewController = [segue destinationViewController];
        playerViewController.selectedMedia = [self.loadedMediaManifest objectAtIndex:(long)selectedIndexPath.row];
    }
}

@end
