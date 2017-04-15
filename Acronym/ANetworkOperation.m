//
//  ANetworkOperation.m
//  Acronym
//
//  Created by Tarun Gupta on 2/24/17.
//  Copyright © 2017 Tarun Gupta. All rights reserved.
//

#import "ANetworkOperation.h"
#import "ResponseModel.h"

static NSString* const kRequestVideoInspirationalContentURLFormat   = @"%@://%@/?sf=%@";
static NSString* const kHostName   = @"www.nactem.ac.uk/software/acromine/dictionary.py";

static NSString* const kAIsExecuting   = @"isExecuting";
static NSString* const kAIsFinished   = @"isFinished";

/** Private category of the ANetworkOperation class */
@interface ANetworkOperation ()

/** Scanned tag content id */
@property (nonatomic, strong) NSString *ecContentID;

/** NSURL Session value */
@property (nonatomic, strong) NSURLSession *session;

/** NSURL Session Configuration value */
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;

@end

@implementation ANetworkOperation
	
	
#pragma mark - NSOperation methods
- (void)main {
	@autoreleasepool {
		[self executeOperation];
	}
}
	
- (void) start {
	// Always check for cancellation before launching the task.
	if ([self isCancelled])
	{
		// Must move the operation to the finished state if it is canceled.
		[self willChangeValueForKey:kAIsFinished];
		finished = NO;
		[self didChangeValueForKey:kAIsFinished];
		return;
	}
	else
	{
		[self willChangeValueForKey:kAIsExecuting];
		[NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
		executing = YES;
		[self didChangeValueForKey:kAIsExecuting];
		// moved task in 'executeOperation'
	}
}
	
	
#pragma mark - Create operations
- (ANetworkOperation *) initNetworkRequestOperation:(NSString *)searchString {
	self = [super init];
	if (self) {
		executing           = NO;
		finished            = NO;
		self.requestType    = kAContentInfoRequest;
		self.ecContentID	= [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	return self;
}
	
#pragma mark - Session handlers
- (NSURLSession *)session {
	if (_session == nil) {
		_session = [NSURLSession sessionWithConfiguration:[self sessionConfiguration]delegate:self
											delegateQueue: nil];
	}
	return _session;
}
	
- (NSURLSessionConfiguration *)sessionConfiguration {
	if (_sessionConfiguration == nil) {
		_sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
		_sessionConfiguration.URLCache = [NSURLCache sharedURLCache];
		_sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData; // Check for network rechability if required
		_sessionConfiguration.timeoutIntervalForRequest = 60.0;
		_sessionConfiguration.timeoutIntervalForResource = 60.0;
	}
	return _sessionConfiguration;
}
	
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
	if (error) {
		NSLog(@"Session Invalidation: %@", [error description]);
	}
	if ([session isEqual:_session]) {
		[self cleanupSession];
	}
}
	
	
#pragma mark - Operation handler
- (void)executeOperation {
	NSString *urlString = [self getUrlStringForRequest];
	
	//Changing the policy when network is available or not.
	NSMutableURLRequest * urlRequest = nil;

	// Check for network rechability if required #Tarun
	urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
										 cachePolicy:NSURLRequestReloadIgnoringCacheData
									 timeoutInterval:60];

	[[self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
	  {
		  if (!error) {
			  @try {
				  NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
				  NSLog(@"statusCode:%ld", (long)httpResp.statusCode);
				  if (httpResp.statusCode == 200) {
					  NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
					  if (responseString) {
						  NSError* jsonError = nil;
						  
						  NSDictionary* payload = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
						  
						  if (jsonError) {
							  self.error = jsonError;
							  dispatch_async(dispatch_get_main_queue(), ^{
								  self.responseBlock(nil,jsonError);
							  });
						  }
						  else {
							  [self parseResponse:payload];
						  }
					  }
				  }
				  else {
					  [self startExecuting:FALSE];
					  
					  NSError *networkError =
					  [NSError errorWithDomain: @"kANetworkErrorDomain" code: httpResp.statusCode userInfo: @{@"Key":NSLocalizedString(@"Server not Responding",@"server not responding")}];
					  self.error = networkError;
				  }
			  }
			  @catch (NSException *exception) {
				  self.error = [NSError errorWithDomain: @"kANetworkErrorDomain" code: 1005 userInfo: @{@"Key":NSLocalizedString(@"Server not Responding",@"server not responding")}];
				  
				  dispatch_async(dispatch_get_main_queue(), ^{
					  self.responseBlock(nil,self.error);
				  });
			  }
		  }
		  else {
			  if (error.code != -999) {//-999 error code for cancel request, no need to notify the controller about the cancel request.
				  [self startExecuting:FALSE];
				  self.error = error;
			  }
		  }
		  
		  dispatch_async(dispatch_get_main_queue(), ^{
			  if (finished) {
				  self.responseBlock(self.objectArray,self.error);
			  }
		  });
		  
	  }] resume];
}
	
-(void)parseResponse:(NSDictionary *)contentDict {
	switch (self.requestType) {
		case kAContentInfoRequest: {
			if(contentDict.count > 0) {
				ResponseModel *model = [ResponseModel new];
				[model setParametersValueFromDict:contentDict];
				self.objectArray = @[model];
			}
			else {
				self.objectArray = nil;
			}
			[self startExecuting:FALSE];
		}
		break;
		
		default:
		break;
	}
}
	
-(void) onCompletion:(AResponseBlock)response {
	self.responseBlock = response;
}
	
#pragma mark - Helper methods
	
-(NSString *)getUrlStringForRequest {
	NSString *scope = @"http";
	
	NSMutableString *urlString  = nil;
	
	switch (self.requestType) {
		case kAContentInfoRequest:
		urlString = [NSMutableString stringWithFormat:kRequestVideoInspirationalContentURLFormat,scope,kHostName,self.ecContentID];
		
		break;
		default:
		break;
	}
	
	NSLog(@"url string:%@ \n", urlString);
	
	return urlString;
}
	
-(void)startExecuting:(BOOL)start {
	[self willChangeValueForKey:kAIsFinished];
	[self willChangeValueForKey:kAIsExecuting];
	executing = start;
	finished = !start;
	[self didChangeValueForKey:kAIsExecuting];
	[self didChangeValueForKey:kAIsFinished];
}
	
	
- (void)cleanupSession {
	_session = nil;
}
	
- (void)endSessionAndCancelTasks {
	if (_session)
		[self.session invalidateAndCancel];
}
	
	
#pragma mark - Dealloc
- (void) dealloc {
	self.session = nil;
	self.sessionConfiguration = nil;
	self.objectArray = nil;
	self.error = nil;
	self.responseBlock = nil;
}
	
@end
