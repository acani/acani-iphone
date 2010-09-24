#include "User.h"

#define BAR_BUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface ProfileViewController : UITableViewController <UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
	User *me;

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
}

@property (nonatomic, retain) User *me;

- (id)initWithMe:(User *)user;
- (void)doneEditingText:(id)sender;
- (void)donePickingValue:(id)sender;

@end
