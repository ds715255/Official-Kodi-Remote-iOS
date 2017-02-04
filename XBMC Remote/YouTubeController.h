//
//  YouTubeController.h
//  Kodi Remote
//
//  Created by Daniel Sabel on 29/01/17.
//  Copyright © 2017 joethefox inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "DSJSONRPC.h"

@interface YouTubeController : UIViewController<WKNavigationDelegate, WKScriptMessageHandler> {
     NSString *JSHandler;
    DSJSONRPC *jsonRPC;
    WKWebView *youtubeweb;
}
@property (weak, nonatomic) IBOutlet UIView *youtubewebhost;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *gobackButton;

@end
