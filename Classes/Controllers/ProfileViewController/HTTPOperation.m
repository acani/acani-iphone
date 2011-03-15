#import	"Constants.h"
#import "HTTPOperation.h"

#define NOTIFY_AND_LEAVE(MSG) {[self cleanup:MSG]; return;}

@implementation HTTPOperation

@synthesize oid;
@synthesize params;
@synthesize delegate;

- (void)cleanup:(NSString *)output {
	self.oid = nil;
	self.params = nil;
	if (self.delegate && [self.delegate respondsToSelector:@selector(doneWithPut:)])
		[self.delegate doneWithPut:output];
}

- (NSData*)generateFormDataFromDictionary:(NSDictionary*)dict {
    NSArray *keys = [dict allKeys];
    NSMutableData *body = [NSMutableData data];
	NSString *formString;

    for (int i = 0; i < [keys count]; i++) {
		id value = [dict valueForKey:[keys objectAtIndex:i]];
		formString = [NSString stringWithFormat:@"--%@\r\n", kStringBoundary];
		[body appendData:DATA_FROM_STRING(formString)];
		
		if ([value isKindOfClass:[NSData class]]) { // handle image data
			formString = [NSString stringWithFormat:kImageContent, [keys objectAtIndex:i]];
			[body appendData:DATA_FROM_STRING(formString)];
			[body appendData:value];
		} else { // assume all non-image fields are numbers or strings
			formString = [NSString stringWithFormat:kStringContent, [keys objectAtIndex:i]];
			[body appendData:DATA_FROM_STRING(formString)];
			if ([value isKindOfClass:[NSNumber class]]) {
				value = [value stringValue];
			}
			NSLog(@"params key: %@ value: %@", formString, value);
			[body appendData:DATA_FROM_STRING(value)];
		}

		formString = @"\r\n";
		[body appendData:DATA_FROM_STRING(formString)];
    }

	formString = [NSString stringWithFormat:@"--%@--\r\n", kStringBoundary];
    [body appendData:DATA_FROM_STRING(formString)];
    return body;
}

- (void)main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	// Create the PUT data from the PUT dictionary
	NSData *putData = [self generateFormDataFromDictionary:params];
	
	// Establish the API request. Use upload vs uploadAndPost for skip tweet
    NSString *baseurl = [NSString stringWithFormat:@"http://%@/%@", kHost, oid]; 
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) NOTIFY_AND_LEAVE(@"Error creating the URL Request");
	
    [urlRequest setHTTPMethod:@"PUT"];
	[urlRequest setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
	[urlRequest setValue:kMultipart forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:putData];
	
	// Send request and receive response.
    NSError *error;
    NSURLResponse *response;
	NSLog(@"Contacting HTTP....");
    NSData *body = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if (!body) {
		[self cleanup:[NSString stringWithFormat:@"Submission error: %@", [error localizedDescription]]];
		return;
	}
	
	// Return results.
    NSString *outstring = [[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] autorelease];
	[self cleanup:outstring];
	[pool release];
}

@end
