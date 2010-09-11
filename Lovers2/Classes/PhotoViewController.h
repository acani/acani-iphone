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
	NSString *ethinicity;
	NSString *likes;
	NSNumber *height;
	NSNumber *weight;
	NSString *location;
	NSString *lastOnline;
	NSNumber *age;
}

@property (nonatomic, retain) User *targetUser;
@property (nonatomic, retain) UIImageView *profileImage;
@property (nonatomic, retain) NSString *picUrl;
@property (nonatomic, retain) NSString *userAbout;
@property (nonatomic, retain) NSString *aboutHead;
@property (nonatomic, retain) NSString *ethinicity;
@property (nonatomic, retain) NSString *likes;
@property (nonatomic, assign) NSNumber *height;
@property (nonatomic, assign) NSNumber *weight;
@property (nonatomic, assign) NSNumber *age;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *lastOnline;

- (void)backButtonClicked:(id)sender;
- (void)moveOverlay:(id)sender;
- (void)goToChat:(id)sender;
- (id)initWithUser:(User *)user;
- (void)profilePicReady:(UIImage *)downloadedImage; 
- (void)handleSingleTap;
- (void)favoriteAction:(id)sender;
- (void)blockAction:(id)sender;

@end
