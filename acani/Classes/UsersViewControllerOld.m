#import "Constants.h"
#import "UsersViewControllerOld.h"
#import "PhotoViewController.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "InternetImage.h"
#import "ThumbnailDownload.h"
#import "User.h"

//UIImage *scaleAndRotateImage(UIImage *image) {
//	int kMaxResolution = 75; // or whatever
//	
//	CGImageRef imgRef = image.CGImage;
//	
//	CGFloat width = CGImageGetWidth(imgRef);
//	CGFloat height = CGImageGetHeight(imgRef);
//	
//	CGAffineTransform transform = CGAffineTransformIdentity;
//	CGRect bounds = CGRectMake(0, 0, width, height);
//	if (width > kMaxResolution || height > kMaxResolution) {
//		CGFloat ratio = width/height;
//		if (ratio > 1) {
//			bounds.size.width = kMaxResolution;
//			bounds.size.height = bounds.size.width / ratio;
//		}
//		else {
//			bounds.size.height = kMaxResolution;
//			bounds.size.width = bounds.size.height * ratio;
//		}
//	}
//
//	CGFloat scaleRatio = bounds.size.width / width;
//	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
//	CGFloat boundHeight;
//	UIImageOrientation orient = image.imageOrientation;
//	switch(orient) {
//		case UIImageOrientationUp: //EXIF = 1
//			transform = CGAffineTransformIdentity;
//			break;
//			
//		case UIImageOrientationUpMirrored: //EXIF = 2
//			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
//			transform = CGAffineTransformScale(transform, -1.0, 1.0);
//			break;
//			
//		case UIImageOrientationDown: //EXIF = 3
//			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
//			transform = CGAffineTransformRotate(transform, M_PI);
//			break;
//			
//		case UIImageOrientationDownMirrored: //EXIF = 4
//			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
//			transform = CGAffineTransformScale(transform, 1.0, -1.0);
//			break;
//			
//		case UIImageOrientationLeftMirrored: //EXIF = 5
//			boundHeight = bounds.size.height;
//			bounds.size.height = bounds.size.width;
//			bounds.size.width = boundHeight;
//			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
//			transform = CGAffineTransformScale(transform, -1.0, 1.0);
//			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
//			break;
//			
//		case UIImageOrientationLeft: //EXIF = 6
//			boundHeight = bounds.size.height;
//			bounds.size.height = bounds.size.width;
//			bounds.size.width = boundHeight;
//			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
//			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
//			break;
//			
//		case UIImageOrientationRightMirrored: //EXIF = 7
//			boundHeight = bounds.size.height;
//			bounds.size.height = bounds.size.width;
//			bounds.size.width = boundHeight;
//			transform = CGAffineTransformMakeScale(-1.0, 1.0);
//			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
//			break;
//			
//		case UIImageOrientationRight: //EXIF = 8
//			boundHeight = bounds.size.height;
//			bounds.size.height = bounds.size.width;
//			bounds.size.width = boundHeight;
//			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
//			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
//			break;
//			
//		default:
//			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
//	}
//
//	UIGraphicsBeginImageContext(bounds.size);
//
//	CGContextRef context = UIGraphicsGetCurrentContext();
//
//	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
//		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
//		CGContextTranslateCTM(context, -height, 0);
//	} else {
//		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
//		CGContextTranslateCTM(context, 0, -height);
//	}
//	
//	CGContextConcatCTM(context, transform);
//	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
//	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();
//	
//	return imageCopy;
//}

#define OFFSET 4
static int rCount = 1;
static int colCounter = 0;
static int rowCounter = 0;
BOOL buttonLayerPresent = NO;

@implementation UsersViewControllerOld

@synthesize selectedImage;
@synthesize asynchImage;
@synthesize Users;
@synthesize location;
@synthesize indicatorView;
@synthesize buttonLayer;
@synthesize locNoticelabel;

const enum downloadType JSON = _json;
//static enum downloadType THUMBNAIL = _thumbnail;

- (void)setLocation:(CLLocation *)_location{
	if (self.location != _location) {
		[location release];
		location = [_location retain];
	}
	NSLog(@"loc %6d", location.horizontalAccuracy);
	self.locNoticelabel.text = [[NSString alloc] initWithFormat:@"Accuracy +-%.1f mts", location.horizontalAccuracy];
	NSString *myOid = [(User *)[[(AppDelegate *)[[UIApplication sharedApplication] delegate] myAccount] user] oid];
	NSLog(@"myOid %@", myOid == nil ? @"0" : myOid);
	NSString *tempUrl = [NSString stringWithFormat:@"http://%@/users/%@/%@/%f/%f",
						 SINATRA,
						 myOid == nil ? @"0" : myOid,
						 [[UIDevice currentDevice] uniqueIdentifier],
						 location.coordinate.latitude, location.coordinate.longitude];
	[self downloadJsonFromInternet: tempUrl];
	NSLog(@"%@", tempUrl);
}

