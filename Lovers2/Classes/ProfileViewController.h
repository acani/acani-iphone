#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface ProfileViewController : UITableViewController <UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
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
	UIBarButtonItem *saveButton;
	UIBarButtonItem *doneButton; // this button appears only when the picker is open
	UIBarButtonItem *textDone;
	UIButton *avatarImg;
	UITextField *profileName;
	UISwitch *filter;
}

@end
