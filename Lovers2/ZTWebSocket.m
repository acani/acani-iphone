//
//  ZTWebSocket.m
//  Zimt
//
//  Created by Esad Hajdarevic on 2/14/10.
//  Copyright 2010 OpenResearch Software Development OG. All rights reserved.
//

#import "ZTLog.h"
#import "ZTWebSocket.h"
#import "AsyncSocket.h"


NSString* const ZTWebSocketErrorDomain = @"ZTWebSocketErrorDomain";
NSString* const ZTWebSocketException = @"ZTWebSocketException";

enum {
    ZTWebSocketTagHandshake = 0,
    ZTWebSocketTagMessage = 1
};

@implementation ZTWebSocket

@synthesize delegate, url, origin, connected, runLoopModes;

#pragma mark Initializers

+ (id)webSocketWithURLString:(NSString*)urlString delegate:(id<ZTWebSocketDelegate>)aDelegate {
    return [[[ZTWebSocket alloc] initWithURLString:urlString delegate:aDelegate] autorelease];
}

-(id)initWithURLString:(NSString *)urlString delegate:(id<ZTWebSocketDelegate>)aDelegate {
    if ((self = [super init])) {
        self.delegate = aDelegate;
        url = [[NSURL URLWithString:urlString] retain];
        if (![url.scheme isEqualToString:@"ws"]) {
            [NSException raise:ZTWebSocketException format:@"Unsupported protocol %@",url.scheme];
        }
        socket = [[AsyncSocket alloc] initWithDelegate:self];
        self.runLoopModes = [NSArray arrayWithObjects:NSRunLoopCommonModes, nil];
    }
    return self;
}

#pragma mark Delegate dispatch methods

-(void)_dispatchFailure:(NSNumber*)code {
    if(delegate && [delegate respondsToSelector:@selector(webSocket:didFailWithError:)]) {
        [delegate webSocket:self didFailWithError:[NSError errorWithDomain:ZTWebSocketErrorDomain code:[code intValue] userInfo:nil]];
    }
}

-(void)_dispatchClosed {
    if (delegate && [delegate respondsToSelector:@selector(webSocketDidClose:)]) {
        [delegate webSocketDidClose:self];
    }
}

-(void)_dispatchOpened {
    if (delegate && [delegate respondsToSelector:@selector(webSocketDidOpen:)]) {
        [delegate webSocketDidOpen:self];
    }
}

-(void)_dispatchMessageReceived:(NSString*)message {
    if (delegate && [delegate respondsToSelector:@selector(webSocket:didReceiveMessage:)]) {
        [delegate webSocket:self didReceiveMessage:message];
    }
}

-(void)_dispatchMessageSent {
    if (delegate && [delegate respondsToSelector:@selector(webSocketDidSendMessage:)]) {
        [delegate webSocketDidSendMessage:self];
    }
}

#pragma mark Private

-(void)_readNextMessage {
    [socket readDataToData:[NSData dataWithBytes:"\xFF" length:1] withTimeout:-1 tag:ZTWebSocketTagMessage];
}

-(void)_sendWebSocketHandshake {
    NSString* requestOrigin = self.origin;
    if (!requestOrigin) requestOrigin = [NSString stringWithFormat:@"http://%@",url.host];
    
    NSString *requestPath = url.path;
    
    // If the url is something like 'ws://localhost', the requestPath should be '/'. 
    if ([requestPath isEqualToString:@""]) {
        requestPath = @"/";
    }
	
    if (url.query) {
        requestPath = [requestPath stringByAppendingFormat:@"?%@", url.query];
    }
    NSString* getRequest = [NSString stringWithFormat:@"GET %@ HTTP/1.1\r\n"
                            "Upgrade: WebSocket\r\n"
                            "Connection: Upgrade\r\n"
                            "Host: %@\r\n"
                            "Origin: %@\r\n"
                            "\r\n",
                            requestPath,url.host,requestOrigin];
    [socket writeData:[getRequest dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:ZTWebSocketTagHandshake];
}

-(void)_sendNow:(NSString*)message {
    NSMutableData* data = [NSMutableData data];
    [data appendBytes:"\x00" length:1];
    [data appendData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendBytes:"\xFF" length:1];
    [socket writeData:data withTimeout:-1 tag:ZTWebSocketTagMessage];    
}

-(void)_flushSendQueue {
    if (queuedMessages != nil) {
        for (NSString *message in queuedMessages) {
            [self _sendNow:message];
        }
        
        [queuedMessages release];
        queuedMessages = nil;
    }
}

#pragma mark Public interface

-(void)close {
    // ZTWebSocket keeps a read operation pending, so disconnectAfterReading won't close the socket
    // until another packet is received.
    [socket disconnectAfterWriting];
}

-(void)open {
    if (!connected) {
        [socket connectToHost:url.host onPort:[url.port intValue] withTimeout:-1 error:nil];
//        [socket connectToHost:url.host onPort:[url.port intValue] withTimeout:5 error:nil];

        if (runLoopModes) [socket setRunLoopModes:runLoopModes];
        
        // This will be queued up and sent by asyncsocket as soon as the TCP connection is
        // established.
        [self _sendWebSocketHandshake];
    }
}

-(void)send:(NSString*)message {
    if (connected) {
        [self _sendNow:message];
    } else {
        // Because of asyncsocket's send queue, we could just pass the messages to asyncsocket
        // immediately even if we haven't connected yet. However, encryption will add some overhead
        // which will invalidate that method.
        if (queuedMessages == nil)  {
            queuedMessages = [[NSMutableArray alloc] init];
        }
        
        NSString *messageCopy = [message copy];
        [queuedMessages addObject:messageCopy];
        [messageCopy release];
    }
}

#pragma mark AsyncSocket delegate methods

-(void)onSocketDidDisconnect:(AsyncSocket *)sock {
    connected = NO;
    [self _dispatchClosed];
}

-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    if (!connected) {
        [self _dispatchFailure:[NSNumber numberWithInt:ZTWebSocketErrorConnectionFailed]];
    } else {
        [self _dispatchClosed];
    }
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {

}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == ZTWebSocketTagHandshake) {
        [sock readDataToData:[@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:ZTWebSocketTagHandshake];
    } else if (tag == ZTWebSocketTagMessage) {
        [self _dispatchMessageSent];
    }
}

-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (tag == ZTWebSocketTagHandshake) {
        NSString* response = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
        if ([response hasPrefix:@"HTTP/1.1 101 Web Socket Protocol Handshake\r\nUpgrade: WebSocket\r\nConnection: Upgrade\r\n"]) {
            connected = YES;
            [self _dispatchOpened];
            
            [self _flushSendQueue];
            [self _readNextMessage];
        } else {
            [self _dispatchFailure:[NSNumber numberWithInt:ZTWebSocketErrorHandshakeFailed]];
        }
    } else if (tag == ZTWebSocketTagMessage) {
        char firstByte = 0xFF;
        [data getBytes:&firstByte length:1];
        if (firstByte != 0x00) return; // Discard message
        NSString* message = [[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(1, [data length]-2)] encoding:NSUTF8StringEncoding] autorelease];
    
        [self _dispatchMessageReceived:message];
        [self _readNextMessage];
    }
}

#pragma mark Destructor

-(void)dealloc {
    socket.delegate = nil;
    [socket disconnect];
    [socket release];
    [runLoopModes release];
    [url release];
    [queuedMessages release];
    [super dealloc];
}

@end

