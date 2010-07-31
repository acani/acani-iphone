//
//  thumbnailDownload.m
//  Lovers
//
//  Created by Abhinav Sharma on 7/23/10.
//  Copyright 2010 Columbia University. All rights reserved.
//

#import "thumbnailDownload.h"


@implementation thumbnailDownload


@synthesize dataUrl, Image, workInProgress;

-(id) initWithUrl:(NSString*)urlToData
{
	self = [super init];
	
	if(self)
	{
		self.dataUrl = urlToData;
	}
	
	return self;
}


- (void)setDelegate:(id)new_delegate
{
    m_Delegate = new_delegate;
}	

-(void)DownloadData:(id)delegate
{
	m_Delegate = delegate;
	
	
	NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.dataUrl] 
												  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
	imageConnection = [[NSURLConnection alloc] initWithRequest:imageRequest delegate:self];
	
	if(imageConnection)
	{
		workInProgress = YES;
		if (m_ImageRequestData == nil) {
			m_ImageRequestData = [NSMutableData data];
		}
		[m_ImageRequestData retain];
		//	m_ImageRequestData = [[NSMutableData data]retain];
		//[imageRequest release];
		
	}
}

-(void)abortDownload
{
	if(workInProgress == YES)
	{
		[imageConnection cancel];
		[m_ImageRequestData release];
		workInProgress = NO;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [m_ImageRequestData setLength:0];
	
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [m_ImageRequestData appendData:data];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the data object
    [m_ImageRequestData release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	workInProgress = NO;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if(workInProgress == YES)
	{
		workInProgress = NO;
		// Create the image with the downloaded data
					
	
			NSLog(@"internetImage: connectiondidfinishloading: thumbnail");
			UIImage* downloadedImage = [[UIImage alloc] initWithData:m_ImageRequestData];
			if ([m_Delegate respondsToSelector:@selector(internetImageReady:)])
			{
				// Call the delegate method and pass ourselves along.
				[m_Delegate internetImageReady:downloadedImage];
			}
			
			[downloadedImage release];
			// send it to the caller function
			
				
		
		
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
		
		[self release];
	}	
}

- (void)dealloc 
{
    [imageConnection release];
	[dataUrl release];
	[Image release];
	[super dealloc];
}


@end
