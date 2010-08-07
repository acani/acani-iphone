@interface ProfileViewController : UITableViewController <UITextViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
	UINavigationController *navController;
	UIView *profileHeader;
	NSArray *profileFields;
	NSArray *descArray;
	NSArray *descArray1;
	NSArray *pickerViewArray;
	UIPickerView *pickerView;
	UIToolbar *pickerToolbar;
	UIActionSheet *aac;
}


-(void) DatePickerDoneClick;
-(BOOL)dismissActionSheet:(id)sender;
@end
