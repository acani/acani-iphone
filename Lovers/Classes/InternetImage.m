#import "LoversAppDelegate.h"
#import "InternetImage.h"
#import "SBJSON.h"
#import "Account.h"
#import "User.h"
#import "Location.h"

static enum downloadType _data = _json; 

@implementation InternetImage

@synthesize dataUrl;
@synthesize Image;
@synthesize workInProgress;

- (id)initWithUrl:(NSString*)urlToData {
	self = [super init];
	
	if (self) {
		self.dataUrl = urlToData;
	}
	return self;
}

- (void)setDelegate:(id)new_delegate {
    m_Delegate = new_delegate;
}	

- (void)DownloadData:(id)delegate datatype:(enum downloadType)d_data {
	m_Delegate = delegate;
	_data = d_data;
	
	NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.dataUrl] 
											   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
	imageConnection = [[NSURLConnection alloc] initWithRequest:imageRequest delegate:self];
	
	if (imageConnection) {
		workInProgress = YES;
		if (m_ImageRequestData == nil) {
			m_ImageRequestData = [NSMutableData data];
		}
		[m_ImageRequestData retain];
	//	m_ImageRequestData = [[NSMutableData data]retain];
		//[imageRequest release];
	}
}

- (void)abortDownload {
	if (workInProgress == YES) {
		[imageConnection cancel];
		[m_ImageRequestData release];
		workInProgress = NO;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [m_ImageRequestData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [m_ImageRequestData appendData:data];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // release the data object
    [m_ImageRequestData release];

    // inform the user
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] valueForKey:NSURLErrorFailingURLStringErrorKey]);
	workInProgress = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (workInProgress == YES) {
		workInProgress = NO;
		// Create the image with the downloaded data
		if (_data == _json) {
			NSString *responseBody = [[NSString alloc] initWithData:m_ImageRequestData encoding:NSUTF8StringEncoding];
			NSLog(@"responseBody: %@", responseBody);
			// call create user function
			NSMutableArray * users = [self createUsers: responseBody];
			[responseBody release];
			if ([m_Delegate respondsToSelector:@selector(jsonReady:)])
			{
				// Call the delegate method and pass ourselves along.
				[m_Delegate jsonReady:users];
			}
		} else if (_data == _thumbnail) {
			NSLog(@"internetImage: connectiondidfinishloading: thumbnail");
			InternetImage* downloadedImage = [[UIImage alloc] initWithData:m_ImageRequestData];
			if ([m_Delegate respondsToSelector:@selector(internetImageReady:)])
			{
				// Call the delegate method and pass ourselves along.
				[m_Delegate internetImageReady:downloadedImage];
			}
			[downloadedImage release];
			// send it to the caller function
		} else if (_data == _profilepic) {
			InternetImage* downloadedImage = [[UIImage alloc] initWithData:m_ImageRequestData];
			// send it to the caller function
			
			if ([m_Delegate respondsToSelector:@selector(internetImageReady:)])
			{
				// Call the delegate method and pass ourselves along.
				[m_Delegate internetImageReady:downloadedImage];
			}
			[downloadedImage release];
		}
	
		//self.Image = downloadedImage;
	
		// release the data object
//		[downloadedImage release];
		[m_ImageRequestData release];
    
		
		// Verify that our delegate responds to the InternetImageReady method
		//if ([m_Delegate respondsToSelector:@selector(internetImageReady:)])
//		{
//			// Call the delegate method and pass ourselves along.
//			[m_Delegate internetImageReady:self];
//		}
	}	
}


- (NSMutableArray *)createUsers: (NSString *)jsonResponse {
	NSMutableArray *users = [NSMutableArray array];
    if (jsonResponse) {
		NSManagedObjectContext *managedObjectContext = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
		NSError *error = nil;
        SBJSON *json = [[SBJSON alloc] init];    
        NSArray *results = [json objectWithString:jsonResponse error:&error];
        [json release];
        NSLog(@"result count %d",[results count]);

		NSEnumerator *e = [results objectEnumerator];
		NSDictionary *dictionary;
	
		User *me = [User insertWithDictionary:[e nextObject] // The first result is me
					   inManagedObjectContext:managedObjectContext];
		[[(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] myAccount] setUser:me];
		if (![managedObjectContext save:&error]) {
			// Handle the error.
			NSLog(@"Error saving myAccount & me! %@", error);
		}
		[users addObject:me];

		while (dictionary = [e nextObject]) {
			[users addObject:[User insertWithDictionary:dictionary
								 inManagedObjectContext:managedObjectContext]];
		}
		NSLog(@"user: %@", [users objectAtIndex:19]);
    }

	ZTWebSocket *webSocket = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] webSocket];
	if (![webSocket connected]) {
		[webSocket open];
	} 
	
	return users;
}

- (void)dealloc 
{
    [imageConnection release];
	[dataUrl release];
	[Image release];
	[super dealloc];
}


@end
