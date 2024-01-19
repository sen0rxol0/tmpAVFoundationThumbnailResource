//
//  CollectionPickerViewController.h
//  PyrusPlay
//
//  Created by sen0rxol0 on 19/01/2024.
//

#import <UIKit/UIKit.h>

@interface CollectionPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *pickerData;
@end
