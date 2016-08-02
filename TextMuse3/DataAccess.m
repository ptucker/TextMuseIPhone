/*
 SELECT C.ID, C.Name, IFNULL(NS.Sends, 0) AS Sends, NSTotal.TotalSends as SendsTotal
 from Categories C LEFT JOIN (select C.ID, count(*) as Sends from NoteSends, Notes N, Categories C where NoteID=N.ID AND N.CategoryID=C.ID AND TIMESTAMPDIFF(HOUR, SendDate, now()) < 24 group by C.ID order by Sends DESC) AS NS on C.ID=NS.ID, (select C.ID, count(*) as TotalSends from NoteSends, Notes N, Categories C where NoteID=N.ID AND N.CategoryID=C.ID group by C.ID order by TotalSends DESC) AS NSTotal WHERE C.ID=NSTotal.ID ORDER BY NS.Sends DESC, NSTotal.TotalSends DESC, C.Name limit 0, 100;
 
 */

//
//  DataAccess.m
//  FriendlyNotes
//
//  Created by Peter Tucker on 4/20/14.
//  Copyright (c) 2014 WhitworthCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataAccess.h"
#import "Settings.h"
#import "GlobalState.h"
#import "Reachability.h"
#import "ImageDownloader.h"
#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>

NSString* urlNotes = @"http://www.textmuse.com/admin/notes.php";
NSString* localNotes = @"notes.xml";
const int HIDEMESSAGE = 1000;

@implementation DataAccess
@synthesize contactFilter;

-(id)init {
    timerLoad = nil;
    
    [self reloadData];
    
    return self;
}

-(void)reloadData {
    //We're already downloading. Knock it off!
    if (conn != nil) {
        for (NSObject* l in listeners) {
            if ([l respondsToSelector:@selector(dataRefresh)])
                [l performSelector:@selector(dataRefresh)];
        }

        return;
    }
    
    selectContacts = [[NSMutableArray alloc] init];
    
    notificationOnly = false;
    
    pinnedMsgs = [SqlDb getPinnedMessages];
    [self initCategories];
    
    [self initContacts];
}

-(void)reloadNotifications {
    notificationOnly = true;
    [self initCategories];
}

-(void)addListener:(id)listener {
    if (listeners == nil)
        listeners = [[NSMutableArray alloc] init];
    
    [listeners addObject:listener];
}

-(void)initCategories {
    currentMsgId = 0;
    
    if (categories == nil || [categories count] == 0) {
        [self loadFromFile];
    }
    
    [self loadFromInternet];
    
    if (!notificationOnly) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadLocalImages];
        });
    }
}

