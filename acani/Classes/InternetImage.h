enum downloadType {
	_json = 0,
	_thumbnail,
	_profilepic
};

@interface InternetImage : NSObject {
	@private NSMutableData *m_ImageRequestData;
	@private id m_Delegate;
	@private NSURLConnection *imageConnection;
	@public NSString* dataUrl;
	@public UIImage* Image;
	bool workInProgress;
	CGSize contentSize;
}

@property (nonatomic, retain) NSString* dataUrl;
@property (nonatomic, retain) UIImage* Image;
@property (nonatomic, assign) bool workInProgress;

- (void)setDelegate:(id)new_delegate;
- (id)initWithUrl:(NSString*)urlToImage;
- (void)DownloadData:(id)delegate datatype:(enum downloadType)d_data;
- (void)abortDownload;
- (NSMutableArray *)createUsers: (NSString *)jsonResponse; 

@end


@interface NSObject (InternetImageDelegate)

- (void)internetImageReady:(InternetImage*)internetImage;

@end
