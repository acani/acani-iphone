@class User;

@interface PhotoViewController : UIViewController {
	User *targetUser;
	UIView *overlay;
	UIView *overlaySide;
	UIImageView *profileImage;
	NSURLConnection *profilePicConnection;
	NSString *picUrl;
	NSString *userAbout;
	NSString *aboutHead;
	NSString *ethinic;
	NSString *likes;
	uint32_t height;
	uint32_t weight;
	NSString *location;
	NSString *laston;
	uint32_t age;
}

@property (nonatomic, retain) User *targetUser;
@property (nonatomic, retain) UIImageView *profileImage;
@property (nonatomic, retain) NSString *picUrl;
@property (nonatomic, retain) NSString *userAbout;
@property (nonatomic, retain) NSString *aboutHead;
@property (nonatomic, retain) NSString *ethinic;
@property (nonatomic, retain) NSString *likes;
@property (nonatomic, assign) uint32_t height;
@property (nonatomic, assign) uint32_t weight;
@property (nonatomic, assign) uint32_t age;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *laston;

- (void)backButtonClicked:(id)sender;
- (void)moveOverlay:(id)sender;
- (void)goToChat:(id)sender;
- (id)initWithUser:(User *)user;
- (void)profilePicReady:(UIImage *)downloadedImage; 
- (void)handleSingleTap;
- (void)favoriteAction:(id)sender;
- (void)blockAction:(id)sender;

@end
