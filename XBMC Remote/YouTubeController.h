//
//  YouTubeController.h
//  Kodi Remote
//
//  Created by Daniel Sabel on 29/01/17.
//  Copyright © 2017 joethefox inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSJSONRPC.h"

@interface YouTubeController : UIViewController<UIWebViewDelegate> {
     NSString *JSHandler;
    DSJSONRPC *jsonRPC;
}
@property (weak, nonatomic) IBOutlet UIWebView *youtubeweb;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *gobackButton;

@end
