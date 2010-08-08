@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
	UINavigationController *navController;
	UIView *profileHeader;
	NSArray *profileFields;
	NSArray *profileValues;
	NSArray *profileFields1;
	NSArray *profileValues1;
	NSArray *valueSelects;
	NSArray *valueSelectArray;
	UIPickerView *valueSelect;
	UIToolbar *pickerToolbar;
	NSIndexPath *editIndexPath;
	UITextView *aboutInput;
	UITableView *profileContent;
}

@end
