@class User;

@interface ThumbView : UIView {
	User *user;
	NSMutableData *urlData;
}

@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSMutableData *urlData;

- (id)initWithFrame:(CGRect)frame user:(User *)theUser;
- (void)downloadThumb;

@end
