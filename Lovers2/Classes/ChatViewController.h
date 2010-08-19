#import "ZTWebSocket.h"

@interface ChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, ZTWebSocketDelegate> {
	ZTWebSocket *webSocket;

	NSMutableArray *messages;
		time_t	latestTimestamp;

	UITableView *chatContent;
		UILabel *msgTimestamp;
		UIImageView *msgBackground;
		UILabel *msgText;

	UIImageView *chatBar;
		UITextView *chatInput;
			CGFloat lastContentHeight;
			Boolean chatInputHadText;
		UIButton *sendButton;
}

@property (nonatomic, retain) ZTWebSocket *webSocket;

@end
