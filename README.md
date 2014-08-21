TSAnimatedRootViewSwitcheroo
===================

`TSAnimatedRootViewSwitcheroo` is a simple container controller for your `UIWindow`'s `rootViewController` that lets you transition from one root controller to another.

`TSAnimatedRootViewSwitcheroo` helps you manage your app's root controllers. It's very common to have several slices in your application. For example:

  - Normal day-to-day app use (`UITabBarController` with `UINavigationController`s on each tab)
  - Intro (`UIPageViewController`)
  - Logged out (perhaps `UINavigationController` with a title)
  - Upgrading DB (plain `UIViewController`)
  - Network down (another plain `UIViewController`)

`TSAnimatedRootViewSwitcheroo` helps your app transition smoothly between these very different structures using the [iOS 7 UIViewControllerAnimatedTransitioning Protocol](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIViewControllerAnimatedTransitioning_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40013387), including animation libraries like [VCTransitionsLibrary](https://github.com/ColinEberhardt/VCTransitionsLibrary/).

## Example

First, grab it with Cocoapods:

```sh
pod 'TSAnimatedRootViewSwitcheroo', '~> 1.0.0'
```

Now let's assume we have a singleton class which creates our separate root controller, with a simple interface like this:

``` objective-c
@interface AppRoots : NSObject

// Normal use
+ (UITabBarController *)appRoot;

// Other uses
+ (UIPageViewController *)introRoot;
+ (UINavigationController *)loggedOutRoot;
+ (UIViewController *)upgradingDBRoot;
+ (UIViewController *)networkDownRoot;

@end
```

Then we can easily add our `TSAnimatedRootViewSwitcheroo` to help transition from one to another.

``` objective-c
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIViewController *root = nil;

    if (/* logged in */) {
        root = [AppRoots appRoot];
    } else {
        root = [AppRoots introRoot];
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [TSAnimatedRootViewSwitcheroo switcherooWithRoot:root andDelegate:self];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)signOut {
  // Do some stuff
  [TSAnimatedRootViewSwitcheroo useRoot:[AppRoots loggedOutRoot] direction:TSSwitcherooAnimationDirectionReverse];
}

- (void)signIn {
  // Do some stuff
  [TSAnimatedRootViewSwitcheroo useRoot:[AppRoots appRoot] direction:TSSwitcherooAnimationDirectionForward];
}

- (id<UIViewControllerAnimatedTransitioning>)switcheroo:(TSAnimatedRootViewSwitcheroo *)switcheroo
                               animationControllerForDirection:(TSSwitcherooAnimationDirection)direction
                                            fromViewController:(UIViewController *)fromViewController
                                              toViewController:(UIViewController *)toViewController {

    // Let's use some awesome transitions from the VCTransitionsLibrary
    CEReversibleAnimationController *animator = [CENatGeoAnimationController new];
    animator.reverse = (direction == TSSwitcherooAnimationDirectionReverse);
    return animator;

    // If we want a Cube animation for login/logout, but a Flip animation for UpgradeDB => app
    // then we'd check the fromViewController/toViewController pairs and return the right animation.
    
    // Return nil for no animation.
}

@end
```

The main thing is that the `TSAnimatedRootViewSwitcheroo` is used as your window's rootViewController, and then you can change the root controller as needed by calling `+ useRoot:direction:`.

Lastly, you have full control over which animation is used to transition between your stacks, including custom animations you create.

Because this is a `UIViewController` that implements the custom container controller methods, you can do quite a bit more with it. The code's evolution is will always prefer to stick with switching between root controllers as the primary use case.
