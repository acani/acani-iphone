@class InternetImage;
@class User;

@interface HomeViewController : UIViewController {
	IBOutlet UIScrollView *scroll;
	UIButton *selectedImage;
	InternetImage *asynchImage;
	NSMutableArray * Users;
}

@property (nonatomic, retain) UIButton *selectedImage;
@property (nonatomic, retain) InternetImage *asynchImage;
@property (nonatomic, retain) NSMutableArray * Users;

- (void) downloadJsonFromInternet:(NSString*) urlToImage;
- (void) internetImageReady:(UIImage *)internetImage userinfo:(NSInteger)user;
- (IBAction) imageSelected:(id)sender;

- (void)ProfileClicked:(id)sender;
- (void)goToProfile:(id)sender;
- (void)logout:(id)sender;

@end