-(void) loadFromFile {
    @try {
        NSString* file = [NSTemporaryDirectory() stringByAppendingPathComponent:localNotes];

        if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
            inetdata = [NSMutableData dataWithData:[[self createFile]
                                                    dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else {
            inetdata = [NSMutableData dataWithContentsOfFile:file];
        }
    
        [self parseMessageData];
        if (parseFailed) {
            inetdata = [NSMutableData dataWithData:[[self createFile] dataUsingEncoding:NSUTF8StringEncoding]];
            [self parseMessageData];
        }
        categories = tmpCategories;
        [self mergeMessages];
    }
    @catch (id ex) {
        inetdata = [NSMutableData dataWithData:[[self createFile] dataUsingEncoding:NSUTF8StringEncoding]];
        [self parseMessageData];
        categories = tmpCategories;
        [self mergeMessages];
    }
    for (NSObject* l in listeners) {
        if ([l respondsToSelector:@selector(dataRefresh)])
            [l performSelector:@selector(dataRefresh)];
    }

    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"** Debug **"
                                                    message:[NSString stringWithFormat:@"cached category count: %ld bytes", [[self getCategories] count]]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
     */
}

-(NSString*)createFile {
    NSString* initialXML = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><notes><ns><t>Check out the new daily deals today.</t><t>Who's having a birthday? Send them a text from our great birthday quotes.</t><t>Make someone's day and send a romantic text.</t><t>Give us feedback! Click the cog button in TextMuse and choose Feedback.</t></ns><c name='Trending' required='1' new='0'><n id='30' new='0' liked='0'>Baby rhino.<text>Baby rhino.</text><media>http://pbs.twimg.com/media/B3yI0nbIEAAY3Hm.jpg</media><url></url></n><n id='34' new='0' liked='0'>My day is filled with thoughts of you.<text>My day is filled with thoughts of you.</text><media></media><url></url></n><n id='24' new='0' liked='0'>There are more than 10 million bricks in the Empire State Building.<text>There are more than 10 million bricks in the Empire State Building.</text><media></media><url></url></n><n id='32' new='0' liked='0'>Just wanted to let you know that I'm glad to have you in my life.<text>Just wanted to let you know that I'm glad to have you in my life.</text><media></media><url></url></n><n id='4240' new='0' liked='0'>A Happy Birthday quote just for you! - It takes a long time to become young.  -Pablo Picasso<text>A Happy Birthday quote just for you! - It takes a long time to become young.  -Pablo Picasso</text><media></media><url></url></n><n id='4234' new='0' liked='0'>A Happy Birthday quote just for you! - God gave us the gift of life; it is up to us to give ourselves the gift of living well.  -Voltaire<text>A Happy Birthday quote just for you! - God gave us the gift of life; it is up to us to give ourselves the gift of living well.  -Voltaire</text><media></media><url></url></n><n id='2597' new='0' liked='0'>A hundred hearts would be too few to carry all my love for you.<text>A hundred hearts would be too few to carry all my love for you.</text><media></media><url></url></n><n id='2168' new='0' liked='0'>Astronaut includes his dogs in official NASA portrait.<text>Astronaut includes his dogs in official NASA portrait.</text><media>http://barkpost.com/wp-content/uploads/2015/02/astroFT.jpg</media><url>http://barkpost.com/astronaut-and-his-dogs/</url></n><n id='1188' new='0' liked='0'>Can Your Pup Actually Understand What You're Saying? The Results Are In!<text>Can Your Pup Actually Understand What You're Saying? The Results Are In!</text><media>http://barkpost.com/wp-content/uploads/2015/01/dogs-hearing-by-Muffet-600x450.jpg</media><url>http://bit.ly/1y3vJxp</url></n><n id='1189' new='0' liked='0'>10 Adorable Pets You Have to See<text>10 Adorable Pets You Have to See</text><media>http://barkpost.com/wp-content/uploads/2015/01/pp1.jpg</media><url>http://barkpost.com/adorable-pets-to-see/</url></n></c><c name='I Can Has Animals' required='0' new='0' url='http://www.cheezburger.com/' icon='http://www.textmuse.com/images/cheezburger.png'><n id='17' new='1' liked='0'>Cat power<text>Cat power</text><media>https://i.chzbgr.com/maxW500/8198417152/h3BDE93F2/</media><url>http://chzb.gr/1cOgeqy</url></n><n id='17' new='1' liked='0'>Slow-Motion Proof Cats Are Ninjas<text> Slow-Motion Proof Cats Are Ninjas </text><media>https://youtu.be/01Ue7Dbf424</media><url>http://chzb.gr/1cOg429</url></n><n id='17' new='1' liked='0'><text></text><media>https://i.chzbgr.com/maxW500/6048876800/h617C4E0E/</media><url>http://chzb.gr/1cOfWzP</url></n><n id='17' new='1' liked='0'>These Two Adorable Fox Pups Love Playing With a Tennis Ball<text> These Two Adorable Fox Pups Love Playing With a Tennis Ball </text><media>https://youtu.be/Vmxf79w2NU0</media><url>http://chzb.gr/1cOfyRN</url></n><n id='17' new='1' liked='0'>The landing is going to be rough.<text>The landing is going to be rough.</text><media>https://i.chzbgr.com/maxW500/8488047616/hC9FFFE29/</media><url>http://chzb.gr/1dg4ZYM</url></n><n id='17' new='1' liked='0'>Here's a cute raccoon for you.<text>Here's a cute raccoon for you.</text><media>https://i.chzbgr.com/maxW500/5357233408/hFF13D13F/</media><url>http://chzb.gr/1dg4HRJ</url></n><n id='17' new='0' liked='0'>Can't Argue With That Logic<text>Can't Argue With That Logic </text><media>https://i.chzbgr.com/maxW500/6491963392/h3DF20FA4/</media><url>http://chzb.gr/1RXOqAg</url></n><n id='17' new='0' liked='0'><text></text><media>https://i.chzbgr.com/maxW500/8489148928/hDD6D9125/</media><url>http://chzb.gr/1RXO2Sp</url></n><n id='17' new='0' liked='0'>Cat And Dog Join Forces For A Delicious Assist<text> Cat And Dog Join Forces For A Delicious Assist </text><media>https://youtu.be/m-I3FIU8nXY</media><url>http://chzb.gr/1RXNRGT</url></n><n id='17' new='0' liked='0'>Acting Fierce 101<text>Acting Fierce 101 </text><media>https://i.chzbgr.com/maxW500/6382480896/h29F475BC/</media><url>http://chzb.gr/1RXNETY</url></n><n id='17' new='0' liked='0'>I'll Just Pet Myself With the Dog's Paw<text> I'll Just Pet Myself With the Dog's Paw </text><media>https://youtu.be/X4zsKJI3-Zw</media><url>http://chzb.gr/1RXNbRF</url></n><n id='17' new='0' liked='0'>And I Won't Be Telling You About It<text> And I Won't Be Telling You About It </text><media>https://i.chzbgr.com/maxW500/6559585536/h9CD86063/</media><url>http://chzb.gr/1RXMVlR</url></n><n id='17' new='0' liked='0'>Baby Ducks, Way Better Than Studying<text> Baby Ducks, Way Better Than Studying </text><media>https://i.chzbgr.com/maxW500/8492637952/h8AE8212D/</media><url>http://chzb.gr/1RXMJmp</url></n><n id='17' new='0' liked='0'>This Adorable Wild Baby Rabbit Is The Happiest Thing You'll See All Week<text>This Adorable Wild Baby Rabbit Is The Happiest Thing You'll See All Week</text><media>https://youtu.be/0VSQy9ANMzg</media><url>http://chzb.gr/1EcTS7L</url></n></c><c name='Inspiring Quotes' required='0' new='0' url='' icon=''><n id='5' new='1' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors3/tmb/eric-hoffer-writer-it-is-easier-to-love-humanity-as-a-whole-than-to.jpg</media><url></url></n><n id='5' new='1' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors3/tmb/george-eliot-author-quote-i-like-not-only-to-be-loved-but-also-to-be.jpg</media><url></url></n><n id='5' new='1' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors2/tmb/plato-life-quotes-life-must-be-lived-as.jpg</media><url></url></n><n id='5' new='1' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors5/tmb/benjamin-franklin-time-quotes-you-may-delay-but-time-will.jpg</media><url></url></n><n id='5' new='1' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors1/tmb/ralph-waldo-emerson-poet-to-know-even-one-life-has-breathed-easier-because-you.jpg</media><url></url></n><n id='5' new='1' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors54/tmb/shane-west-shane-west-sexy-is-kind-of-like-an-aura-around.jpg</media><url></url></n><n id='5' new='1' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors3/tmb/henry-miller-author-the-one-thing-we-can-never-get-enough-of-is-love.jpg</media><url></url></n><n id='5' new='0' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors3/tmb/oliver-wendell-holmes-men-quotes-men-do-not-quit-playing-because-they.jpg</media><url></url></n><n id='5' new='0' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors76/tmb/jessica-savitch-journalist-quote-no-matter-how-many-goals-you-have.jpg</media><url></url></n><n id='5' new='0' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors4/tmb/sigmund-freud-psychologist-the-voice-of-the-intellect-is-a-soft-one.jpg</media><url></url></n><n id='5' new='0' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors7/tmb/mignon-mclaughlin-change-quotes-its-the-most-unhappy-people-who-most.jpg</media><url></url></n><n id='5' new='0' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors2/tmb/ansel-adams-photographer-quote-a-true-photograph-need-not-be.jpg</media><url></url></n><n id='5' new='0' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors5/tmb/courtney-love-musician-i-dont-need-plastic-in-my-body-to-validate-me.jpg</media><url></url></n><n id='5' new='0' liked='0'><text></text><media>http://www.quotehd.com/imagequotes/authors5/tmb/john-updike-novelist-quote-art-is-like-baby-shoes-when-you-coat-them.jpg</media><url></url></n></c><c name='Birthdays and Occasions' required='0' new='0' url='' icon=''><n id='35' new='0' liked='0'>A Happy Birthday quote just for you! - It takes a long time to become young.  -Pablo Picasso<text>A Happy Birthday quote just for you! - It takes a long time to become young.  -Pablo Picasso</text><media></media><url></url></n><n id='35' new='0' liked='0'>A Happy Birthday quote just for you! - Let us celebrate the occasion with wine and sweet words.  -Plautus<text>A Happy Birthday quote just for you! - Let us celebrate the occasion with wine and sweet words.  -Plautus</text><media></media><url></url></n><n id='35' new='0' liked='0'>A Happy Birthday quote just for you! - Every year on your birthday, you get a chance to start new.  -Sammy Hagar<text>A Happy Birthday quote just for you! - Every year on your birthday, you get a chance to start new.  -Sammy Hagar</text><media></media><url></url></n><n id='35' new='0' liked='0'>A Happy Birthday quote just for you! - Age is a case of mind over matter. If you don't mind, it don't matter.  -Satchel Paige<text>A Happy Birthday quote just for you! - Age is a case of mind over matter. If you don't mind, it don't matter.  -Satchel Paige</text><media></media><url></url></n><n id='35' new='0' liked='0'>A Happy Birthday quote just for you! - Let us never know what old age is. Let us know the happiness time brings, not count the years.  -Ausonius<text>A Happy Birthday quote just for you! - Let us never know what old age is. Let us know the happiness time brings, not count the years.  -Ausonius</text><media></media><url></url></n><n id='35' new='0' liked='0'>A Happy Birthday quote just for you! - God gave us the gift of life; it is up to us to give ourselves the gift of living well.  -Voltaire<text>A Happy Birthday quote just for you! - God gave us the gift of life; it is up to us to give ourselves the gift of living well.  -Voltaire</text><media></media><url></url></n><n id='35' new='0' liked='0'>A Happy Birthday quote just for you! - Today you are you! That is truer than true! There is no one alive who is you-er than you!  -Dr. Seuss<text>A Happy Birthday quote just for you! - Today you are you! That is truer than true! There is no one alive who is you-er than you!  -Dr. Seuss</text><media></media><url></url></n><n id='35' new='0' liked='0'>Happy Birthday! May you continue to wear them well! Cheers!<text>Happy Birthday! May you continue to wear them well! Cheers!</text><media></media><url></url></n><n id='35' new='0' liked='0'>Let's make today a national holiday! Happy Birthday! Enjoy!<text>Let's make today a national holiday! Happy Birthday! Enjoy!</text><media></media><url></url></n><n id='35' new='0' liked='0'>Congratulations on your new baby! I'll be in touch!<text>Congratulations on your new baby! I'll be in touch!</text><media></media><url></url></n><n id='35' new='0' liked='0'>Congratulations on your engagement! So happy for you! I'll be in touch!<text>Congratulations on your engagement! So happy for you! I'll be in touch!</text><media></media><url></url></n><n id='35' new='0' liked='0'>Congratulations! Very happy for you! I'll be in touch!<text>Congratulations! Very happy for you! I'll be in touch!</text><media></media><url></url></n><n id='35' new='0' liked='0'>Hope you have a great birthday and celebrate in style! I'll be in touch!<text>Hope you have a great birthday and celebrate in style! I'll be in touch!</text><media></media><url></url></n><n id='35' new='0' liked='0'>Hope you have a great anniversary and celebrate in style! I'll be in touch!<text>Hope you have a great anniversary and celebrate in style! I'll be in touch!</text><media></media><url></url></n></c><c name='Recipes of the Day' required='0' new='0' url='' icon=''><n id='30' new='1' liked='0'>Blackberry Cobblers Cups<text>Blackberry Cobblers Cups</text><media>http://img.sndimg.com/food/image/upload/w_293,h_273,c_fit/v1/img/slideshow-item/0450/ZH9qaab3RauZK5DRrZ21_19%20Cobbler%20cups.jpg</media><url>http://fd.cm/1PtWlqj</url></n><n id='30' new='1' liked='0'>Coconut Rice With Black Beans, Plantains, and Mango Salsa<text>Coconut Rice With Black Beans, Plantains, and Mango Salsa</text><media>http://img.food.com/fdc/mobile/icons/touch-icon-iphone@3x.png</media><url>http://fd.cm/1PtXGgM</url></n><n id='30' new='1' liked='0'>Kway Teow Gai<text>Kway Teow Gai</text><media></media><url>http://fd.cm/1PtXFK0</url></n><n id='30' new='1' liked='0'>Easy Breakfast Casserole With Sausage, Hashbrowns, and Eggs<text>Easy Breakfast Casserole With Sausage, Hashbrowns, and Eggs</text><media></media><url>http://fd.cm/1PtXG0y</url></n><n id='30' new='1' liked='0'>Red Lentil Coconut Curry Soup<text>Red Lentil Coconut Curry Soup</text><media></media><url>http://fd.cm/1PtXG0x</url></n><n id='30' new='1' liked='0'>Yemeni Dal With Lamb<text>Yemeni Dal With Lamb</text><media></media><url>http://fd.cm/1PtXFJP</url></n><n id='30' new='1' liked='0'>Low Carb Vanilla Frappuccino<text>Low Carb Vanilla Frappuccino</text><media></media><url>http://fd.cm/1PtXG0w</url></n><n id='30' new='1' liked='0'>Umami Beef Pho<text>Umami Beef Pho</text><media></media><url>http://fd.cm/1PtXFtu</url></n><n id='30' new='1' liked='0'>Chicken Pot Pie - YIAH Style<text>Chicken Pot Pie - YIAH Style</text><media></media><url>http://fd.cm/1PtXG0v</url></n><n id='30' new='1' liked='0'>Apricot-Cinnamon Couscous<text>Apricot-Cinnamon Couscous</text><media></media><url>http://fd.cm/1PtXG0u</url></n><n id='30' new='1' liked='0'>Gazpacho<text>Gazpacho</text><media></media><url>http://fd.cm/1PtXFts</url></n><n id='30' new='1' liked='0'>Roast Lamb &amp; Onions<text>Roast Lamb &amp; Onions</text><media></media><url>http://fd.cm/1PtXFtr</url></n><n id='30' new='1' liked='0'>Millet Porridge<text>Millet Porridge</text><media></media><url>http://fd.cm/1PtXG0r</url></n><n id='30' new='1' liked='0'>Broccoli and Sausage Frittata<text>Broccoli and Sausage Frittata</text><media></media><url>http://fd.cm/1PtXFtl</url></n><n id='30' new='1' liked='0'>Nest Egg Pie<text>Nest Egg Pie</text><media></media><url>http://fd.cm/1PtXFtk</url></n><n id='30' new='1' liked='0'>America's Best Potato Salad<text>America's Best Potato Salad</text><media></media><url>http://fd.cm/1PtXG0o</url></n><n id='30' new='1' liked='0'>Asian Pasta Salad<text>Asian Pasta Salad</text><media>http://img.sndimg.com/food/image/upload/w_293,h_273,c_fit/v1/img/slideshow-item/0450/whLEXcsJQbu8rlrWENFC_18%20Asian%20Salad.jpg</media><url>http://fd.cm/1PtW7zy</url></n></c><c name='Cute Photos' required='0' new='0' url='' icon=''><n id='37' new='0' liked='0'>13 Facts About Wolves and Dogs That Will Blow Your Mind<text>13 Facts About Wolves and Dogs That Will Blow Your Mind</text><media>http://barkpost.com/wp-content/uploads/2014/06/nikai2.jpg</media><url>http://bit.ly/1EQuNAf</url></n><n id='37' new='0' liked='0'>Wolf pup with hiccups<text>Wolf pup with hiccups</text><media>https://youtu.be/lNY79Ktq_vg</media><url>http://bit.ly/1EQuNAf</url></n><n id='37' new='0' liked='0'>To ease red wolves back into packs, conservations will insert newborns into litters of red wolves in the wild.<text>To ease red wolves back into packs, conservations will insert newborns into litters of red wolves in the wild.</text><media>http://barkpost.com/wp-content/uploads/2014/06/red-wolf.jpg</media><url>http://bit.ly/1EQuNAf</url></n><n id='37' new='0' liked='0'><text></text><media>http://barkpost.com/wp-content/uploads/2014/06/nikai-and-kai.jpg</media><url>http://bit.ly/1EQuNAf</url></n><n id='37' new='0' liked='0'>Dogs and wolves split from a common ancestor around 34,000 years ago.<text>Dogs and wolves split from a common ancestor around 34,000 years ago.</text><media>http://barkpost.com/wp-content/uploads/2014/06/wolves-and-dogs.jpg</media><url>http://bit.ly/1EQuNAf</url></n><n id='37' new='0' liked='0'>Brilliantly Obedient Pup Can Speak AND Whisper On Command<text>Brilliantly Obedient Pup Can Speak AND Whisper On Command</text><media>https://youtu.be/AsBw64EDklU</media><url>http://bit.ly/1EQuqFW</url></n><n id='37' new='0' liked='0'>Defiant Husky Throws A Dramatic Tantrum At Shower Time<text>Defiant Husky Throws A Dramatic Tantrum At Shower Time</text><media>https://youtu.be/-1lbRawBPRk</media><url>http://bit.ly/1EQueGN</url></n></c><c name='Friendship and Love' required='0' new='0' url='' icon=''><n id='8' new='0' liked='0'>Only love interests me, and I am only in contact with things that revolve around love.  -Marc Chagall<text>Only love interests me, and I am only in contact with things that revolve around love.  -Marc Chagall</text><media></media><url></url></n><n id='8' new='0' liked='0'>The magic of marriage is that four arms are better than two. Your chances of survival are better.  -Eames Yates<text>The magic of marriage is that four arms are better than two. Your chances of survival are better.  -Eames Yates</text><media></media><url></url></n><n id='8' new='0' liked='0'>If it is your time, love will track you down like a cruise missile.  -Lynda Barry<text>If it is your time, love will track you down like a cruise missile.  -Lynda Barry</text><media></media><url></url></n><n id='8' new='0' liked='0'>Never pretend to a love which you do not actually feel, for love is not ours to command.  -Alan Watts<text>Never pretend to a love which you do not actually feel, for love is not ours to command.  -Alan Watts</text><media></media><url></url></n><n id='8' new='0' liked='0'>You make my life special by just being in it.<text>You make my life special by just being in it.</text><media></media><url></url></n><n id='8' new='0' liked='0'>Being with you is like having every single one of my wishes come true.<text>Being with you is like having every single one of my wishes come true.</text><media></media><url></url></n><n id='8' new='0' liked='0'>I love you more today than I did yesterday, but not as much as I will tomorrow!<text>I love you more today than I did yesterday, but not as much as I will tomorrow!</text><media></media><url></url></n><n id='8' new='0' liked='0'>I love you, not for what you are, but for what I am when I am with you.<text>I love you, not for what you are, but for what I am when I am with you.</text><media></media><url></url></n><n id='8' new='0' liked='0'>A hundred hearts would be too few to carry all my love for you.<text>A hundred hearts would be too few to carry all my love for you.</text><media></media><url></url></n><n id='8' new='0' liked='0'>If you do not love me, I shall not be loved. If I do not love you, I shall not love.<text>If you do not love me, I shall not be loved. If I do not love you, I shall not love.</text><media></media><url></url></n><n id='8' new='0' liked='0'>Love keeps the cold out better than a cloak. - Henry Wadsworth Longfellow<text>Love keeps the cold out better than a cloak. - Henry Wadsworth Longfellow</text><media></media><url></url></n><n id='8' new='0' liked='0'>The sweetest of all sounds is that of the voice of the woman we love. - Jean de la Bruyere<text>The sweetest of all sounds is that of the voice of the woman we love. - Jean de la Bruyere</text><media></media><url></url></n><n id='8' new='0' liked='0'>My day is filled with thoughts of you.<text>My day is filled with thoughts of you.</text><media></media><url></url></n><n id='8' new='0' liked='0'>Just wanted to let you know that I'm glad to have you in my life.<text>Just wanted to let you know that I'm glad to have you in my life.</text><media></media><url></url></n></c><c name='Fail Blog' required='0' new='0' url='' icon=''><n id='29' new='0' liked='0'>Discovery Channel 1 - Penguins 0<text>Discovery Channel 1 - Penguins 0</text><media>https://i.chzbgr.com/maxW500/8493090048/h83ABCB62/</media><url>http://chzb.gr/1EcVE8Y</url></n><n id='29' new='0' liked='0'>Behold the Beast, Slayer of the Post<text>Behold the Beast, Slayer of the Post </text><media>https://i.chzbgr.com/maxW500/8493226752/hFE5CE00D/</media><url>http://chzb.gr/1RXOEHE</url></n></c><c name='Everyday Texts' required='0' new='0' url='' icon=''><n id='34' new='0' liked='0'>Join me for lunch?<text>Join me for lunch?</text><media></media><url></url></n><n id='34' new='0' liked='0'>Would you like to come for dinner?<text>Would you like to come for dinner?</text><media></media><url></url></n><n id='34' new='0' liked='0'>Can you still join us?<text>Can you still join us?</text><media></media><url></url></n><n id='34' new='0' liked='0'>Could you please connect with me at your earliest convenience? Thanks!<text>Could you please connect with me at your earliest convenience? Thanks!</text><media></media><url></url></n><n id='34' new='0' liked='0'>Thank you!<text>Thank you!</text><media></media><url></url></n><n id='34' new='0' liked='0'>Happy Birthday! Enjoy! Chat soon!<text>Happy Birthday! Enjoy! Chat soon!</text><media></media><url></url></n><n id='34' new='0' liked='0'>Be there in a few!<text>Be there in a few!</text><media></media><url></url></n><n id='34' new='0' liked='0'>On my way!<text>On my way!</text><media></media><url></url></n><n id='34' new='0' liked='0'>Just checking in. What's the latest?<text>Just checking in. What's the latest?</text><media></media><url></url></n><n id='34' new='0' liked='0'>Hi! What's up?<text>Hi! What's up?</text><media></media><url></url></n><n id='34' new='0' liked='0'>Where are you?<text>Where are you?</text><media></media><url></url></n><n id='34' new='0' liked='0'>Everything okay?<text>Everything okay?</text><media></media><url></url></n><n id='34' new='0' liked='0'>Hello! How's it going?<text>Hello! How's it going?</text><media></media><url></url></n><n id='34' new='0' liked='0'>Let's connect soon!<text>Let's connect soon!</text><media></media><url></url></n><n id='34' new='0' liked='0'>Sorry you're under the weather. Hope you're back to feeling great soon!<text>Sorry you're under the weather. Hope you're back to feeling great soon!</text><media></media><url></url></n><n id='34' new='0' liked='0'>Just heard the difficult news. I'm so sorry. I'll be in touch soon.<text>Just heard the difficult news. I'm so sorry. I'll be in touch soon.</text><media></media><url></url></n><n id='34' new='0' liked='0'>Just heard the good news! Very happy for you! I'll be in touch!<text>Just heard the good news! Very happy for you! I'll be in touch!</text><media></media><url></url></n></c><c name='Science and Education' required='0' new='0' url='' icon=''><n id='36' new='1' liked='0'>Will Aliens Be the Size of Bears?<text>Will Aliens Be the Size of Bears?</text><media></media><url>http://bit.ly/1HsLJUk</url></n><n id='36' new='1' liked='0'>Pacific NW's 'Wet Drought' Gets Worse<text>Pacific NW's 'Wet Drought' Gets Worse</text><media></media><url>http://bit.ly/1HsLMzw</url></n><n id='36' new='1' liked='0'>Drought: Why California Wine Will Be Okay<text>Drought: Why California Wine Will Be Okay</text><media></media><url>http://bit.ly/1HsLJUj</url></n><n id='36' new='1' liked='0'>A New Medical Diagnosis for Julius Caesar<text>A New Medical Diagnosis for Julius Caesar</text><media></media><url>http://bit.ly/1HsLMzt</url></n><n id='36' new='1' liked='0'>Will Computers Redefine Roots of Math?<text>Will Computers Redefine Roots of Math?</text><media></media><url>http://bit.ly/1HsLMzs</url></n><n id='36' new='1' liked='0'>Generational Labels Are Lazy and Wrong<text>Generational Labels Are Lazy and Wrong</text><media></media><url>http://bit.ly/1HsLJUi</url></n><n id='36' new='1' liked='0'>Don't Fight Stress. Welcome It<text>Don't Fight Stress. Welcome It</text><media></media><url>http://bit.ly/1PtXxdv</url></n><n id='36' new='1' liked='0'>Where Is the Cosmic Microwave Background?<text>Where Is the Cosmic Microwave Background?</text><media></media><url>http://bit.ly/1PtXzBW</url></n><n id='36' new='1' liked='0'>Do Bugs Sleep?<text>Do Bugs Sleep?</text><media></media><url>http://bit.ly/1PtXzBV</url></n><n id='36' new='1' liked='0'>Long Lost Egyptian Temple Found<text>Long Lost Egyptian Temple Found</text><media></media><url>http://bit.ly/1PtXxds</url></n><n id='36' new='1' liked='0'>Unscientific Nonsense on 'Shark Tank'<text>Unscientific Nonsense on 'Shark Tank'</text><media></media><url>http://bit.ly/1PtXzBU</url></n><n id='36' new='1' liked='0'>Infections May Lower Cognitive Ability<text>Infections May Lower Cognitive Ability</text><media></media><url>http://bit.ly/1PtXxdr</url></n><n id='36' new='0' liked='0'>Let your kids become animal helpers at the zoo with Turtle!<text>Let your kids become animal helpers at the zoo with Turtle!</text><media>http://bit.ly/1K7jD1A</media><url>http://bit.ly/1zeXVoz</url></n></c><c name='Fitness and Health' required='0' new='0' url='' icon=''><n id='1047' new='0' liked='0'>Get your heart pumping with CARDIO BLAST from Wright Now Fitness!<text>Get your heart pumping with CARDIO BLAST from Wright Now Fitness!</text><media>http://bit.ly/1IyHkiT</media><url>http://bit.ly/1bT53ML</url></n></c></notes>";
    
    /*
    NSString* file = [NSTemporaryDirectory() stringByAppendingPathComponent:localNotes];
    [[NSFileManager defaultManager] createFileAtPath:file
                                            contents:[initialXML dataUsingEncoding:NSStringEncodingConversionAllowLossy]
                                          attributes:nil];
     */
    return initialXML;
}

-(void)loadFromInternet {
    if (timerLoad != nil)
        [timerLoad invalidate];
    timerLoad = nil;
    
    [ImageDownloader CancelDownloads];
    
    NSDateFormatter *dateformat=[[NSDateFormatter alloc]init];
    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // Date formatter
    NSString *lastDownload = [dateformat stringFromDate:[NSDate date]];
    //NSString* lastDownload = @"2015-4-6 12:00:00";
    if (LastNoteDownload != nil)
        lastDownload = LastNoteDownload;
    lastDownload = [lastDownload stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString* appid = (AppID != nil) ? [NSString stringWithFormat:@"&app=%@", AppID] : @"";
    NSString* notif = (notificationOnly) ? @"&notifyonly=1" : @"";
    NSString* sponsor = @"";
#ifdef WHITWORTH
    sponsor = @"&sponsor=6";
#endif
#ifdef UOREGON
    sponsor = @"&sponsor=7";
#endif
    if (Skin != nil)
        sponsor = [NSString stringWithFormat:@"&sponsor=%ld", [Skin SkinID]];
    NSString* surl = [NSString stringWithFormat:@"%@?ts=%@%@%@&highlight=1%@",
                      urlNotes, lastDownload, appid, notif, sponsor];
    if (!notificationOnly)
        LastNoteDownload = [dateformat stringFromDate:[NSDate date]];
    NSURL* url = [NSURL URLWithString:surl];
    NSURLRequest* req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    inetdata = [[NSMutableData alloc] initWithCapacity:60000];

    conn = [[NSURLConnection alloc] initWithRequest:req
                                           delegate:self
                                   startImmediately:YES];

    timerLoad = [NSTimer scheduledTimerWithTimeInterval:7200
                                                 target:self
                                               selector:@selector(autoReloadMessages)
                                               userInfo:nil
                                                repeats:NO];
    
}

-(void)autoReloadMessages {
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi) {
        [self loadFromInternet];
    }
    else {
        timerLoad = [NSTimer scheduledTimerWithTimeInterval:7200
                                                     target:self
                                                   selector:@selector(autoReloadMessages)
                                                   userInfo:nil
                                                    repeats:NO];
    }
}

-(void)loadLocalImages {
    NSMutableArray* dates = [[NSMutableArray alloc] init];
    localImages = [[NSMutableArray alloc] init];
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop){
                @try {
                if (asset){
                    int i=0;
                    NSDate* pdate = [asset valueForProperty:ALAssetPropertyDate];
                    for (;i < [dates count]; i++) {
                        if ([pdate compare:[dates objectAtIndex:i]] == NSOrderedDescending)
                            break;
                    }
                    if (i < 15) {
                        if (i < [dates count]) {
                            [dates insertObject:pdate atIndex:i];
                            [localImages insertObject:[[Message alloc] initFromUserPhoto:asset] atIndex:i];
                        }
                        else if ([dates count] < 15) {
                            [dates addObject:pdate];
                            [localImages addObject:[[Message alloc] initFromUserPhoto:asset]];
                        }
                    }
                }
                if ([localImages count] > 15)
                    [localImages removeObjectsInRange:NSMakeRange(15, [localImages count] - 15)];
                }
                @catch (id ex) {
                    NSLog(@"Exception occurred");
                }
            }];
        }
        else {
            //NSLog(@"All photos loaded");
            for (Message*m in localImages) {
                [m loadUserImage];
            }
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"error enumerating AssetLibrary groups %@\n", error);
    }];
}

