/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The primary view controller for this app.
*/

#import "CollectionViewController.h"
#import "AAPLPlayerViewController.h"
#import "Cell.h"

NSString *kMediaManifestURL = @"https://gist.githubusercontent.com/sen0rxol0/0b28c8a6bf4b6a632115fe85daa19a6b/raw/81a5f5f1eb5499a17d3e840753703a117cc290c4/mediamanifest.json";
//NSString *kPlayerViewControllerID = @"playerViewController";      // view controller storyboard id
NSString *kCellID = @"collectionCell";      // UICollectionViewCell storyboard id

// Private properties
@interface CollectionViewController ()

@property NSMutableArray *loadedMediaManifest;

@end

@implementation CollectionViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.loadedMediaManifest) {
        NSURL* url = [NSURL URLWithString:kMediaManifestURL];
        
        __weak CollectionViewController *weakSelf = self;
        NSURLSessionDataTask *mediaTask = [[NSURLSession sharedSession]
              dataTaskWithURL:url
              completionHandler:^(NSData* data, NSURLResponse* _Nullable response, NSError* _Nullable error) {
                      if (error) {
                          return;
                      }
    //         NSLog(@"HERE!");
                    [weakSelf loadMediaManifestWithData:data];
        }];
        
        [mediaTask resume];
    }
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
        NSDictionary *titleAndThumbnail = [self.loadedMediaManifest objectAtIndex:(long)indexPath.row];
        NSData *thumbnailData = [NSData dataWithContentsOfURL:titleAndThumbnail[@"thumbnail"]];
        UIImage *thumbnail = [UIImage imageWithData:thumbnailData];
    
        cell.label.text = titleAndThumbnail[@"title"];
        cell.image.image = thumbnail;
//        cell.backgroundView = [[UIImageView alloc] initWithImage:thumbnail];
        return cell;
}

- (void)loadMediaManifestWithData:(NSData *)jsonData
{
    NSArray *assetsArray = (NSArray *)[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    for (NSDictionary *assetDict in assetsArray) {
      
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:[NSURL URLWithString:assetDict[@"mediaURL"]] forKey:@"url"];
        [dict setValue:[NSString stringWithString:assetDict[@"title"]] forKey:@"title"];
        [dict setValue:[NSURL URLWithString:assetDict[@"thumbnailURL"]] forKey:@"thumbnail"];
        
        if (!self.loadedMediaManifest) {
            self.loadedMediaManifest = [[NSMutableArray alloc] init];
        }
        
        [self.loadedMediaManifest addObject:dict];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

// the user tapped a collection item, load and set the image on the detail view controller
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPlayer"])
    {
        //NSLog(@"HERE!");
        NSIndexPath *selectedIndexPath = [self.collectionView indexPathsForSelectedItems][0];
        
        AAPLPlayerViewController *playerViewController = [segue destinationViewController];
        playerViewController.mediaURL = [self.loadedMediaManifest objectAtIndex:(long)selectedIndexPath.row][@"url"];
    }
}

@end
