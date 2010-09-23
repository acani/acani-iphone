@class User;

@protocol HTTPOperationDelegate <NSObject>
- (void)doneWithPut:(NSString *)status;
@end

@interface HTTPOperation : NSOperation {
//	UIImage *picture; // this should be made related to me (Profile)
//	User *me;
	NSString *oid;
	NSDictionary *params;
	id <HTTPOperationDelegate> delegate;
}

//@property (retain) UIImage *picture;
//@property (retain) User *me;
@property (retain) NSString *oid;
@property (retain) NSDictionary *params;
@property (retain) id delegate;

- (void)cleanup:(NSString *)output;
- (NSData*)generateFormDataFromDictionary:(NSDictionary*)dict;

@end
