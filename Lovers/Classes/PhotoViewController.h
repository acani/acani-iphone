@class User;

@interface PhotoViewController : UIViewController {
	User *targetUser;
	UIView *overlay;
	UIView *overlaySide;
	NSMutableData *picData;
}

@property (nonatomic, retain) User *targetUser;
@property (nonatomic, retain) UIView *overlay;
@property (nonatomic, retain) UIView *overlaySide;
@property (nonatomic, retain) NSMutableData *picData;

- (void)backButtonClicked:(id)sender;
- (void)goToChat:(id)sender;
- (id)initWithUser:(User *)user;
- (void)profilePicReady:(UIImage *)downloadedImage; 
- (void)handleSingleTap;
- (void)favoriteAction:(id)sender;
- (void)blockAction:(id)sender;
- (NSString *)statusFromDate:(NSDate *)date;

@end