-(void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [inetdata appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //NSLog([error localizedDescription]);
    
    for (NSObject* l in listeners) {
        if ([l respondsToSelector:@selector(dataRefresh)])
            [l performSelector:@selector(dataRefresh)];
    }

    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK Button", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
    */
    conn = nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection*) connection {
    //Now that we have data from the server, re-initialize Categories to an empty dictionary
    @try {
        //NSString* result = [[NSString alloc] initWithData:inetdata encoding:NSUTF8StringEncoding];
        //NSLog(result);
        [self parseMessageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!notificationOnly) {
                categories = tmpCategories;
                [self mergeMessages];
            }

            NSString* file = [NSTemporaryDirectory() stringByAppendingPathComponent:localNotes];
            [[NSFileManager defaultManager] createFileAtPath:file
                                                    contents:inetdata
                                                  attributes:nil];
            
            for (NSObject* l in listeners) {
                if ([l respondsToSelector:@selector(dataRefresh)])
                    [l performSelector:@selector(dataRefresh)];
            }
        });
    }
    @catch(id ex) {
        NSLog(@"Exception loading from Internet");
    }
    conn = nil;
}

-(void)parseMessageData {
    tmpCategories = [[NSMutableDictionary alloc] init];
    tmpRegMessages = [[NSMutableArray alloc] init];
    tmpVersionMessages = [[NSMutableArray alloc] init];
    parseFailed = false;
    //NSString* xml = [[NSString alloc] initWithData:inetdata encoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:inetdata];
    [parser setDelegate:self];
    [parser parse];
}

