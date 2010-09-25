#include "User.h"
#include "FBConnect.h"

#define BAR_BUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface ProfileViewController : UITableViewController <UITextViewDelegate, UITextFieldDelegate,
UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate,
UIActionSheetDelegate, FBSessionDelegate, FBRequestDelegate, FBDialogDelegate> {
	User *me;
	Facebook *fb;

	UIBarButtonItem *saveButton;
	UIBarButtonItem *doneButton; // appears only when the picker is open
	UIBarButtonItem *textDone;  // appears only when the keyboard is open

	UIButton *avatarImg;
	UITextField *profileName;
	UITextField *headlineInput;

	UITextView *aboutInput;
	UITextField *valueInput;

	NSArray *profileFields;
	NSArray *pickerOptions;
	NSArray *components;
	UIPickerView *valueSelect;
	NSIndexPath *editIndexPath;
	NSInteger editTextTag;
}

@property (nonatomic, retain) User *me;
@property (nonatomic, retain) Facebook *fb;

@property (nonatomic, retain) UIBarButtonItem *saveButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;
@property (nonatomic, retain) UIBarButtonItem *textDone;

@property (nonatomic, retain) UIButton *avatarImg;
@property (nonatomic, retain) UITextField *profileName;
@property (nonatomic, retain) UITextField *headlineInput;

@property (nonatomic, retain) UITextView *aboutInput;
@property (nonatomic, retain) UITextField *valueInput;

@property (nonatomic, retain) NSArray *profileFields;
@property (nonatomic, retain) NSArray *pickerOptions;
@property (nonatomic, retain) NSArray *components;
@property (nonatomic, retain) UIPickerView *valueSelect;
@property (nonatomic, retain) NSIndexPath *editIndexPath;
@property (nonatomic) NSInteger editTextTag;

- (id)initWithMe:(User *)user;
- (void)doneEditingText:(id)sender;
- (void)donePickingValue:(id)sender;

@end
