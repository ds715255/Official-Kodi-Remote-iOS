//
//  YouTubeController.m
//  Kodi Remote
//
//  Created by Daniel Sabel on 29/01/17.
//  Copyright © 2017 joethefox inc. All rights reserved.
//

#define CocoaJSHandler          @"mpajaxhandler"

#import "YouTubeController.h"
#import "AppDelegate.h"
#import "StackScrollViewController.h"
#import "ViewControllerIPad.h"
#import "GlobalData.h"

@interface YouTubeController () {
   
}

@end

@implementation YouTubeController

- (void)viewDidLoad {
    [super viewDidLoad];
    jsonRPC = [[DSJSONRPC alloc] initWithServiceEndpoint:[AppDelegate instance].getServerJSONEndPoint andHTTPHeaders:[AppDelegate instance].getServerHTTPHeaders];
    
    
    self->JSHandler = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"ajax_handler" withExtension:@"js"] encoding:NSUTF8StringEncoding error:nil];
    
    
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc]init];
    WKUserContentController *userController = [[WKUserContentController alloc]init];
    WKUserScript *userScript = [[WKUserScript alloc]initWithSource:self->JSHandler injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [userController addUserScript:userScript];
    [userController addScriptMessageHandler:self name:@"ajaxCall"];
    webConfig.userContentController = userController;
    webConfig.allowsInlineMediaPlayback = NO;
    webConfig.requiresUserActionForMediaPlayback = YES;
    
    youtubeweb = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, _youtubewebhost.frame.size.width, _youtubewebhost.frame.size.height) configuration:webConfig];
    
    [_youtubewebhost addSubview:youtubeweb];
    [self observe];
    
    youtubeweb.navigationDelegate = self;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: @"https://www.youtube.com"] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 30000];
    [youtubeweb loadRequest: request];
    
}

-(void)observe {
    [_youtubewebhost addObserver:self forKeyPath:@"frame" options:0 context:NULL];
    [_youtubewebhost.layer addObserver:self forKeyPath:@"bounds" options:0 context:NULL];
    [_youtubewebhost.layer addObserver:self forKeyPath:@"transform" options:0 context:NULL];
    [_youtubewebhost.layer addObserver:self forKeyPath:@"position" options:0 context:NULL];
    [_youtubewebhost.layer addObserver:self forKeyPath:@"zPosition" options:0 context:NULL];
    [_youtubewebhost.layer addObserver:self forKeyPath:@"anchorPoint" options:0 context:NULL];
    [_youtubewebhost.layer addObserver:self forKeyPath:@"anchorPointZ" options:0 context:NULL];
    [_youtubewebhost.layer addObserver:self forKeyPath:@"frame" options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    youtubeweb.frame = CGRectMake(0, 0, _youtubewebhost.frame.size.width, _youtubewebhost.frame.size.height);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onGoBack:(id)sender {
    if(youtubeweb.canGoBack) {
        [youtubeweb goBack];
    }
    
}
- (IBAction)onRefresh:(id)sender {
    [youtubeweb reload];
}



+(NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [query componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [queryStringDictionary setObject:value forKey:key];
    }
    return queryStringDictionary;
}

-(void) openVideoUrl:(NSString*) videoId {
    NSDictionary *params =
        [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"plugin://plugin.video.youtube/?action=play_video&videoid=%@", videoId], @"file", nil], @"item", nil];
    [jsonRPC callMethod:@"Player.Open" withParameters:params onCompletion:nil];
}

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if([message.name isEqualToString:@"ajaxCall"]) {
        // The message.body contains the object being posted back
        NSString *requestedURLString = [message.body valueForKey:@"url"];
        NSLog(@"ajax request: %@", requestedURLString);

        if([requestedURLString containsString:@"www.youtube.com/watch?"]) {
            NSURL *url = [[NSURL alloc] initWithString:requestedURLString];
            NSDictionary *args = [YouTubeController parseQueryString:url.query];
            NSString *video_id = [args valueForKey:@"v"];
            NSLog(@"Playing YouTube video %@", video_id);
            [self openVideoUrl:video_id];
            
        }
    }
}



- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation {
    CGSize size = [AppDelegate instance].windowController.stackScrollViewController.view.frame.size;
    [self.view setFrame:CGRectMake(0, 0, size.width, size.height)];
}
@end
