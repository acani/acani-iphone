@class InternetImage;

@interface HomeViewController : UIViewController {
	IBOutlet UIScrollView *scroll;
	UIButton *selectedImage;
	InternetImage *asynchImage;
}

@property (nonatomic, retain) UIButton *selectedImage;
@property (nonatomic, retain) InternetImage *asynchImage;

- (void) downloadJsonFromInternet:(NSString*) urlToImage;
- (void) internetImageReady:(UIImage *)internetImage;
- (void) imageSelected:(id)sender;

- (void)ProfileClicked:(id)sender;
- (void)goToProfile:(id)sender;
- (void)logout:(id)sender;

@end
