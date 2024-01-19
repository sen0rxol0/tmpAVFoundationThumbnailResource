//
//  CollectionPickerViewController.m
//  PyrusPlay
//
//  Created by sen0rxol0 on 19/01/2024.
//

#import <Foundation/Foundation.h>
#import "CollectionPickerViewController.h"
#import "CollectionViewController.h"


@interface CollectionPickerViewController ()

@end

@implementation CollectionPickerViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;

    self.pickerData = [NSArray arrayWithObjects:@"Frequent",@"Newest",@"Popular",@"Ratings",nil];
}


#pragma mark MARK: - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return [self.pickerData count];
}

#pragma mark MARK: - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [self.pickerData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow: (NSInteger)row
       inComponent:(NSInteger)component
{
    NSLog(@"Selected collection: %@", [self.pickerData objectAtIndex:row]);
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCollection"])
    {
        NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
        CollectionViewController *collectionViewController = [segue destinationViewController];
        collectionViewController.collectionTitle = [self.pickerData objectAtIndex:selectedRow];
    }
}

@end
