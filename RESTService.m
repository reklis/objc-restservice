#import "RESTService.h"

@implementation RESTService

- (id)init
{
    self = [super init];
    if (self) {
        networkingQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

+ (NSString *)dataAsHexString:(NSData *)data
{
    NSMutableString* hexString = [[NSMutableString alloc] init];
    
    // build a comma delimited string of 0xNN style hex representation of each byte
    const char* dataBytes = [data bytes];
    for (int i = 0; i < [data length]; ++i) {
        if (i != 0) {
            [hexString appendString:@","];
        }
        [hexString appendFormat:@"0x%02hhx", (unsigned char) dataBytes[i]];
    }
    
    return hexString;
}

+ (NSString*) urlEncode:(NSString*)value
{
    return [[[[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
              stringByReplacingOccurrencesOfString:@":" withString:@"%3A"]
             stringByReplacingOccurrencesOfString:@"," withString:@"%2C"]
            stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
}

+ (NSString *)objectAsJsonString:(id)jsonObject
{
    NSError* error = nil;
    NSData* serialized = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&error];
    if (error) {
        return nil;
    } else {
        return [[NSString alloc] initWithData:serialized encoding:NSUTF8StringEncoding];
    }
}

- (RESTRequest*) request:(NSString *)httpMethod
            url:(NSString *)url
           body:(NSString *)requestBody
    contentType:(NSString *)contentType
     completion:(RESTRequestCompletion)completion
{
    NSMutableURLRequest* urlReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [urlReq setHTTPMethod:httpMethod];
    
    if (HTTP_CONTENT_TYPE_NONE != contentType) {
        NSData* payload = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
        [urlReq setValue:contentType forHTTPHeaderField:@"Content-Type"];
        [urlReq setValue:[NSString stringWithFormat:@"%u", [payload length]] forHTTPHeaderField:@"Content-Length"];
        [urlReq setHTTPBody:payload];
    }
    
    RESTRequest* req = [RESTRequest requestWithURLRequest:urlReq
                                               usingQueue:networkingQueue
                        completion:^(RESTResponse *response) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(response);
                            });
                        }];
    
    req.allowSelfSignedCertificates = self.allowSelfSignedCertificates;
    
    return req;
}

@end

#pragma mark -

@implementation RESTRequest

+ (id)requestWithURLRequest:(NSURLRequest *)httpRequest
                 usingQueue:(NSOperationQueue *)networkingQueue
                 completion:(RESTRequestCompletion)completion
{
    RESTRequest* req = [[RESTRequest alloc] init];
    
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:httpRequest
                                                                  delegate:req
                                                          startImmediately:NO];
    [connection setDelegateQueue:networkingQueue];
    
    req.httpRequest = httpRequest;
    req.connection = connection;
    req.completion = completion;
    
    [connection start];
    
    return req;
}

+ (id)requestWithConnection:(NSURLConnection *)connection completion:(RESTRequestCompletion)completion
{
    RESTRequest* req = [[RESTRequest alloc] init];
    req.connection = connection;
    req.completion = completion;
    return req;
}


#pragma NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection: %@ didFailWithError: %@", connection, error);
    self.response = [RESTResponse response];
    self.response.httpError = error;
    self.completion(self.response);
}

//- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
//{
//    
//}

-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (self.allowSelfSignedCertificates) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }
}

#pragma NSURLConnectionDataDelegate

//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
//{
//}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = [RESTResponse response];
    self.response.httpResponse = (NSHTTPURLResponse*) response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.response appendData:data];
}

//- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
//{
//    
//}

//- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
// totalBytesWritten:(NSInteger)totalBytesWritten
//totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
//{
//
//}

//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
//{
//
//}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.completion(self.response);
}

@end

#pragma mark -

@implementation RESTResponse

+ (id)response
{
    RESTResponse* rep = [[RESTResponse alloc] init];
    return rep;
}

- (BOOL) isError
{
    return (self.httpError || self.httpResponse.statusCode != HTTP_STATUS_OK);
}

- (NSData*) payload
{
    return responsePayload;
}

- (NSString*) text
{
    NSString* s = [[NSString alloc] initWithData:responsePayload encoding:NSUTF8StringEncoding];
    return s;
}

- (id) json
{
    if (!responsePayload) {
        return nil;
    }
    
    NSError* readError = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:responsePayload options:0 error:&readError];
    if (readError) {
        NSLog(@"RESTResponse NSJSONSerialization JSONObjectWithData Error %@", readError);
    }
    return jsonObj;
}

- (void) appendData:(NSData*)data
{
    if (!responsePayload) {
        responsePayload = [[NSMutableData alloc] init];
    }
    [responsePayload appendData:data];
}

@end