#import "PhotoViewController.h"
#import "ChatViewController.h"
#import "User.h"
#import "Location.h"
#import "Constants.h"
#import "LoversAppDelegate.h"

@implementation PhotoViewController

@synthesize targetUser;
@synthesize overlay;
@synthesize overlaySide;
@synthesize profileImage;
@synthesize profilePicConnection;
@synthesize picUrl;

BOOL overlayHide;
BOOL workInProgress;
NSMutableData *picData;

- (id)initWithUser:(User *)user {
	if (self = [super init]) {
		self.targetUser = user;
		self.title = [user name];
		self.picUrl = [NSString stringWithFormat:@"http://%@/%@/picture?type=large", SINATRA, [targetUser uid]];
		[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackTranslucent];
		self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
		self.wantsFullScreenLayout = YES;
	}
	
	NSURL *picUrl_t = [NSURL URLWithString:self.picUrl];
	NSURLRequest *imageRequest = [NSURLRequest requestWithURL:picUrl_t 
												  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
	profilePicConnection = [[NSURLConnection alloc] initWithRequest:imageRequest delegate:self];
	
	if (profilePicConnection) {
		workInProgress = YES;
		if (picData == nil) {
			picData = [NSMutableData data];
		}
		[picData retain];
	}
	return self;
}

- (void)goToChat:(id)sender {
	ChatViewController *chatView = [[ChatViewController alloc] init];
	chatView.channel = [NSString stringWithFormat:@"%@_%@", @"myid", [targetUser uid]];
	chatView.title = targetUser.name;
	[self.navigationController pushViewController:chatView animated:YES];
	[chatView release];
}

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	contentView.backgroundColor = [UIColor cyanColor];
	profileImage = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	profileImage.image = [UIImage imageNamed:@"blankprofile.jpg"];
	[contentView addSubview:profileImage];
	NSLog(@"view is loading");
//	[self.navigationController setNavigationBarHidden:NO];

	UIBarButtonItem *chatButton = BAR_BUTTON(@"Chat", @selector(goToChat:));
	self.navigationItem.rightBarButtonItem = chatButton;
	[chatButton release];
	
	UITapGestureRecognizer *singleFingerDTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    singleFingerDTap.numberOfTapsRequired = 1;
	[contentView addGestureRecognizer:singleFingerDTap];
    [singleFingerDTap release];
	
	self.view = contentView;
	[contentView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 320, 320, 160 )];
	overlay.backgroundColor = [UIColor clearColor];
	//overlay.alpha = 0.5;
	
	UILabel *userAboutHead = [[UILabel alloc] initWithFrame:CGRectMake(25, 5, 280, 30)];
	userAboutHead.text = [targetUser headline];
	userAboutHead.backgroundColor = [UIColor clearColor];
	userAboutHead.shadowColor = [UIColor blackColor];
	userAboutHead.textColor = [UIColor whiteColor];
	[overlay addSubview:userAboutHead];
	[userAboutHead release];

	CGSize aboutLabelSize = [[targetUser about] sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(280.0f, 100.0f) lineBreakMode:UILineBreakModeWordWrap];
	
	UILabel *aboutLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 35, aboutLabelSize.width, aboutLabelSize.height)];
	aboutLabel.lineBreakMode = UILineBreakModeWordWrap;
	aboutLabel.numberOfLines = 0;
	aboutLabel.text = [targetUser about];
	aboutLabel.font = [UIFont systemFontOfSize:12.0];
	aboutLabel.backgroundColor = [UIColor clearColor];
	aboutLabel.shadowColor = [UIColor blackColor];
	aboutLabel.textColor = [UIColor whiteColor];
	[overlay addSubview:aboutLabel];
	[aboutLabel release];
	[self.view addSubview:overlay];

	overlaySide = [[UIView alloc] initWithFrame:CGRectMake(160, 10, 150, 310)];
	overlaySide.backgroundColor = [UIColor clearColor];

	// Lots of repetition here. Keep code DRY (Donot Repeat Yourself). Refactor with: 
	//   (1) macro, or (2) function, or (3) subclass UILabel & redefine init.
	// Also, labals should be created & displayed only if corresponding value !- nil
	// They should also be positioned vertically w/o gaps.
	// So, the origin.y should be a variable and only incremented if value != nil
	UILabel *locationLabel =   [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
	UILabel *lastOnlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 150, 15)];
	UILabel *ageLabel =        [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 150, 15)];
	UILabel *likesLabel =      [[UILabel alloc] initWithFrame:CGRectMake(0, 35, 150, 15)];
	UILabel *heightLabel =     [[UILabel alloc] initWithFrame:CGRectMake(0, 65, 150, 15)];
	UILabel *weightLabel =     [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 150, 15)];
	UILabel *ethnicityLabel =  [[UILabel alloc] initWithFrame:CGRectMake(0, 95, 150, 15)];
	UILabel *sexLabel =        [[UILabel alloc] initWithFrame:CGRectMake(0, 110, 150, 15)];
	
	locationLabel.backgroundColor =   [UIColor clearColor];
	lastOnlineLabel.backgroundColor = [UIColor clearColor];
	ageLabel.backgroundColor =        [UIColor clearColor];
	likesLabel.backgroundColor =      [UIColor clearColor];
	heightLabel.backgroundColor =     [UIColor clearColor];
	weightLabel.backgroundColor =     [UIColor clearColor];
	ethnicityLabel.backgroundColor =  [UIColor clearColor];
	sexLabel.backgroundColor =        [UIColor clearColor];

	locationLabel.shadowColor =   [UIColor blackColor];
	lastOnlineLabel.shadowColor = [UIColor blackColor];
	ageLabel.shadowColor =        [UIColor blackColor];
	likesLabel.shadowColor =      [UIColor blackColor];
	heightLabel.shadowColor =     [UIColor blackColor];
	weightLabel.shadowColor =     [UIColor blackColor];
	ethnicityLabel.shadowColor =  [UIColor blackColor];
	sexLabel.shadowColor =        [UIColor blackColor];

	locationLabel.textColor =   [UIColor whiteColor];
	lastOnlineLabel.textColor = [UIColor whiteColor];
	ageLabel.textColor =        [UIColor whiteColor];
	likesLabel.textColor =      [UIColor whiteColor];
	heightLabel.textColor =     [UIColor whiteColor];
	weightLabel.textColor =     [UIColor whiteColor];
	ethnicityLabel.textColor =  [UIColor whiteColor];
	sexLabel.textColor =        [UIColor whiteColor];
	
	locationLabel.font =   [UIFont systemFontOfSize:14.0];
	lastOnlineLabel.font = [UIFont systemFontOfSize:12.0];
	ageLabel.font =        [UIFont systemFontOfSize:12.0];
	likesLabel.font =      [UIFont systemFontOfSize:12.0];
	heightLabel.font =     [UIFont systemFontOfSize:12.0];
	weightLabel.font =     [UIFont systemFontOfSize:12.0];
	ethnicityLabel.font =  [UIFont systemFontOfSize:12.0];
	sexLabel.font =        [UIFont systemFontOfSize:12.0];
	
	locationLabel.textAlignment =   UITextAlignmentRight;
	lastOnlineLabel.textAlignment = UITextAlignmentRight;
	ageLabel.textAlignment =        UITextAlignmentRight;
	likesLabel.textAlignment =      UITextAlignmentRight;
	heightLabel.textAlignment =     UITextAlignmentRight;
	weightLabel.textAlignment =     UITextAlignmentRight;
	ethnicityLabel.textAlignment =  UITextAlignmentRight;
	sexLabel.textAlignment =        UITextAlignmentRight;

	CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:[[[targetUser location] latitude] doubleValue]
															longitude:[[[targetUser location] longitude] doubleValue]];
	locationLabel.text = [NSString stringWithFormat:@"%.1f meters away",
						  [[(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] bestEffortAtLocation]
						  distanceFromLocation:targetLocation]]; // @"420 feet away";
	[targetLocation release];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"]; // make user friendly with function below
	lastOnlineLabel.text = [dateFormatter stringFromDate:[targetUser lastOnline]]; // @"Online 10 mins ago";
	[dateFormatter release];

	NSArray *Sexes = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] Sexes];
	NSArray *Ethnicities = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] Ethnicities];
	NSArray *Likes = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] Likes];

	ageLabel.text =       [NSString stringWithFormat:@"%@ years old", [targetUser age]];
	likesLabel.text =     [NSString stringWithFormat:@"Likes %@",
						   [[Likes objectAtIndex:[[targetUser likes] intValue]] lowercaseString]];
	heightLabel.text =    [NSString stringWithFormat:@"%@ cm", [targetUser height]];
	weightLabel.text =    [NSString stringWithFormat:@"%@ lbs", [targetUser weight]];
	ethnicityLabel.text = [[Ethnicities objectAtIndex:[[targetUser ethnicity] intValue]] capitalizedString];
	sexLabel.text =       [[Sexes objectAtIndex:[[targetUser sex] intValue]] capitalizedString];

	UIButton * favorite = [UIButton buttonWithType:UIButtonTypeCustom];
	favorite.frame = CGRectMake(70, 230, 30, 30);
	[favorite setImage:[UIImage imageNamed:@"gold-star-2.jpg" ] forState:UIControlStateNormal];
	[favorite addTarget:self action:@selector(favoriteAction:) forControlEvents:UIControlEventTouchUpInside];

	UILabel *favoriteLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 260, 50, 10)];
	favoriteLabel.text = @"favorite";
	favoriteLabel.backgroundColor = [UIColor clearColor];
	favoriteLabel.textColor = [UIColor whiteColor];
	favoriteLabel.font =  [UIFont systemFontOfSize:10.0];
	
	UIButton * block = [UIButton buttonWithType:UIButtonTypeCustom];
	block.frame = CGRectMake(70, 270, 30, 30);
	[block setImage:[UIImage imageNamed:@"BlockButton.png"] forState:UIControlStateNormal];
	[block addTarget:self action:@selector(blockAction:) forControlEvents:UIControlEventTouchUpInside];
	
	UILabel *blockLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 300, 50, 10)];
	blockLabel.text = @"block";
	blockLabel.backgroundColor = [UIColor clearColor];
	blockLabel.textColor = [UIColor whiteColor];
	blockLabel.font =  [UIFont systemFontOfSize:10.0];
	
