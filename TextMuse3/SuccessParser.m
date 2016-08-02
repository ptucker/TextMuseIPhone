//
//  SuccessParser.m
//  TextMuse
//
//  Created by Peter Tucker on 7/28/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import "SuccessParser.h"
#import "Settings.h"

@implementation SuccessParser

-(id)initWithXml:(NSData*)xml {
    self = [super init];
    
    _ExplorerPoints = 0;
    _SharerPoints = 0;
    _MusePoints = 0;
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xml];
    [parser setDelegate:self];
    [parser parse];
    
    return self;
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"success"]) {
        _ExplorerPoints = [[attributeDict objectForKey:@"ep"] intValue];
        _SharerPoints = [[attributeDict objectForKey:@"sp"] intValue];
        _MusePoints = [[attributeDict objectForKey:@"mp"] intValue];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

}


@end
