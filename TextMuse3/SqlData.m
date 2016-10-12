//
//  SqlData.m
//  TextMuse
//
//  Created by Peter Tucker on 1/5/16.
//  Copyright © 2016 LaLoosh. All rights reserved.
//

#import "SqlData.h"

@implementation SqlData

-(id)init {
    self = [super init];
    
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        [self setDocumentsDirectory: [paths objectAtIndex:0]];
        [self setDatabaseFilename: @"textmuse.db"];

        NSString *dbPath = [[self documentsDirectory] stringByAppendingPathComponent:[self databaseFilename]];
        BOOL openDatabaseResult = SQLITE_OK;
        if (db == nil)
            openDatabaseResult = sqlite3_open([dbPath UTF8String], &db);
        if (openDatabaseResult == SQLITE_OK) {
            NSString* pins = @"create table if not exists Pins (msgid int, msg text, mediaurl text, url text);";
            sqlite3_stmt* stmt;
            if (sqlite3_prepare(db, [pins UTF8String], -1, &stmt, nil) == SQLITE_OK) {
                sqlite3_step(stmt);
            }
            NSString* flagged  = @"create table if not exists Flagged (msgid int);";
            if (sqlite3_prepare(db, [flagged UTF8String], -1, &stmt, nil) == SQLITE_OK) {
                sqlite3_step(stmt);
            }
            NSString* cats = @"create table if not exists Categories (name text, chosen int, archived int);";
            if (sqlite3_prepare(db, [cats UTF8String], -1, &stmt, nil) == SQLITE_OK) {
                sqlite3_step(stmt);
            }
        }
        else {
            UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"error"
                                                         message:[NSString stringWithUTF8String:(char*)sqlite3_errmsg(db)]
                                                        delegate:nil
                                               cancelButtonTitle:@"ok"
                                               otherButtonTitles:nil, nil];
            [av show];
        }
        
    }
    
    return self;
}