-(void)loadView {
	UIScrollView *localScroll = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	localScroll.backgroundColor = [UIColor whiteColor];
	self.view = localScroll;
	[localScroll release];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.wantsFullScreenLayout = YES;
	// TODO: make the navBar title a logo.
	self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];

	UIBarButtonItem *profileButton = BAR_BUTTON(@"Profile", @selector(goToProfile:));
	self.navigationItem.rightBarButtonItem = profileButton;
	[profileButton release];

//	self.loginButton = BAR_BUTTON(@"Login", @selector(login:));
//	self.logoutButton = BAR_BUTTON(@"Logout", @selector(login:));

	indicatorView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
	
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[indicatorView addSubview:activityIndicator];
	self.locNoticelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 400, 110, 20)];
	self.locNoticelabel.font =  [UIFont systemFontOfSize:10.0];
	self.locNoticelabel.textAlignment = UITextAlignmentCenter;
	self.locNoticelabel.text = @"Finding Location";
	self.locNoticelabel.textColor = [UIColor whiteColor];
	self.locNoticelabel.backgroundColor = [UIColor blackColor];
	self.locNoticelabel.alpha = 0.65;
	
	//[indicatorView addSubview:locNoticelabel];
	[self.view addSubview: self.locNoticelabel];
	[self.view addSubview:indicatorView];
	[activityIndicator startAnimating];
	
	[activityIndicator release];
	[self.locNoticelabel release];
	[indicatorView release];
	//[self downloadImageFromInternet:@"http://graph.facebook.com/5/picture"];
	//[self downloadJsonFromInternet:@"http://localhost:4567/users/123/123/50/50"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

- (void)downloadJsonFromInternet:(NSString*)urlToJson {
	// Create a instance of InternetImage
	[indicatorView removeFromSuperview];
	
	asynchImage = [[InternetImage alloc] initWithUrl:urlToJson];

	// Start downloading the image with self as delegate receiver
	[asynchImage DownloadData:self datatype:JSON];
}

- (void)jsonReady:(NSMutableArray *)users {	
	NSLog(@"user count: %d",[users count]);
	self.Users = users;
// download thumbnail images from internet and feed into users
	for (int i = 0; i < [self.Users count]; i++){
		User *user = [self.Users objectAtIndex:i];
		//NSLog(@"user id %@", user.oid);
		//NSLog(@"user fbid %d", user.fbid);
		NSString *imageUrl = [[NSString alloc] initWithFormat:@"http://%@/%@/picture", SINATRA, [user oid]];
//		imageUrl = [[NSString alloc] initWithFormat:@"http://graph.facebook.com/%d/picture", user.fbid];
		ThumbnailDownload * thumbnailLoad = [[ThumbnailDownload alloc] initWithUrl:imageUrl userInfo:i];
		[thumbnailLoad DownloadData:self];

		//asynchImage.dataUrl = imageUrl;
		//NSLog(@"checkpoint1");
		//[self.asynchImage DownloadData:self datatype:THUMBNAIL];
		[imageUrl release];
	}
	
	double tempY = ([self.Users count]/4)* 80;
	[(UIScrollView *)self.view setContentSize:CGSizeMake(320,((100/4) * 80))];
	NSLog(@"tempY : %f", tempY);
	//TODO: feed in the load more and refresh button
	if (buttonLayerPresent == YES) {
		//[self removeFromSuperview];
		NSLog(@"removing button layer");
	}
	
	self.buttonLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 400, 320, 40)];
	self.buttonLayer.backgroundColor = [UIColor clearColor];
	
	UIButton * reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	reloadButton.frame = CGRectMake(0, tempY, 150, 40);
	reloadButton.backgroundColor = [UIColor whiteColor];
	[reloadButton addTarget:self action:@selector(reloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[reloadButton setTitle:@"reload" forState:UIControlStateNormal];
	reloadButton.titleLabel.textColor = [UIColor blackColor];
	
	UIButton * loadMoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	loadMoreButton.frame = CGRectMake(170, tempY, 150, 40);
	
	loadMoreButton.backgroundColor = [UIColor whiteColor];
	[loadMoreButton setTitle:@"load more" forState:UIControlStateNormal];
	[loadMoreButton addTarget:self action:@selector(loadMoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:loadMoreButton];
	[self.view addSubview:reloadButton];
	//[self.buttonLayer addSubview: reloadButton];
	//[self.buttonLayer addSubview: loadMoreButton];
	
	//[self.view addSubview:buttonLayer];
	
	[self.buttonLayer release];
	
//	[users release];
}

- (void) internetImageReady:(UIImage *)downloadedImage userinfo:(NSInteger)user{	
//	UIImage * userImage = scaleAndRotateImage(downloadedImage);
	//[user retain];
	UIImage * userImage = downloadedImage;
	
	NSLog(@"homeviewcontroller: internetImageReady");
	// The image has been downloaded. Put the image into the UIImageView
	//int totalImages = 100;
	
	int xOffset = 79;
	int yOffset = 79;
//	int colCounter = 0;
//	int rowCounter = 0;

	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage: userImage forState:UIControlStateNormal];
	button.tag = user;
		
	UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 75, 10)];
	name.font = [UIFont fontWithName:@"Arial" size:12];
	name.textColor = [UIColor whiteColor];
	name.backgroundColor = [UIColor clearColor];
	name.text = @"mike";
	
	[button addSubview:name];
	UIImageView * onlineIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(69, 69, 6, 6)];
	onlineIndicator.image = [UIImage imageNamed:@"greendot.jpg" ];
	[button addSubview:onlineIndicator];
	[button addTarget:self action:@selector(imageSelected:) forControlEvents:UIControlEventTouchUpInside];
	button.frame = CGRectMake(OFFSET + xOffset*colCounter, OFFSET + yOffset*rowCounter, 75, 75);
	rowCounter = rCount%4 == 0 ? ++rowCounter:rowCounter;
	colCounter = (colCounter+1)%4;
	[self.view addSubview:button];
	rCount++;
	//[user release];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[selectedImage release];
	// Abort download. Doesn't do anything if image has been downloaded already.
	[asynchImage abortDownload];
	[asynchImage release]; // then release.
	[Users release];
	[location release];
	[indicatorView release];
	[buttonLayer release];
	[locNoticelabel release];
    [super dealloc];
}

