#import	"Constants.h"
#import "HTTPOperation.h"

#define NOTIFY_AND_LEAVE(MSG) {[self cleanup:MSG]; return;}
#define DATA(X)	[X dataUsingEncoding:NSUTF8StringEncoding]

// Posting constants
#define IMAGE_CONTENT @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
#define STRING_CONTENT @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"

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
    id boundary = @"------------0x0x0x0x0x0x0x0x";
    NSArray *keys = [dict allKeys];
    NSMutableData* result = [NSMutableData data];
	NSString *formString;

    for (int i = 0; i < [keys count]; i++) {
		id value = [dict valueForKey:[keys objectAtIndex:i]];
		[result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		if ([value isKindOfClass:[NSData class]]) { // handle image data
			formString = [NSString stringWithFormat:IMAGE_CONTENT, [keys objectAtIndex:i]];
			[result appendData:DATA(formString)];
			[result appendData:value];
		} else { // assume all non-image fields are numbers or strings
			formString = [NSString stringWithFormat:STRING_CONTENT, [keys objectAtIndex:i]];
			[result appendData:DATA(formString)];
			if ([value isKindOfClass:[NSNumber class]]) {
				value = [value stringValue];
			}
			NSLog(@"params key: %@ value: %@", formString, value);
			[result appendData:DATA(value)];
		}
		
		formString = @"\r\n";
		[result appendData:DATA(formString)];
    }

	formString =[NSString stringWithFormat:@"--%@--\r\n", boundary];
    [result appendData:DATA(formString)];
    return result;
}

- (void)main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	// Create the PUT data from the PUT dictionary
	NSData *putData = [self generateFormDataFromDictionary:params];
	
	// Establish the API request. Use upload vs uploadAndPost for skip tweet
    NSString *baseurl = [NSString stringWithFormat:@"http://%@/%@", SINATRA, oid]; 
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) NOTIFY_AND_LEAVE(@"Error creating the URL Request");
	
    [urlRequest setHTTPMethod:@"PUT"];
	[urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:putData];
	
	// Submit & retrieve results
    NSError *error;
    NSURLResponse *response;
	NSLog(@"Contacting HTTP....");
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if (!result) {
		[self cleanup:[NSString stringWithFormat:@"Submission error: %@", [error localizedDescription]]];
		return;
	}
	
	// Return results
    NSString *outstring = [[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] autorelease];
	[self cleanup:outstring];
	[pool release];
}

@end
