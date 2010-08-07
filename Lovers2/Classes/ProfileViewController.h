@interface ProfileViewController : UITableViewController <UITextViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
	UINavigationController *navController;
	UIView *profileHeader;
	NSArray *profileFields;
	NSArray *profileValues;
	NSArray *profileFields1;
	NSArray *profileValues1;
	NSArray *pickerViewArray;
	UIPickerView *pickerView;
	UIToolbar *pickerToolbar;
	UIActionSheet *aac;
	NSIndexPath *editIndexPath;
	UITextView *aboutInput;
}


-(void) DatePickerDoneClick;
-(BOOL)dismissActionSheet:(id)sender;
@end
