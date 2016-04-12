#import "AppDelegate.h"
#import "GCTurnBasedMatchHelper.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
	
    self.window.rootViewController = self.viewController;
	
    [self.window makeKeyAndVisible];
	
	[[GCTurnBasedMatchHelper sharedInstance] authenticateLocalUser];
	
    return YES;
}

@end
