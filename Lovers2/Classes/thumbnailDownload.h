//
//  thumbnailDownload.h
//  Lovers
//
//  Created by Abhinav Sharma on 7/23/10.
//  Copyright 2010 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface thumbnailDownload : NSObject {

	@private NSMutableData *m_ImageRequestData;
	@private id m_Delegate;
	@private NSURLConnection *imageConnection;
	@public NSString* dataUrl;
	@public UIImage* Image;
	bool workInProgress;
	
}

@property (nonatomic, retain) NSString* dataUrl;
@property (nonatomic, retain) UIImage* Image;
@property (nonatomic, assign) bool workInProgress;

-(void)setDelegate:(id)new_delegate;
-(id)initWithUrl:(NSString*)urlToImage;
-(void)DownloadData:(id)delegate;
-(void)abortDownload;


@end