- (void)reloadButtonAction:(id)sender{
	NSLog(@"reload Button Action");
	//[self.view release];
	//[self loadView];
}

- (void)loadMoreButtonAction:(id)sender {
	NSLog(@"load more button called");
}

- (void)imageSelected:(id)sender {
	NSLog(@"Button Clicked");
	if (selectedImage) {
		selectedImage.backgroundColor = [UIColor clearColor];
	}
	self.selectedImage = (UIButton*)sender;
	[selectedImage setBackgroundColor:[UIColor colorWithRed:0.500f green:0.500f blue:0.500f alpha:0.50f]];
	User *user = [self.Users objectAtIndex:selectedImage.tag];
	
	PhotoViewController *aController = [(PhotoViewController *)[PhotoViewController alloc] initWithUser:user];
	[[(AppDelegate *)[[UIApplication sharedApplication] delegate] navigationController] pushViewController:aController animated:YES];
	[aController release];
}

- (void)goToProfile:(id)sender {
	ProfileViewController *profileVC = [[ProfileViewController alloc] initWithMe:[Users objectAtIndex:0]];
	profileVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:profileVC];
	[profileVC release];
	[self presentModalViewController:navController animated:YES];
	[navController release];
}

#define TERMS_ALERT 901
#define	REVIEW 1
#define	LOGOUT_ALERT 902
#define LOGOUT 1

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(int)index {
	printf("User selected button %d\n", index);
	switch (alertView.tag) {
		case LOGOUT_ALERT:
			if (index == LOGOUT) {
				[[(AppDelegate *)[[UIApplication sharedApplication] delegate] webSocket] close];
			}
			break;
		case TERMS_ALERT:
			if (index == REVIEW) {
				UIApplication *app = [UIApplication sharedApplication];
				[app openURL:[NSURL URLWithString:@"http://www.acani.com/terms"]];
			}
			break;
	}
	[alertView release];
}
	
/*
// Flash alertView on first login:
Terms of Service
 * I am a male at least 18 years old.
 * I understand that acani allows other users to see my relative distance. I can choose to hide my distance if I prefer not to have this information displayed.
 * I will not post any adult/sexual photos or text in my profile.
 * I will not post any profane/foul language in my profile.
 * I will not post or exchange any content that is unlawful, harassing, abusive, or threatening in any way.
 * I will not solicit, advertise, or offer any commercial services.
 * I have reviewed the acani Terms of Service and understand that any violation of any of these terms will result in the immediate banning of my acani account.
Review | Agree
*/

- (void)showAlert:(NSString *)message {
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Logout" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
	av.tag = LOGOUT_ALERT;
	[av show];
}

- (void)logout:(id)sender {
	// Only display this alert on first logout.
	if (YES) {
		[self showAlert:@"If you logout, you will no longer be visible in acani and will not be able to chat with other users."];
	} else {
		[[(AppDelegate *)[[UIApplication sharedApplication] delegate] webSocket] close];
		// Then go to loginView like Facebook iPhone app does.
	}
}

- (void)login:(id)sender {
	[[(AppDelegate *)[[UIApplication sharedApplication] delegate] webSocket] open];
}

@end
