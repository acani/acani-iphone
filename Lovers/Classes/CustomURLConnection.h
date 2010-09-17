@interface CustomURLConnection : NSURLConnection {
	NSString *tag;
}

@property (nonatomic, retain) NSString *tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString*)tag;

@end