//	moveMe.backgroundColor = [UIColor whiteColor];
//	moveMe.titleLabel.text = @"move";
//	moveMe.titleLabel.textColor = [UIColor blackColor];
//	[moveMe addTarget:self action:@selector(moveOverlay:) forControlEvents:UIControlEventTouchUpInside];

	[overlaySide addSubview:locationLabel];
	[locationLabel release];
	[overlaySide addSubview:lastOnlineLabel];
	[lastOnlineLabel release];
	[overlaySide addSubview:likesLabel];
	[likesLabel release];
	[overlaySide addSubview:heightLabel];
	[heightLabel release];
	[overlaySide addSubview:weightLabel];
	[weightLabel release];
	[overlaySide addSubview:ageLabel];
	[ageLabel release];
	[overlaySide addSubview:ethnicityLabel];
	[ethnicityLabel release];
	[overlaySide addSubview:favorite];
	[overlaySide addSubview:favoriteLabel];
	[favoriteLabel release];
	[overlaySide addSubview:block];
	[overlaySide addSubview:blockLabel];
	[blockLabel release];
	[self.view addSubview:overlaySide];
}

- (void) profilePicReady:(UIImage*)downloadedImage {
	self.profileImage.image = downloadedImage;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)backButtonClicked:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)favoriteAction:(id)sender{
//TODO: implement favorite functionality

}