-(void)pinMessage:(Message*)msg {
    if (db == nil) return;
    
    NSString* text = [msg text] == nil ? @"null" :
            [NSString stringWithFormat:@"'%@'", [[msg text] stringByReplacingOccurrencesOfString:@"'"
                                                                                      withString:@"''"]];
    NSString* url = [msg url] == nil ? @"null" : [NSString stringWithFormat:@"'%@'", [msg url]];
    NSString* mediaurl = [msg mediaUrl] == nil ? @"null" : [NSString stringWithFormat:@"'%@'", [msg mediaUrl]];
    NSString* insert = [NSString stringWithFormat:@"insert into Pins (msgid, msg, mediaurl, url) values (%d, %@, %@, %@);", [msg msgId], text, mediaurl, url];
    sqlite3_stmt* stmt;
    if (sqlite3_prepare(db, [insert UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_step(stmt);
        
    }
}

-(void)unpinMessage:(Message*)msg {
    if (db == nil) return;

    NSString* insert = [NSString stringWithFormat:@"delete from Pins where msgid=%d;", [msg msgId]];
    sqlite3_stmt* stmt;
    if (sqlite3_prepare(db, [insert UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_step(stmt);
        
    }
}

-(NSArray*)getPinnedMessages {
    if (db == nil) return nil;
    
    NSString* fetch = @"select msgid, msg, mediaurl, url from Pins;";
    sqlite3_stmt* stmt;
    NSMutableArray* pins = [[NSMutableArray alloc] init];
    if (sqlite3_prepare(db, [fetch UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int msgid = sqlite3_column_int(stmt, 0);
            char* data = (char*)sqlite3_column_text(stmt, 1);
            NSString* msg = (data == nil) ? nil : [NSString stringWithUTF8String:data];
            data = (char*)sqlite3_column_text(stmt, 2);
            NSString* mediaurl = (data == nil) ? nil : [NSString stringWithUTF8String:data];
            data = (char*)sqlite3_column_text(stmt, 3);
            NSString* url = (data == nil) ? nil : [NSString stringWithUTF8String:data];
            Message* m = [[Message alloc] initWithId:msgid
                                                text:msg
                                            mediaUrl:mediaurl
                                                 url:url
                                         forCategory:nil
                                               isNew:NO];
            [m setPinned:YES];
            [pins addObject:m];
        }
        
    }
    
    return pins;
}

-(void)flagMessage:(Message*)msg {
    if (db == nil) return;

    NSString* insert = [NSString stringWithFormat:@"insert into Flagged (msgid) values (%d);", [msg msgId]];
    sqlite3_stmt* stmt;
    if (sqlite3_prepare(db, [insert UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_step(stmt);
        
    }
}

-(BOOL)isFlagged:(Message*)msg {
    return [self isFlaggedId:[msg msgId]];
}

-(BOOL)isFlaggedId:(int)msgId {
    if (db == nil || msgId < 0) return false;
    
    BOOL ret = false;
    NSString* fetch = [NSString stringWithFormat:@"select msgid from Flagged where msgid=%d;", msgId];
    sqlite3_stmt* stmt;
    if (sqlite3_prepare(db, [fetch UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        ret = (sqlite3_step(stmt) == SQLITE_ROW);
    }
    
    return ret;
}

-(void)archiveAllCategories {
    if (db == nil) return;

    sqlite3_stmt* stmt;
    NSString* cats = @"update Categories set archived = 1;";
    if (sqlite3_prepare(db, [cats UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_step(stmt);
    }
}

-(void)categoryExists:(NSString*)cat {
    if (db == nil) return;
    
    NSString* fetch = [NSString stringWithFormat:@"select name from Categories where name='%@';", cat];
    sqlite3_stmt* stmt;
    BOOL ret = false;
    if (sqlite3_prepare(db, [fetch UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        ret = (sqlite3_step(stmt) == SQLITE_ROW);
    }
    if (!ret) {
        fetch = [NSString stringWithFormat:@"insert into Categories (name, chosen, archived) values ('%@', 0, 0)",
                 cat];
    }
    else {
        fetch = [NSString stringWithFormat:@"update Categories set archived=0 where name='%@'", cat];
    }
    if (sqlite3_prepare(db, [fetch UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        ret = (sqlite3_step(stmt) == SQLITE_ROW);
    }
}

-(NSArray*)getChosenCategories {
    if (db == nil) return nil;
    
    NSString* fetch = @"select name from Categories where archived=0 and chosen=1;";
    sqlite3_stmt* stmt;
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    if (sqlite3_prepare(db, [fetch UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            char* data = (char*)sqlite3_column_text(stmt, 0);
            if (data != nil)
                [ret addObject:[NSString stringWithUTF8String:data]];
        }
    }
    
    return ret;
}

-(NSArray*)getExistingCategories {
    if (db == nil) return nil;
    
    NSString* fetch = @"select name from Categories where archived=0;";
    sqlite3_stmt* stmt;
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    if (sqlite3_prepare(db, [fetch UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            char* data = (char*)sqlite3_column_text(stmt, 0);
            if (data != nil)
                [ret addObject:[NSString stringWithUTF8String:data]];
        }
    }
    
    return ret;
}

-(void)addChosenCategory:(NSString*)cat {
    if (db == nil) return;
    
    NSString* fetch = [NSString stringWithFormat:@"update Categories set chosen=1 where name='%@';", cat];
    sqlite3_stmt* stmt;
    if (sqlite3_prepare(db, [fetch UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_step(stmt);
    }
}
-(void)removeChosenCategory:(NSString*)cat {
    if (db == nil) return;
    
    NSString* fetch = [NSString stringWithFormat:@"update Categories set chosen=0 where name='%@';", cat];
    sqlite3_stmt* stmt;
    if (sqlite3_prepare(db, [fetch UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_step(stmt);
    }
}


@end
