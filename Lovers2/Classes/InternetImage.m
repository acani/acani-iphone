#import "LoversAppDelegate.h"
#import "InternetImage.h"
#import "SBJSON.h"
#import "User.h"
#import "Location.h"

static enum downloadType _data = _json; 

@implementation InternetImage

@synthesize dataUrl, Image, workInProgress;

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
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] valueForKey:NSErrorFailingURLStringKey]);
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
			UIImage* downloadedImage = [[UIImage alloc] initWithData:m_ImageRequestData];
			if ([m_Delegate respondsToSelector:@selector(internetImageReady:)])
			{
				// Call the delegate method and pass ourselves along.
				[m_Delegate internetImageReady:downloadedImage];
			}
			
			[downloadedImage release];
			// send it to the caller function
			
		} else if (_data == _profilepic) {
			UIImage* downloadedImage = [[UIImage alloc] initWithData:m_ImageRequestData];
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
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"]; // 2010-06-21T08:26:46+0000 => 2010-06-21 08:26:46 -0400
		NSError *error = nil;
        SBJSON *json = [[SBJSON alloc] init];    
        NSArray *results = [json objectWithString:jsonResponse error:&error];
        [json release];
        NSLog(@"result count %d",[results count]);
        for (NSDictionary *dictionary in results) {
			User *user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
			[user setAbout:[dictionary valueForKey:@"about"]];
			[user setAge:[dictionary valueForKey:@"age"]];
			[user setCreated:[dateFormatter dateFromString:[dictionary valueForKey:@"created"]]];
			[user setEthnicity:[dictionary valueForKey:@"ethnic"]];
			[user setFbid:[dictionary valueForKey:@"fbid"]];
			[user setFbLink:[dictionary valueForKey:@"fb_link"]];
			[user setHeadline:[dictionary valueForKey:@"head"]];
			[user setHeight:[dictionary valueForKey:@"height"]];
			[user setLastOnline:[dateFormatter dateFromString:[dictionary valueForKey:@"last_on"]]];
			[user setLikes:[dictionary valueForKey:@"likes"]];
			Location *location = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
			[location setLatitude:[[dictionary valueForKey:@"loc"] objectAtIndex:0]];
			[location setLongitude:[[dictionary valueForKey:@"loc"] objectAtIndex:1]];
			[user setLocation:location];
			[user setName:[dictionary valueForKey:@"name"]];
			[user setOnlineStatus:[dictionary valueForKey:@"on_stat"]];
			[user setSex:[dictionary valueForKey:@"sex"]];
			[user setShowDistance:[dictionary valueForKey:@"sdis"]];
			[user setUpdated:[dateFormatter dateFromString:[dictionary valueForKey:@"updated"]]];
			[user setUid:[[dictionary valueForKey:@"_id"] valueForKey:@"$oid"]];
			[user setWeight:[dictionary valueForKey:@"weight"]];
			[users addObject:user];
            [user release];
        }
		[dateFormatter release];
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
