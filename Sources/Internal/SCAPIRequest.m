//
//  SCAPIRequest.m
//  SnapchatHax
//
//  Created by Alex Nichol on 12/17/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <NSData+CommonCrypto.h>

#import "SCAPIRequest.h"

@implementation SCAPIRequest

+ (NSString *)timestampString {
    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    return [NSString stringWithFormat:@"%llu", (unsigned long long)round(time * 1000.0)];
}

+ (NSString *)encodeQueryParam:(NSString *)param {
    NSMutableString * str = [NSMutableString string];
    for (NSInteger i = 0; i < param.length; i++) {
        unichar aChar = [param characterAtIndex:i];
        if (isalnum(aChar)) {
            [str appendFormat:@"%C", aChar];
        } else {
            [str appendFormat:@"%%%02X", (unsigned char)aChar];
        }
    }
    return str;
}

+ (NSString *)encodeQuery:(NSDictionary *)dict {
    NSMutableString * str = [NSMutableString string];
    
    for (NSString * key in dict) {
        if (str.length) [str appendString:@"&"];
        [str appendFormat:@"%@=%@", [self encodeQueryParam:key],
         [self encodeQueryParam:[dict[key] description]]];
    }
    
    return str;
}

- (id)initWithConfiguration:(SCAPIConfiguration *)enc
                       path:(NSString *)path
                      token:(NSString *)token
                 dictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        [self setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", enc.baseURL, path]]];
        [self setHTTPMethod:@"POST"];
        NSMutableDictionary * jsonBody = [dict mutableCopy];
        NSString * timestamp = self.class.timestampString;
        jsonBody[@"req_token"] = [enc dualHash:[token dataUsingEncoding:NSUTF8StringEncoding]
                                       andHash:[timestamp dataUsingEncoding:NSUTF8StringEncoding]];
        jsonBody[@"timestamp"] = @([timestamp longLongValue]);
        NSData * encoded = [[self.class encodeQuery:jsonBody] dataUsingEncoding:NSASCIIStringEncoding];
        [self setHTTPBody:encoded];
        [self setValue:[NSString stringWithFormat:@"%d", (int)encoded.length]
    forHTTPHeaderField:@"Content-Length"];
        [self setValue:enc.userAgent forHTTPHeaderField:@"User-Agent"];
        [self setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [self addValue:@"en;q=1" forHTTPHeaderField: @"Accept-Language"];
        [self addValue:@"en_US" forHTTPHeaderField: @"Accept-Locale"];
        [self addValue:@"gzip" forHTTPHeaderField: @"Accept-Encoding"];
    }
    return self;
}

- (id)initMultipartWithConfiguration:(SCAPIConfiguration *)enc
                                path:(NSString *)path
                               token:(NSString *)token
                          dictionary:(NSDictionary *)dict
                            filePath:(NSString *)filePath
                            fileName:(NSString *)name
{
    if ((self = [super init])) {
        [self setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", enc.baseURL, path]]];
        [self setHTTPMethod:@"POST"];
        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        NSString *boundary = @"Boundary+0xAbCdEfGbOuNdArY";
        NSString *endBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
        [self setValue:enc.userAgent forHTTPHeaderField:@"User-Agent"];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [self addValue:contentType forHTTPHeaderField: @"Content-Type"];
        [self addValue:@"en;q=1" forHTTPHeaderField: @"Accept-Language"];
        [self addValue:@"en_US" forHTTPHeaderField: @"Accept-Locale"];
        [self addValue:@"gzip" forHTTPHeaderField: @"Accept-Encoding"];

        NSString * timestamp = self.class.timestampString;

        NSMutableData *tempPostData = [NSMutableData data];
        [tempPostData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

        [tempPostData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"req_token"] dataUsingEncoding:NSUTF8StringEncoding]];
        [tempPostData appendData:[[enc dualHash:[token dataUsingEncoding:NSUTF8StringEncoding]
                                       andHash:[timestamp dataUsingEncoding:NSUTF8StringEncoding]] dataUsingEncoding:NSUTF8StringEncoding]];
        [tempPostData appendData:[endBoundary dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        [tempPostData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"timestamp"] dataUsingEncoding:NSUTF8StringEncoding]];
        [tempPostData appendData:[[@([timestamp longLongValue]) stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
        [tempPostData appendData:[endBoundary dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        for (NSString* key in dict) {
            [tempPostData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [tempPostData appendData:[[dict valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
            [tempPostData appendData:[endBoundary dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [tempPostData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"data\"; filename=\"%@\"\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
        [tempPostData appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        NSData * encrypted = [[NSData dataWithContentsOfFile:filePath] dataEncryptedUsingAlgorithm:kCCAlgorithmAES128 key:@"M02cnQ51Ji97vwT4" initializationVector:nil options:kCCOptionPKCS7Padding|kCCOptionECBMode error:nil];
        [tempPostData appendData:encrypted];
        [tempPostData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self setHTTPBody:tempPostData];
    }
    return self;
}

@end
