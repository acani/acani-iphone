#import <CoreLocation/CoreLocation.h>

@class InternetImage;
@class AppDelegate;

@interface UsersViewControllerOld : UIViewController {
	UIButton *selectedImage;
	InternetImage *asynchImage;
	NSMutableArray *Users;
	CLLocation *location;
	UIView *indicatorView;
	UIView *buttonLayer;
	UILabel *locNoticelabel;
}

@property (nonatomic, retain) UIButton *selectedImage;
@property (nonatomic, retain) InternetImage *asynchImage;
@property (nonatomic, retain) NSMutableArray *Users;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) UIView *indicatorView;
@property (nonatomic, retain) UIView *buttonLayer;
@property (nonatomic, retain) UILabel *locNoticelabel;
 
- (void)downloadJsonFromInternet:(NSString*) urlToImage;
- (void)jsonReady:(NSMutableArray *)users;
- (void)internetImageReady:(UIImage *)internetImage userinfo:(NSInteger)user;
- (void)reloadButtonAction:(id)sender;
- (void)loadMoreButtonAction:(id)sender;
- (void)imageSelected:(id)sender;
- (void)goToProfile:(id)sender;
- (void)login:(id)sender;
- (void)logout:(id)sender;

@end
