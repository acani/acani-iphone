@interface PhotoViewController : UIViewController {
	UIView * overlay;
	UIView * overlaySide;
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

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)moveOverlay:(id)sender;
- (void)goToChat:(id)sender;
- (id)initWithUrl:(NSString*)urlToImage;
- (void) profilePicReady: (UIImage*) downloadedImage; 
- (void) handleSingleTap;
- (IBAction)favoriteAction:(id)sender;
- (IBAction)blockAction:(id)sender;

@end
