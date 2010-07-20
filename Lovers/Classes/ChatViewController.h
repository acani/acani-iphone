@interface ChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate> {
	NSMutableArray *messages;
	UITextView *textView;
	UILabel *timestampLabel;
	UIImageView *backgroundImageView;
	UILabel *textLabel;
}

@end
