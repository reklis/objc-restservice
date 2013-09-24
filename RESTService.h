#import <Foundation/Foundation.h>

#define HTTP_CONTENT_TYPE_NONE nil
#define HTTP_CONTENT_TYPE_TEXT @"text/plain"
#define HTTP_CONTENT_TYPE_FORM @"application/x-www-form-urlencoded"
#define HTTP_CONTENT_TYPE_JSON @"application/json"
#define HTTP_CONTENT_TYPE_XML @"application/xml"
#define HTTP_CONTENT_TYPE_ATOM @"application/atom+xml"
#define HTTP_CONTENT_TYPE_RSS @"application/rss+xml"

#define HTTP_METHOD_CONNECT @"CONNECT"
#define HTTP_METHOD_DELETE @"DELETE"
#define HTTP_METHOD_GET @"GET"
#define HTTP_METHOD_HEAD @"HEAD"
#define HTTP_METHOD_OPTIONS @"OPTIONS"
#define HTTP_METHOD_PATCH @"PATCH"
#define HTTP_METHOD_POST @"POST"
#define HTTP_METHOD_PUT @"PUT"
#define HTTP_METHOD_TRACE @"TRACE"

//Informational 1xx
#define HTTP_STATUS_CONTINUE 100
#define HTTP_STATUS_SWITCHING_PROTOCOLS 101

// Successful 2xx
#define HTTP_STATUS_OK 200
#define HTTP_STATUS_CREATED 201
#define HTTP_STATUS_ACCEPTED 202
#define HTTP_STATUS_NON_AUTHORITATIVE_INFORMATION 203
#define HTTP_STATUS_NO_CONTENT 204
#define HTTP_STATUS_RESET_CONTENT 205
#define HTTP_STATUS_PARTIAL_CONTENT 206

// Redirection 3xx
#define HTTP_STATUS_MULTIPLE_CHOICES 300
#define HTTP_STATUS_MOVED_PERMANENTLY 301
#define HTTP_STATUS_FOUND 302
#define HTTP_STATUS_SEE_OTHER 303
#define HTTP_STATUS_NOT_MODIFIED 304
#define HTTP_STATUS_USE_PROXY 305
//#define HTTP_STATUS_306 306 (UNUSED)
#define HTTP_STATUS_TEMPORARY_REDIRECT 307

// Client Error 4xx
#define HTTP_STATUS_BAD_REQUEST 400 
#define HTTP_STATUS_UNAUTHORIZED 401 
#define HTTP_STATUS_PAYMENT_REQUIRED 402 
#define HTTP_STATUS_FORBIDDEN 403 
#define HTTP_STATUS_NOT_FOUND 404 
#define HTTP_STATUS_METHOD_NOT_ALLOWED 405 
#define HTTP_STATUS_NOT_ACCEPTABLE 406 
#define HTTP_STATUS_PROXY_AUTHENTICATION_REQUIRED 407 
#define HTTP_STATUS_REQUEST_TIMEOUT 408 
#define HTTP_STATUS_CONFLICT 409 
#define HTTP_STATUS_GONE 410 
#define HTTP_STATUS_LENGTH_REQUIRED 411 
#define HTTP_STATUS_PRECONDITION_FAILED 412 
#define HTTP_STATUS_REQUEST_ENTITY_TOO_LARGE 413 
#define HTTP_STATUS_REQUEST_URI_TOO_LONG 414 
#define HTTP_STATUS_UNSUPPORTED_MEDIA_TYPE 415 
#define HTTP_STATUS_REQUESTED_RANGE_NOT_SATISFIABLE 416 
#define HTTP_STATUS_EXPECTATION_FAILED 417 

// Server Error 5xx
#define HTTP_STATUS_INTERNAL_SERVER_ERROR 500 
#define HTTP_STATUS_NOT_IMPLEMENTED 501
#define HTTP_STATUS_BAD_GATEWAY 502 
#define HTTP_STATUS_SERVICE_UNAVAILABLE 503 
#define HTTP_STATUS_GATEWAY_TIMEOUT 504 
#define HTTP_STATUS_HTTP_VERSION_NOT_SUPPORTED 505 

@interface RESTResponse : NSObject
{
    @private
    NSMutableData* responsePayload;
}

+ (id) response;

@property NSHTTPURLResponse* httpResponse;
@property NSError* httpError;

- (BOOL) isError;

- (NSData*) payload;
- (NSString*) text;
- (id) json;

- (void) appendData:(NSData*)data;

@end

typedef void (^RESTRequestCompletion) (RESTResponse* response);

#pragma mark -

@interface RESTRequest : NSObject  <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{ }

@property BOOL allowSelfSignedCertificates;
@property (weak) NSURLRequest* httpRequest;
@property (weak) NSURLConnection* connection;
@property (strong) RESTResponse* response;
@property (strong) RESTRequestCompletion completion;

+ (id) requestWithURLRequest:(NSURLRequest*)httpRequest
                  usingQueue:(NSOperationQueue*)networkingQueue
                  completion:(RESTRequestCompletion)completion;

@end

#pragma mark -

@interface RESTService : NSObject
{
@private
    NSOperationQueue* networkingQueue;
}

@property BOOL allowSelfSignedCertificates;

+ (NSString*) urlEncode:(NSString*)value;
+ (NSString*) urlDecode:(NSString*)encoded;
+ (NSString*) dataAsHexString:(NSData *)data;
+ (NSString*) objectAsJsonString:(id)jsonObject;
+ (NSDictionary*) queryParametersAsDictionary:(NSString*)queryString;
+ (NSString*) dictionaryAsQueryString:(NSString*)queryString;

- (RESTRequest*)request:(NSString *)httpMethod
            url:(NSString *)url
           body:(NSString *)requestBody
    contentType:(NSString *)contentType
     completion:(RESTRequestCompletion)completion;

@end