-(void)initContacts {
    loadingContacts = YES;
    CFErrorRef* error = NULL;
    DataAccess* __weak weakSelf = self;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);

    //if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf loadContacts:addressBook];
            });
        });
    //}
    //else { // we're on iOS 5 or older
    //    [self loadContacts:addressBook];
    //}
    loadingContacts = NO;
}

-(void)loadContacts:(ABAddressBookRef)addressBook {
    NSMutableArray* _contacts = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    if (allPeople == nil) return;
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    if (numberOfPeople == 0) return;
    
    for(int i = 0; i < numberOfPeople; i++){
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        NSMutableArray* phones = [[NSMutableArray alloc] init];
        long cphones = ABMultiValueGetCount(phoneNumbers);
        if (cphones > 0) {
            for (long i=0; i<cphones; i++) {
                CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
                NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
                phoneLabel = [phoneLabel lowercaseString];
                NSString* phoneNumber = (__bridge NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                [phones addObject:[[UserPhone alloc] initWithNumber:phoneNumber Label:phoneLabel]];
            }
        }
        
        NSData* photo = nil;
        if (ABPersonHasImageData(person)){
            photo = (__bridge NSData*)(ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail));
        }
        
        if (([firstName length] > 0 || [lastName length] > 0) && [phones count] > 0) {
            UserContact* c = [[UserContact alloc] initWithFName:firstName
                                                          LName:lastName
                                                          Phones:phones
                                                          Photo:photo];
            if (c != nil)
                [_contacts addObject:c];
        }
    }
    
    contacts = [_contacts sortedArrayUsingSelector:@selector(compareName:)];
}

