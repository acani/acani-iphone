#import <UIKit/UIKit.h>

@interface BubblesViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	IBOutlet UITableView *tbl;
	NSMutableArray *messages;
	IBOutlet UITextField *textfield;
	UIImageView *imageView;
	UIButton *choosePhotoBtn;
	IBOutlet UIToolbar *toolBar;
	IBOutlet UILabel *timestampLabel;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UITextField *textfield;
@property (nonatomic, retain) IBOutlet UIButton *choosePhotoBtn;
@property (nonatomic, retain) UITableView *tbl;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet UILabel *timestampLabel;

-(IBAction) getPhoto:(id) sender;
-(IBAction) slideFrameUp;
-(IBAction) slideFrameDown;
-(IBAction) push:(id)sender; 

@end
