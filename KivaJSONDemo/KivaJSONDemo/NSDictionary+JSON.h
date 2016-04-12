//
//  NSDictionary+JSON.h
//  KivaJSONDemo
//
//  Created by James Valaitis on 08/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

+ (NSDictionary *)	dictionaryWithContentsOfJSONURLString:	(NSString *)	url;

- (NSData *)		toJSON;

@end