-(void)sortContacts {
    contacts = [contacts sortedArrayUsingSelector:@selector(compareName:)];
}

-(NSArray*) sortCategories {
    NSComparisonResult (^categoryCmp)(id, id);
    categoryCmp = ^NSComparisonResult(id c1, id c2) {
        MessageCategory* cat1 = [categories objectForKey:c1];
        MessageCategory* cat2 = [categories objectForKey:c2];
        if ([cat1 required] != [cat2 required]) {
            return ([cat1 required]) ? NSOrderedAscending : NSOrderedDescending;
        }
        if ([cat1 newCategory] != [cat2 newCategory]) {
            return ([cat1 newCategory]) ? NSOrderedAscending : NSOrderedDescending;
        }
        if ([CategoryList objectForKey:[cat1 name]] != [CategoryList objectForKey:[cat2 name]]) {
            int v1 = [[CategoryList objectForKey:[cat1 name]] intValue];
            int v2 = [[CategoryList objectForKey:[cat2 name]] intValue];
            if (v1 == 0)
                return NSOrderedDescending;
            else if (v2 == 0)
                return NSOrderedAscending;
            else if (v1 > v2)
                return NSOrderedDescending;
            else if (v1 < v2)
                return NSOrderedAscending;
        }
        
        return ([cat1 order] > [cat2 order]) ? NSOrderedDescending :
        (([cat1 order] < [cat2 order]) ? NSOrderedAscending : NSOrderedSame);
    };

    NSArray* sortedCats = [[[categories keyEnumerator] allObjects] sortedArrayUsingComparator: categoryCmp];
    return sortedCats;
}