- (void)blockAction:(id)sender{

//TODO: implement block functionality

}

- (void)moveOverlay:(id)sender {
	if (self.view.window!=nil) {
		[UIView beginAnimations:@"move_Overlay" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.3f];
		
		//headerView.alpha = 0.0;
		overlay.frame = CGRectMake(overlay.frame.origin.x, -160, overlay.frame.size.width, overlay.frame.size.height) ;
		//backBtn.alpha = 0.0;
		
		[UIView commitAnimations];
	}
}


#pragma mark singlFingerTap methods

- (void) handleSingleTap {
	NSLog(@"handleSingleTap");
	if (self.view.window != nil) {
		if (overlayHide == NO) {
		[UIView beginAnimations: @"move_Overlay" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.3f];
		
		//headerView.alpha = 0.0;
		overlay.frame = CGRectMake(overlay.frame.origin.x, 640, overlay.frame.size.width, overlay.frame.size.height) ;
		overlaySide.frame = CGRectMake(320, overlaySide.frame.origin.y, overlaySide.frame.size.width, overlaySide.frame.size.height) ;
		//backBtn.alpha = 0.0;
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
		[self.navigationController setNavigationBarHidden:YES];

		
		[UIView commitAnimations];
		overlayHide = YES;
		} else if (overlayHide == YES) {
			[UIView beginAnimations: @"move_Overlay" context:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
			[UIView setAnimationDuration:0.3f];
			
			//headerView.alpha = 0.0;
			overlay.frame = CGRectMake(overlay.frame.origin.x, 320, overlay.frame.size.width, overlay.frame.size.height) ;
			overlaySide.frame = CGRectMake(210, overlaySide.frame.origin.y, overlaySide.frame.size.width, overlaySide.frame.size.height) ;
			//backBtn.alpha = 0.0;
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
			[self.navigationController setNavigationBarHidden:NO];
			
			[UIView commitAnimations];
			overlayHide = NO;
		}
	}
}


#pragma mark Internet access methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [picData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [picData appendData:data];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // release the data object
    [picData release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@. ", [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	workInProgress = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (workInProgress == YES) {
		workInProgress = NO;
		// Create the image with the downloaded data
		NSLog(@"internetImage: connectiondidfinishloading: profilePic");
		UIImage* downloadedImage = [[UIImage alloc] initWithData:picData];
		if ([self respondsToSelector:@selector(profilePicReady:)]) {
			// Call the delegate method and pass ourselves along.
			[self profilePicReady:downloadedImage];
		}
		
		[downloadedImage release];
		// send it to the caller function
		
		//self.Image = downloadedImage;
		
		// release the data object
		//		[downloadedImage release];
		[picData release];
		
		// Verify that our delegate responds to the InternetImageReady method
		//if ([m_Delegate respondsToSelector:@selector(internetImageReady:)])
		//		{
		//			// Call the delegate method and pass ourselves along.
		//			[m_Delegate internetImageReady:self];
		//		}
		
		//[self release];
	}	
}

