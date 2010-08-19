@class InternetImage;
@class User;
@class LoversAppDelegate;

#import <CoreLocation/CoreLocation.h>

@interface HomeViewController : UIViewController {
	UIScrollView *scroll;
	UIButton *selectedImage;
	InternetImage *asynchImage;
	NSMutableArray * Users;
	CLLocation *location;
	UIView *indicatorView;
	UIView *buttonLayer;
	UILabel *locNoticelabel;
}

@property (nonatomic, retain) UIButton *selectedImage;
@property (nonatomic, retain) InternetImage *asynchImage;
@property (nonatomic, retain) NSMutableArray * Users;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) UIView *buttonLayer;
@property (nonatomic, retain) UIScrollView * scroll;
@property (nonatomic, retain) UILabel * locNoticelabel;
 
- (void) downloadJsonFromInternet:(NSString*) urlToImage;
- (void) internetImageReady:(UIImage *)internetImage userinfo:(NSInteger)user;
- (IBAction) reloadButtonAction: (id)sender;
- (IBAction) loadMoreButtonAction: (id)sender;
- (IBAction) imageSelected:(id)sender;
- (void)goToProfile:(id)sender;
- (void)logout:(id)sender;

@end