-(NSArray*)getCategories {
    NSArray* sorted = [self sortCategories];
    NSMutableArray* cs = [[NSMutableArray alloc] init];
    for (NSString* m in sorted)
        [cs addObject:m];

    if (localImages != nil && [localImages count] > 0)
        [cs addObject:NSLocalizedString(@"Your Photos Title", nil)];
    [cs addObject:NSLocalizedString(@"Your Messages Title", nil)];
    if (SaveRecentMessages && [RecentMessages count] > 0)
        [cs addObject:NSLocalizedString(@"Recent Messages Title", nil)];
    
    return cs;
}

-(NSArray*)getRequiredCategories {
    NSArray* sorted = [self sortCategories];
    NSMutableArray* cs = [[NSMutableArray alloc] init];
    for (NSString*c in sorted) {
        if ([[categories objectForKey:c] required])
            [cs addObject:c];
    }
    int i=0;
    if (localImages != nil && [localImages count] > 0)
        [cs insertObject:NSLocalizedString(@"Your Photos Title", nil) atIndex:i++];
    [cs insertObject:NSLocalizedString(@"Your Messages Title", nil) atIndex:i++];
    if (SaveRecentMessages && [RecentMessages count] > 0)
        [cs insertObject:NSLocalizedString(@"Recent Messages Title", nil) atIndex:i];

    return cs;
}

-(NSArray*)getSponsorCategories {
    NSArray* sorted = [self sortCategories];
    NSMutableArray* cs = [[NSMutableArray alloc] init];
    for (NSString*c in sorted) {
        if ([[categories objectForKey:c] sponsor] != nil)
            [cs addObject:c];
    }
    
    return cs;
}

-(MessageCategory*)getCategory:(NSString *)c {
    return [categories objectForKey:c];
}

-(SponsorInfo*)getSponsorForCategory:(NSString *)category {
    return [[categories objectForKey:category] sponsor];
}

-(NSArray*)getContactHeadings {
    NSMutableArray* _headings = [[NSMutableArray alloc] init];
    NSArray* cs = contacts;
    for (UserContact* uc in cs) {
        NSString* n = [uc getSortValue];
        unichar ch = toupper([n characterAtIndex:0]);
        NSString* c = [NSString stringWithCharacters:&ch length:1];
        if ([_headings count] == 0 || ![[_headings objectAtIndex:[_headings count]-1] isEqualToString:c])
            [_headings addObject:c];
    }
        
    return _headings;
}

-(NSArray*)getContacts {
    while (loadingContacts)
        [NSThread sleepForTimeInterval:0.20];
    return contacts;
}

-(NSArray*)getContactsForHeading:(NSString *)h {
    while (loadingContacts)
        [NSThread sleepForTimeInterval:0.20];
    NSMutableArray* _cs = [[NSMutableArray alloc] init];
    NSArray* cs = contacts;
    for (UserContact* uc in cs) {
        NSString* n = [uc getSortValue];
        if (toupper([n characterAtIndex:0]) == toupper([h characterAtIndex:0]))
            [_cs addObject:uc];
    }
    
    return _cs;
}

-(int)getIndexForContact:(UserContact*)uc {
    int index = -1;
    for (int i=0; i<[contacts count] && index == -1; i++) {
        UserContact*u = [contacts objectAtIndex:i];
        if ([uc isEqual:u])
            index = i;
    }
    return index;
}

-(UserContact*) chooseRandomContact {
    while (loadingContacts)
        [NSThread sleepForTimeInterval:0.20];
    if ([contacts count] == 0) return nil;
    
    BOOL chooseRecent = ([RecentContacts count] > 0 && arc4random() % 3 != 0);
    NSArray* cs = (chooseRecent) ? RecentContacts : contacts;
    NSInteger r = arc4random() % [cs count];
    return chooseRecent ? [self findUserByPhone:[cs objectAtIndex:r]] : [cs objectAtIndex:r];
}

-(NSArray*)getAllMessages {
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:allMessages];
    NSArray *ret = [orderedSet array];
    return ret;
}

-(NSArray*)getEventMessages {
    NSMutableArray* eventMessages = [[NSMutableArray alloc] init];
    for (int i=0; i<[allMessages count]; i++) {
        if ([[allMessages objectAtIndex:i] eventToggle])
            [eventMessages addObject:[allMessages objectAtIndex:i]];
    }
    return eventMessages;
}

-(NSArray*)getPinnedMessages {
    return [SqlDb getPinnedMessages];
}

-(void) mergeMessages {
    int v = 0, r = 0;
    NSArray* bs = [self getMessagesForCategory:@"Badges"];
    if (bs == nil)
        allMessages = [[NSMutableArray alloc] init];
    else
        allMessages = [NSMutableArray arrayWithArray:[self getMessagesForCategory:@"Badges"]];
    while (v < [tmpVersionMessages count] || r < [tmpRegMessages count]) {
        if (v < [tmpVersionMessages count]){
            [allMessages addObject:[tmpVersionMessages objectAtIndex:v]];
            v++;
        }
        if (r < [tmpRegMessages count]) {
            [allMessages addObject:[tmpRegMessages objectAtIndex:r]];
            r++;
        }
    }

    [allMessages filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary* bindings) {
        return [self getMessageScore:(Message*)obj] < HIDEMESSAGE || Skin == nil;
    }]];
}

-(NSArray*)resortMessages {
    [tmpVersionMessages sortUsingComparator:^NSComparisonResult(id m1, id m2) {
        int score1 = [self getMessageScore:(Message*)m1];
        int score2 = [self getMessageScore:(Message*)m2];
        
        return (score1 < score2) ? NSOrderedAscending : (score1 > score2) ? NSOrderedDescending : NSOrderedSame;
    }];
    [tmpRegMessages sortUsingComparator:^NSComparisonResult(id m1, id m2) {
        int score1 = [self getMessageScore:(Message*)m1];
        int score2 = [self getMessageScore:(Message*)m2];
        
        return (score1 < score2) ? NSOrderedAscending : (score1 > score2) ? NSOrderedDescending : NSOrderedSame;
    }];
    
    [self mergeMessages];
    
    return allMessages;
}

-(void)setMessagePin:(Message*)msg withValue:(BOOL)pin {
    Message*m = [self findMessageWithID:[msg msgId]];
    
    if (m != nil)
        [m setPinned:pin];
}

-(Message*)findMessageWithID:(int)msgid {
    Message* ret;
    for (Message* m in allMessages) {
        if ([m msgId] == msgid) {
            ret = m;
            break;
        }
    }
    
    return ret;
}

