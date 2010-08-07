@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
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
	UITableView *profileContent;
}


-(void) DatePickerDoneClick;
-(BOOL)dismissActionSheet:(id)sender;
@end
