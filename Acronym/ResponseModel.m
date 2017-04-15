//
//  ResponseModel.m
//  Acronym
//
//  Created by Tarun Gupta on 2/24/17.
//  Copyright © 2017 Tarun Gupta. All rights reserved.
//

#import "ResponseModel.h"

static NSString* const kALongFormTitle  = @"lfs";
static NSString* const kALongFormSubTitle  = @"lf";

@implementation ResponseModel
	
-(void)setParametersValueFromDict:(NSDictionary *)tagInfoDict {
	if(!tagInfoDict)
		return;
	self.contentArray = [[NSMutableArray alloc] init];
	[self setContentArray:[[[tagInfoDict valueForKey:kALongFormTitle] valueForKey:kALongFormSubTitle] firstObject]];
}
		
@end
