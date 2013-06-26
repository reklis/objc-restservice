objc-restservice
================

stupid simple http requests for api use


usage example
=============

	rest = [[RESTService alloc] init];
	
	# ifdef STAGING_ENV
	rest.allowSelfSignedCertificates = YES;
	# endif
	
    UIDevice* currentDevice = [UIDevice currentDevice];
    
    NSString* vendorid = [[currentDevice identifierForVendor] UUIDString];
    NSString* vendordescription = [currentDevice name];
    NSString* systemname = [currentDevice systemName];
    NSString* systemversion = [currentDevice systemVersion];
    NSString* modelname = [currentDevice model];
    NSString* devicetokenhex = [RESTService dataAsHexString:deviceToken];
    
    NSString* requestBody = [NSString stringWithFormat:@"token=%@&vendorid=%@&vendordescription=%@&systemname=%@&systemversion=%@&modelname=%@&devicetoken=%@",
                             self.authToken,
                             [RESTService urlEncode:vendorid],
                             [RESTService urlEncode:vendordescription],
                             [RESTService urlEncode:systemname],
                             [RESTService urlEncode:systemversion],
                             [RESTService urlEncode:modelname],
                             devicetokenhex
                             ];
    NSString* resourceURL = [self pathToResource:DENDRITE_API_USER_DEVICE];
    
    [rest request:HTTP_METHOD_POST
              url:resourceURL
             body:requestBody
      contentType:HTTP_CONTENT_TYPE_FORM
       completion:^(RESTResponse *response) {
           if ([response isError]) {
               NSLog(@"Error: %@ Body: %@", [response httpError], [response text]);
           } else {
               NSLog(@"%@", [response json]);
           }
       }];