-(int)getMessageScore:(Message*)m {
    int s = arc4random() % 3;
    
    //if ([[categories objectForKey:[m category]] sponsor] == NULL)
        //s += 5;
    if (CategoryList != nil && [[CategoryList objectForKey:[m category]] isEqualToString: @"0"])
        s += HIDEMESSAGE;
    
    if (![m newMsg])
        s += 4;
    if (![m liked])
        s += 1;
    if (![m pinned])
        s += 1;
    
    s += ([m order] / 3);
    
    return s;
}

-(NSArray*)getMessagesForCategory:(NSString*)category {
    if ([category isEqualToString:NSLocalizedString(@"Your Photos Title", nil)])
        return localImages;
    else if ([category isEqualToString:NSLocalizedString(@"Your Messages Title", nil)])
        return YourMessages;
    else if ([category isEqualToString:NSLocalizedString(@"Recent Messages Title", nil)])
        return RecentMessages;
    else {
        if ([categories objectForKey:category] == nil)
            return nil;
        
        NSMutableArray* ms = [[NSMutableArray alloc] init];
        for (Message*m in [[categories objectForKey:category] messages]) {
            if (![SqlDb isFlagged:m])
                [ms addObject:m];
        }
        return ms;
    }
}

-(int)getNewMessageCount {
    int c = 0;
    for (MessageCategory* category in [categories keyEnumerator]) {
        for (Message* msg in [[categories objectForKey:category] messages]) {
            if ([msg newMsg])
                c++;
        }
    }
    return c;
}

-(int)getNewMessageCountForCategory:(NSString*)category {
    int c = 0;
    for (Message* msg in [[categories objectForKey:category] messages]) {
        if ([msg newMsg])
            c++;
    }
    return c;
}

const int RECENTWATCHCOUNT=5;
int irecent = 0;
Message* recentMsgs[RECENTWATCHCOUNT];
-(Message*)chooseRandomMessage {
    BOOL chooseRecent = ([RecentCategories count] > 0 && arc4random() % 3) != 0;
    BOOL chooseSponsor = Skin != nil && arc4random() % 3 != 0;
    NSInteger m = -1;
    MessageCategory* cat;
    
    int iloop = 0;
    Message* rndmsg = nil;
    while (rndmsg == nil) {
        NSMutableDictionary* cs = (chooseRecent) ? RecentCategories : categories;
        if (chooseSponsor && [self getSponsorCategories] != nil) {
            NSArray* sponsoredCats = [self getSponsorCategories];
            cat = [sponsoredCats objectAtIndex:(arc4random() % [sponsoredCats count])];
        }
        else {
            NSInteger c = arc4random() % [cs count];
            for (MessageCategory* ms in cs) {
                if (c == 0)
                    cat = ms;
                c--;
            }
        }
        if ([categories objectForKey:cat] == nil || [[[categories objectForKey:cat] messages] count] == 0) {
            [RecentCategories removeObjectForKey:cat];
            chooseRecent = ([RecentCategories count] > 0 && arc4random() % 3) != 0;
            [Settings SaveSetting:SettingRecentCategories withValue:RecentCategories];
        }
        else {
            m = arc4random() % [[[categories objectForKey:cat] messages] count];
        }
        rndmsg = [[[categories objectForKey:cat] messages] objectAtIndex:m];
        for (int i=0; iloop < 10 && i<RECENTWATCHCOUNT; i++) {
            if (recentMsgs[i] != nil && [recentMsgs[i] msgId] == [rndmsg msgId])
                rndmsg = nil;
        }
        iloop++;
    }
    recentMsgs[irecent%RECENTWATCHCOUNT] = rndmsg;
    irecent++;
    return rndmsg;
}

-(UserContact*)findUserByPhone:(NSString*)targetPhone {
    while (loadingContacts)
        [NSThread sleepForTimeInterval:0.20];

    for (UserContact* uc in contacts) {
        if ([uc hasPhone:targetPhone])
             return uc;
    }
    
    return nil;
}

-(void)selectUser:(UserContact*)contact toValue:(BOOL)on {
    bool found = false;
    for (int i=0; i<[selectContacts count]; i++) {
        UserContact* uc = (UserContact*)[selectContacts objectAtIndex:i];
        found |= ([[contact phones] count] > 0 && [uc hasPhone:[[contact phones] objectAtIndex:0]]);
        if (found && !on) {
            [selectContacts removeObjectAtIndex:i];
            i--;
        }
    }
    if (!found && on)
        [selectContacts addObject:contact];
}

-(NSArray*)getSelectedUsers {
    return selectContacts;
}

-(BOOL)isUserSelected:(UserContact*)contact {
    bool found = false;
    for (int i=0; !found && i<[selectContacts count]; i++) {
        UserContact* uc = (UserContact*)[selectContacts objectAtIndex:i];
        found |= [[contact phones] count] > 0 && [uc hasPhone:[[contact phones] objectAtIndex:0]];
    }
    
    return found;
}

