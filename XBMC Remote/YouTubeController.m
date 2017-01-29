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
    
    // Do any additional setup after loading the view from its nib.
    self.youtubeweb.delegate = self;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString: @"https://www.youtube.com"] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 30000];
    [self.youtubeweb loadRequest: request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onGoBack:(id)sender {
    if(self.youtubeweb.canGoBack) {
        [self.youtubeweb goBack];
    }
    
}
- (IBAction)onRefresh:(id)sender {
    [self.youtubeweb reload];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)webViewDidStartLoad:(UIWebView *)webView {
     [webView stringByEvaluatingJavaScriptFromString:self->JSHandler];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:@""];
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] scheme] isEqual:CocoaJSHandler] || [request.URL.absoluteString containsString:@"www.youtube.com/watch?"]) {
        NSString *requestedURLString = [[[request URL] absoluteString] substringFromIndex:[CocoaJSHandler length] + 3];

        NSLog(@"ajax request: %@", requestedURLString);

        if([requestedURLString containsString:@"www.youtube.com/watch?"]) {
            NSDictionary *args = [YouTubeController parseQueryString:request.URL.query];
            NSString *video_id = [args valueForKey:@"v"];
            NSLog(@"Playing YouTube video %@", video_id);
            [self openVideoUrl:video_id];
            return YES;
        }
        
    }
    
    // keep us on youtube.com and don't follow ad links (not very safe but ok for now)
    if(![request.URL.host containsString:@".youtube."] &&
       ![request.URL.host containsString:@".google."]) {
        return YES;
    }
    return YES;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation {
    CGSize size = [AppDelegate instance].windowController.stackScrollViewController.view.frame.size;
    [self.view setFrame:CGRectMake(0, 0, size.width, size.height)];
}
@end
