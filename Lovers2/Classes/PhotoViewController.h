@class User;

@interface PhotoViewController : UIViewController {
	User *targetUser;
	UIView *overlay;
	UIView *overlaySide;
	UIImageView *profileImage;
	NSURLConnection *profilePicConnection;
	NSString *picUrl;
}

@property (nonatomic, retain) User *targetUser;
@property (nonatomic, retain) UIView *overlay;
@property (nonatomic, retain) UIView *overlaySide;
@property (nonatomic, retain) UIImageView *profileImage;
@property (nonatomic, retain) NSURLConnection *profilePicConnection;
@property (nonatomic, retain) NSString *picUrl;

- (void)backButtonClicked:(id)sender;
- (void)moveOverlay:(id)sender;
- (void)goToChat:(id)sender;
- (id)initWithUser:(User *)user;
- (void)profilePicReady:(UIImage *)downloadedImage; 
- (void)handleSingleTap;
- (void)favoriteAction:(id)sender;
- (void)blockAction:(id)sender;

@end