-(void)clearSelectedUsers {
    [selectContacts removeAllObjects];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    //abort the data load
    tmpCategories = categories;
    parseFailed = true;
    NSLog(@"parsing failed");
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    currentElement = elementName;
    if ([elementName isEqualToString:@"notes"]) {
        [SqlDb archiveAllCategories];
        LastNoteDownload = [attributeDict objectForKey:@"ts"];
        if (AppID == nil || ![AppID isEqualToString:[attributeDict objectForKey:@"app"]]) {
            AppID = [attributeDict objectForKey:@"app"];
            [Settings SaveSetting:SettingAppID withValue:AppID];
            //We changed the appid, so we need to re-register for push notifications
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate registerRemoteNotificationWithAzure];
        }
        [CurrentUser setExplorerPoints:[[attributeDict objectForKey:@"ep"] intValue]];
        [CurrentUser setSharerPoints:[[attributeDict objectForKey:@"sp"] intValue]];
        [CurrentUser setMusePoints:[[attributeDict objectForKey:@"mp"] intValue]];
        
        [Settings SaveSetting:SettingLastNoteDownload withValue:LastNoteDownload];
    }
    else if ([elementName isEqualToString:@"ns"]) {
        NotificationMsgs = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:@"skin"]) {
        Skin = [[SkinInfo alloc] init];
        
        [Skin setSkinID:[[attributeDict objectForKey:@"id"] integerValue]];
        [Skin setSkinName:[attributeDict objectForKey:@"name"]];
        [Skin setMasterName:[attributeDict objectForKey:@"master"]];
        [Skin setColor1:[attributeDict objectForKey:@"c1"]];
        [Skin setColor2:[attributeDict objectForKey:@"c2"]];
        [Skin setColor3:[attributeDict objectForKey:@"c3"]];
        [Skin setHomeURL:[attributeDict objectForKey:@"home"]];
        [Skin setLaunchImageURL:[[NSMutableArray alloc] init]];
        [Skin setMainWindowTitle:[attributeDict objectForKey:@"title"]];
        [Skin setIconButtonURL:[attributeDict objectForKey:@"icon"]];

        [Settings SaveSkinData];
    }
    else if ([elementName isEqualToString:@"launch"]) {
        if ([[attributeDict objectForKey:@"width"] isEqualToString:@"320"]) {
            [[Skin LaunchImageURL] addObject:[attributeDict objectForKey:@"url"]];
            ImageDownloader* img =
                [[ImageDownloader alloc] initWithUrl:[attributeDict objectForKey:@"url"]];
            [img load];
        }
    }
    else if ([elementName isEqualToString:@"c"]) {
        categoryOrder = 0;
        NSString* name = [attributeDict objectForKey:@"name"];
        [SqlDb categoryExists:name];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        isBadge = [name isEqualToString:@"Badges"];

        currentCategory = [[MessageCategory alloc] initWithName:name];
        [currentCategory setOrder:[tmpCategories count]];
        [currentCategory setCatid:([[attributeDict allKeys] containsObject:@"id"] ?
                                   [[attributeDict objectForKey:@"id"] intValue] : 0)];
        [currentCategory setRequired:([[attributeDict allKeys] containsObject:@"required"] &&
                                      ![[attributeDict objectForKey:@"required"] isEqualToString:@"0"])];
        [currentCategory setNewCategory:([[attributeDict allKeys] containsObject:@"new"] &&
                                         ![[attributeDict objectForKey:@"new"] isEqualToString:@"0"])];
        [currentCategory setChosen:(CategoryList == nil ||
                                    [CategoryList objectForKey:[currentCategory name]] == nil ||
                                    ![[CategoryList objectForKey:[currentCategory name]] isEqualToString:@"0"])];
        [currentCategory setMessages:[[NSMutableArray alloc] init]];
        if ([currentCategory required]) {
            if (InitialCategory == nil || [InitialCategory length] == 0) {
                InitialCategory = [currentCategory name];
                [Settings SaveSetting:InitialCategory withValue:[currentCategory name]];
            }
            if (CategoryList != nil && [[CategoryList objectForKey:[currentCategory name]] isEqualToString:@"0"])
                [CategoryList setObject:@"1" forKey:[currentCategory name]];
        }
        [currentCategory setEventToggle:([attributeDict objectForKey:@"event"] != nil &&
                                         [[attributeDict objectForKey:@"event"] isEqualToString: @"1"])];
        if ([CategoryList objectForKey:name] == nil)
            [CategoryList setObject:([currentCategory eventToggle] ? @"1" : @"0") forKey:name];
        versionMsg = NO;
        if ([attributeDict objectForKey:@"version"] != nil)
            versionMsg = [[attributeDict objectForKey:@"version"] isEqualToString:@"1"];
        BOOL useIcon = false;
        if ([[attributeDict allKeys] containsObject:@"useicon"])
            useIcon = [[attributeDict objectForKey:@"useicon"] isEqualToString:@"1"];
        [currentCategory setUseIcon:useIcon];
        if ([[attributeDict allKeys] containsObject:@"url"] &&
                [[attributeDict allKeys] containsObject:@"icon"]) {
            NSString* url = [attributeDict objectForKey:@"url"];
            NSString* icon = [attributeDict objectForKey:@"icon"];
            if ([url length] > 0 && [icon length] > 0) {
                SponsorInfo* sponsor = [[SponsorInfo alloc] init];
                [sponsor setUrl:url];
                [sponsor setIcon:icon];
                [currentCategory setSponsor:sponsor];
            }
        }
        //if (CategoryList != nil && [currentCategory newCategory]) {
        if (CategoryList != nil && [currentCategory sponsor] != nil) {
            [CategoryList setObject:@"1" forKey:[currentCategory name]];
            [SqlDb addChosenCategory:[currentCategory name]];
        }

        [tmpCategories setValue:currentCategory forKey:name];
    }
    else if ([elementName isEqualToString:@"n"]) {
        if ([attributeDict objectForKey:@"id"] == nil)
            currentMsgId++;
        else
            currentMsgId = [[attributeDict objectForKey:@"id"] intValue];
        newMsg = NO;
        if ([attributeDict objectForKey:@"new"] != nil)
            newMsg = [[attributeDict objectForKey:@"new"] isEqualToString:@"1"];
        if ([attributeDict objectForKey:@"liked"] != nil)
            likedMsg = [[attributeDict objectForKey:@"liked"] isEqualToString:@"1"];
        likeCount = 0;
        if ([attributeDict objectForKey:@"likecount"] != nil)
            likeCount = [[attributeDict objectForKey:@"likecount"] intValue];
        discoverPoints = 0;
        if ([attributeDict objectForKey:@"dp"] != nil)
            discoverPoints = [[attributeDict objectForKey:@"dp"] intValue];
        sharePoints = 0;
        if ([attributeDict objectForKey:@"sp"] != nil)
            sharePoints = [[attributeDict objectForKey:@"sp"] intValue];
        goPoints = 0;
        if ([attributeDict objectForKey:@"gp"] != nil)
            goPoints = [[attributeDict objectForKey:@"gp"] intValue];
        currentEventLoc = [attributeDict objectForKey:@"loc"];
        currentEventDate = [attributeDict objectForKey:@"edate"];
        xmldata = [[NSMutableString alloc] init];
        currentText = nil;
        currentMediaUrl = nil;
        currentUrl = nil;
    }
    else if ([elementName isEqualToString:@"t"])
        xmldata = [[NSMutableString alloc] init];
    else if ([elementName isEqualToString:@"text"] || [elementName isEqualToString:@"media"] ||
                                                      [elementName isEqualToString:@"url"])
        partsdata = [[NSMutableString alloc] init];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([currentElement isEqualToString:@"n"] || [currentElement isEqualToString:@"t"])
        [xmldata appendString:string];
    else if ([currentElement isEqualToString:@"text"] || [currentElement isEqualToString:@"media"] ||
             [currentElement isEqualToString:@"url"])
         [partsdata appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"n"]) {
        if (![SqlDb isFlaggedId:currentMsgId]) {
            NSString* m = (currentText==nil && currentMediaUrl==nil && currentUrl==nil) ? xmldata : currentText;
            Message* msg = [[Message alloc] initWithId:currentMsgId
                                                  text:m
                                              mediaUrl:currentMediaUrl
                                                   url:currentUrl
                                           forCategory:[currentCategory name]
                                                 isNew:newMsg];
            [msg setLiked:likedMsg];
            [msg setLikeCount:likeCount];
            [msg setDiscoverPoints:discoverPoints];
            [msg setSharePoints:sharePoints];
            [msg setGoPoints:goPoints];
            [msg setBadge:isBadge];
            [msg setVersion:versionMsg];
            [msg setOrder:categoryOrder];
            [msg setPinned:[self isPinned:msg]];
            [msg setEventDate:currentEventDate];
            [msg setEventLocation:currentEventLoc];
            [msg setEventToggle:[currentCategory eventToggle]];
            categoryOrder++;
            [[currentCategory messages] addObject:msg];
            if (versionMsg)
                [tmpVersionMessages addObject:msg];
            else
                [tmpRegMessages addObject:msg];
        }
    }
    else if ([elementName isEqualToString:@"t"]) {
        [NotificationMsgs addObject:xmldata];
    }
    else if ([elementName isEqualToString:@"notes"]) {
        if (!notificationOnly) {
            [Settings UpdateCategoryList];
        }

        [tmpVersionMessages sortUsingComparator:^NSComparisonResult(id m1, id m2) {
            int score1 = [self getMessageScore:(Message*)m1];
            int score2 = [self getMessageScore:(Message*)m2];
            
            return (score1 < score2) ? NSOrderedAscending : (score1 > score2) ? NSOrderedDescending : NSOrderedSame;
        }];
        [tmpRegMessages sortUsingComparator:^NSComparisonResult(id m1, id m2) {
            int score1 = [self getMessageScore:(Message*)m1];
            int score2 = [self getMessageScore:(Message*)m2];
            
            return (score1 < score2) ? NSOrderedAscending : (score1 > score2) ? NSOrderedDescending : NSOrderedSame;
        }];
        
    }
    else if ([elementName isEqualToString:@"text"] && [partsdata length] > 0)
        currentText = partsdata;
    else if ([elementName isEqualToString:@"media"] && [partsdata length] > 0)
        currentMediaUrl = partsdata;
    else if ([elementName isEqualToString:@"url"] && [partsdata length] > 0)
        currentUrl = partsdata;
}

-(BOOL)isPinned:(Message*)msg {
    BOOL ret = false;
    for (int i=0; i<[pinnedMsgs count] && !ret; i++)
        ret = [msg msgId] == [[pinnedMsgs objectAtIndex:i] msgId];
    
    return ret;
}

@end