//- (NSString*)timestamp {
//    // Calculate distance time string
//    //
//    time_t now;
//    time(&now);
//    
//    int distance = (int)difftime(now, lastOnline);
//    if (distance < 0) distance = 0;
//    
//    if (distance < 60) {
//        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "second ago" : "seconds ago"];
//    }
//    else if (distance < 60 * 60) {  
//        distance = distance / 60;
//        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "minute ago" : "minutes ago"];
//    }  
//    else if (distance < 60 * 60 * 24) {
//        distance = distance / 60 / 60;
//        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "hour ago" : "hours ago"];
//    }
//    else if (distance < 60 * 60 * 24 * 7) {
//        distance = distance / 60 / 60 / 24;
//        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "day ago" : "days ago"];
//    }
//    else if (distance < 60 * 60 * 24 * 7 * 4) {
//        distance = distance / 60 / 60 / 24 / 7;
//        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "week ago" : "weeks ago"];
//    }
//    else {
//        static NSDateFormatter *dateFormatter = nil;
//        if (dateFormatter == nil) {
//            dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
//            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//        }
//        
//        NSDate *date = [NSDate dateWithTimeIntervalSince1970:createdAt];        
//        self.timestamp = [dateFormatter stringFromDate:date];
//    }
//    return timestamp;
//}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.targetUser = nil;
	self.overlay = nil;
	self.overlaySide = nil;
	[profileImage release];
	self.profileImage = nil;
	self.profilePicConnection = nil;
	self.picUrl = nil;
}

- (void)dealloc {	
	[overlay release];
	[overlaySide release];
	[profilePicConnection release];
    [super dealloc];
}

@end
