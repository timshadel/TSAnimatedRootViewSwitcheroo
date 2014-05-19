LRNavStackContainer
===================

`LRNavStackContainer` is a simple container controller that lets you transition between `UIViewController`s.

`LRNavStackContainer` helps you manage your app's nav stacks. It's very common to have several slices in your application. For example:

  - Normal day-to-day app use (`UITabBarController` with `UINavigationController`s on each tab)
  - Intro (`UIPageViewController`)
  - Logged out (perhaps `UINavigationController` with a title)
  - Upgrading DB (plain `UIViewController`)
  - Network down (another plain `UIViewController`)

`LRNavStackContainer` helps your app transition smoothly between these very different structures using the [iOS 7 UIViewControllerAnimatedTransitioning Protocol](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIViewControllerAnimatedTransitioning_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40013387), including animation libraries like [VCTransitionsLibrary](https://github.com/ColinEberhardt/VCTransitionsLibrary/).

## Example

First, grab it with Cocoapods:

```sh
pod 'LRNavStackContainer', '~> 1.0.0'
```

Now let's assume we have a singleton class which creates our separate nav stacks, with a simple interface like this:

``` objective-c
@interface OurNavStacks : NSObject

// Normal use
+ (UITabBarController *)appStack;

// Other uses
+ (UIPageViewController *)introStack;
+ (UINavigationController *)loggedOutStack;
+ (UIViewController *)upgradingDBStack;
+ (UIViewController *)networkDownStack;

@end
```

Then we can easily add our `LRNavStackContainer` to help transition from one to another.

``` objective-c
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIViewController *stack = nil;

    if (/* logged in */) {
        stack = [OurNavStacks appStack];
    } else {
        stack = [OurNavStacks introStack];
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [LRNavStackContainer setupNavStack:stack andDelegate:self];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)signOut {
  // Do some stuff
  [LRNavStackContainer useNavStack:[OurNavStacks loggedOutStack] direction:LRNavStackAnimationDirectionReverse];
}

- (void)signIn {
  // Do some stuff
  [LRNavStackContainer useNavStack:[OurNavStacks appStack] direction:LRNavStackAnimationDirectionForward];
}

- (id<UIViewControllerAnimatedTransitioning>)navStackContainer:(LRNavStackContainer *)navStackContainer
                               animationControllerForDirection:(LRNavStackAnimationDirection)direction
                                            fromViewController:(UIViewController *)fromViewController
                                              toViewController:(UIViewController *)toViewController {

    // Let's use some awesome transitions from the VCTransitionsLibrary
    CEReversibleAnimationController *animator = [CENatGeoAnimationController new];
    animator.reverse = (direction == LRNavStackAnimationDirectionReverse);
    return animator;

    // If we want a Cube animation for login/logout, but a Flip animation for UpgradeDB => app
    // then we'd check the fromViewController/toViewController pairs and return the right animation.
    
    // Return nil for no animation.
}

@end
```

The main thing is that the `LRNavStackContainer` is used as your window's rootViewController, and then you can change the nav stack as needed by calling `+ useNavStack:direction:`.

Lastly, you have full control over which animation is used to transition between your stacks, including custom animations you create.

Because this is a `UIViewController` that implements the custom container controller methods, you can do quite a bit more with it. The code's evolution is will always prefer to stick with switching between traditional nav stacks as the primary use case.
