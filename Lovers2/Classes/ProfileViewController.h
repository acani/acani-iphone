@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
	UINavigationController *navController;
	UIView *profileHeader;
	NSArray *profileFields;
	NSArray *profileValues;
	NSArray *profileFields1;
	NSArray *profileValues1;
	NSArray *pickerOptions;
	NSArray *components;
	UIPickerView *valueSelect;
	UIToolbar *pickerToolbar;
	NSIndexPath *editIndexPath;
	UITextView *aboutInput;
	UITextField *valueInput;
	UITableView *profileContent;
}

@end
