@class User;


@interface ThumbnailDownload : NSObject {
	@private NSMutableData *m_ImageRequestData;
	@private id m_Delegate;
	@private NSURLConnection *imageConnection;
	@public NSString* dataUrl;
	@public UIImage* Image;
	bool workInProgress;
	NSInteger user;
	
}

@property (nonatomic, retain) NSString* dataUrl;
@property (nonatomic, retain) UIImage* Image;
@property (nonatomic, assign) bool workInProgress;
@property (nonatomic, assign) NSInteger  user;

- (void)setDelegate:(id)new_delegate;
- (id)initWithUrl:(NSString*)urlToImage userInfo:(NSInteger)user_i;
- (void)DownloadData:(id)delegate;
- (void)abortDownload;

@end
