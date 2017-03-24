/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#include <sys/types.h>
#include <sys/sysctl.h>
#include "TargetConditionals.h"

#import <Cordova/CDV.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import "CDVZebra.h"

#import "ZebraPrinterConnection.h"
#import "ZebraPrinter.h"
#import "ZebraPrinterFactory.h"
#import "TcpPrinterConnection.h"
#import "MFiBtPrinterConnection.h"

@implementation CDVZebra


- (void)scan:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        NSMutableArray *devices = [[NSMutableArray alloc] init];
        NSMutableDictionary *device = [[NSMutableDictionary alloc] init];
        
        // Check command.arguments here.
        EAAccessoryManager *manager = [EAAccessoryManager sharedAccessoryManager];
        
        self.bluetoothPrinters =[NSMutableArray arrayWithArray:manager.connectedAccessories ];
        for (EAAccessory *accessory in self.bluetoothPrinters) {
            device = @{
                       @"name": accessory.name,
                       @"serialNumber": accessory.serialNumber,
                      };
            [devices addObject:device];
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:devices ];
        // The sendPluginResult method is thread-safe.
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}
- (NSDictionary *) indexKeyedDictionaryFromArray:(NSArray *)array
{
    id objectInstance;
    NSUInteger indexKey = 0U;
    
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (objectInstance in array)
        [mutableDictionary setObject:objectInstance forKey:[NSNumber numberWithUnsignedInt:indexKey++]];
    
    return (NSDictionary *)mutableDictionary;
}
-(BOOL)printTestLabel:(PrinterLanguage) language onConnection:(id<ZebraPrinterConnection, NSObject>)connection withError:(NSError**)error {
    NSString *testLabel;
    if (language == PRINTER_LANGUAGE_ZPL) {
        testLabel = @"^XA^FO17,16^GB379,371,8^FS^FT65,255^A0N,135,134^FDTEST^FS^XZ";
        NSData *data = [NSData dataWithBytes:[testLabel UTF8String] length:[testLabel length]];
        [connection write:data error:error];
    } else if (language == PRINTER_LANGUAGE_CPCL) {
        testLabel = @"! 0 200 200 406 1\r\nON-FEED IGNORE\r\nBOX 20 20 380 380 8\r\nT 0 6 137 177 TEST\r\nPRINT\r\n";
        NSData *data = [NSData dataWithBytes:[testLabel UTF8String] length:[testLabel length]];
        [connection write:data error:error];
    }
    if(*error == nil){
        return YES;
    } else {
        return NO;
    }
}

- (void)write:(CDVInvokedUrlCommand*)command
{
    // Check command.arguments here.
    [self.commandDelegate runInBackground:^{
            CDVPluginResult* pluginResult = nil;
        
            //Getting arguments
            NSString* serialNumber = [command.arguments objectAtIndex:0];
            NSString* dataPrint = [command.arguments objectAtIndex:1];
        
            // Create connection
            id<ZebraPrinterConnection, NSObject> connection = nil;
            connection = [[MfiBtPrinterConnection alloc] initWithSerialNumber:serialNumber];
            BOOL didOpen = [connection open];
            if(didOpen == YES) {
              
                NSError *error = nil;
                id<ZebraPrinter,NSObject> printer = [ZebraPrinterFactory getInstance:connection error:&error];
                
                if(printer != nil) {
                    NSData *data = [NSData dataWithBytes:[dataPrint UTF8String] length:[dataPrint length]];
                    [connection write:data error:&error];
                
                   if(error == nil) {
                       pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Data Sent"];
                       
                    } else {
                       pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Data failed to print"];
                    }
                } else {
               
                   pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Could not Detect Language"];
                }
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Could not connect to printer"];
            }

            [connection close];
                 // The sendPluginResult method is thread-safe.
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
}
+ (NSString*)cordovaVersion
{
    return CDV_VERSION;
}

- (BOOL)isVirtual
{
#if TARGET_OS_SIMULATOR
    return true;
#elif TARGET_IPHONE_SIMULATOR
    return true;
#else
    return false;
#endif
}

@end
