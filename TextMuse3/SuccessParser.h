//
//  SuccessParser.h
//  TextMuse
//
//  Created by Peter Tucker on 7/28/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuccessParser : NSObject<NSXMLParserDelegate>

@property (readonly) int ExplorerPoints;
@property (readonly) int SharerPoints;
@property (readonly) int MusePoints;

-(id)initWithXml:(NSData*)xml;

@end
