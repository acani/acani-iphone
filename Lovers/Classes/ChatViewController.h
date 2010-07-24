@interface ChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate> {
	NSMutableArray *messages;
		time_t	latestTimestamp;

	UITableView *chatContent;
		UILabel *msgTimestamp;
		UIImageView *msgBackground;
		UILabel *msgText;

	UIToolbar *chatToolbar;
		UITextView *chatInput;
}

@end
