#import "HomeViewController.h"
#import "PhotoViewController.h"
#import "LoversAppDelegate.h"
#import "ProfileViewController.h"
#import "InternetImage.h"
#import "User.h"
#import "ThumbnailDownload.h"

#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

UIImage *scaleAndRotateImage(UIImage *image) {
	int kMaxResolution = 75; // or whatever
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}

	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
	}

	UIGraphicsBeginImageContext(bounds.size);

	CGContextRef context = UIGraphicsGetCurrentContext();

	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	} else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}

#define offset 5
static int rCount = 1;
static int colCounter = 0;
static int rowCounter = 0;

@implementation HomeViewController
@synthesize selectedImage,asynchImage;

const enum downloadType JSON = _json;
static enum downloadType THUMBNAIL = _thumbnail;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.navigationController setNavigationBarHidden:NO];
	self.navigationController.navigationBar.tintColor = [UIColor clearColor];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Profile", @selector(goToProfile:));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Logout", @selector(logout:));

	//[self prepareImageList];
	//[self downloadJSON];
	// TODO: init with user
	// TODO: download image from facebook containing fbid from user

	//[self downloadImageFromInternet:@"http://graph.facebook.com/5/picture"];
	[self downloadJsonFromInternet:@"http://localhost:4567/users/123/123/50/50"];
}

- (void) downloadJsonFromInternet:(NSString*) urlToJson {
	// Create a instance of InternetImage
	asynchImage = [[InternetImage alloc] initWithUrl:urlToJson];

	// Start downloading the image with self as delegate receiver
	[asynchImage DownloadData:self datatype:JSON ];
}

- (void) jsonReady: (NSMutableArray *)users {
	NSLog(@"user count: %d",[users count]);

// download thumbnail images from internet and feed into users
	for (User * user in users){
		NSLog(@"user id %@", user.uid);
		NSLog(@"user fbid %d", user.fbid);
		NSString *imageUrl;
		imageUrl = [[NSString alloc] initWithFormat:@"http://localhost:4567/%@/picture", user.uid];
//		imageUrl = [[NSString alloc] initWithFormat:@"http://graph.facebook.com/%d/picture", user.fbid];
		ThumbnailDownload * thumbnailLoad = [[ThumbnailDownload alloc] initWithUrl:imageUrl];
		[thumbnailLoad DownloadData:self];

		//asynchImage.dataUrl = imageUrl;
		NSLog(@"checkpoint1");
		//[self.asynchImage DownloadData:self datatype:THUMBNAIL];
		[imageUrl release];
	}
//	[users release];
}

- (void) internetImageReady:(UIImage *)downloadedImage {	
//	UIImage * userImage = scaleAndRotateImage(downloadedImage);
	
	UIImage * userImage = downloadedImage;
	
	NSLog(@"homeviewcontroller: internetImageReady");
	// The image has been downloaded. Put the image into the UIImageView
	int totalImages = 20;
	scroll.contentSize = CGSizeMake(320,(totalImages/4 * 80));
	int xOffset = 76;
	int yOffset = 76;
//	int colCounter = 0;
//	int rowCounter = 0;
	//for(int i = 1 ; i < totalImages ; ++i)
//	{
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setImage: userImage forState:UIControlStateNormal];
		button.tag = rCount + 100;
		
	UILabel * name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 76, 10)];
	name.font = [UIFont fontWithName:@"Arial" size:12];
	name.textColor = [UIColor whiteColor];
	name.backgroundColor = [UIColor clearColor];
		name.text = @"mike";
	
	[button addSubview:name];
	UIImageView * onlineIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(69, 69, 6, 6)];
	onlineIndicator.image = [UIImage imageNamed:@"greendot.jpg" ];
	[button addSubview:onlineIndicator];
		[button addTarget:self action:@selector(imageSelected:) forControlEvents:UIControlEventTouchUpInside];
		button.frame = CGRectMake(offset + xOffset*colCounter, offset + yOffset*rowCounter,76 ,76);
		rowCounter = rCount%4 == 0 ? ++rowCounter:rowCounter;
		colCounter = (colCounter+1)%4;
		[scroll addSubview:button];
	rCount++;
	//}
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
    [super dealloc];
	[selectedImage release];
	// Abort the download. Doesn't do anything if the image has been downloaded already.
	[asynchImage abortDownload];
	// Then release.
	[asynchImage release];
}

- (void)ProfileClicked:(id)sender {
//	ProfileEditController *aController = [[ProfileEditController alloc] initWithNibName:@"ProfileEditview" bundle:nil];
//	UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:aController];
//	[self presentModalViewController:navC animated:YES];
//	[aController release];
//	[navC release];
	
//	ProfileViewController *aController = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
//	[[(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController] pushViewController:aController animated:YES];
//	[aController release];
}

- (void)imageSelected:(id)sender {
	PhotoViewController *aController = [[PhotoViewController alloc] init];
	[[(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController] pushViewController:aController animated:YES];
	[aController release];
	
	NSLog(@"Button Clicked");
	if (selectedImage) {
		selectedImage.backgroundColor = [UIColor clearColor];
	}
	self.selectedImage = (UIButton*)sender;
	[selectedImage setBackgroundColor:[UIColor colorWithRed:0.500f green:0.500f blue:0.500f alpha:0.50f]];
}

- (void)goToProfile:(id)sender {
	ProfileViewController *profileVC = [[[ProfileViewController alloc] init] autorelease];
	//	[self.navigationController pushViewController:pvc animated:YES];
	profileVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:profileVC];
	[navController setNavigationBarHidden:NO];
	
	[self presentModalViewController:navController animated:YES];
	NSLog(@"GoToProfile!");
}

- (void)logout:(id)sender {
	// Discoonect
	NSLog(@"Logout");
}

@end
