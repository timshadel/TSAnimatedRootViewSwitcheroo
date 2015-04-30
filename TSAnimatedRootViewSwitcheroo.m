//
//  TSAnimatedRootViewSwitcheroo.m
//

#import "TSAnimatedRootViewSwitcheroo.h"

typedef void (^TSSwitcherooCompletionBlock)(BOOL didComplete);

__strong static TSAnimatedRootViewSwitcheroo *sharedContainer;

@interface TSSwitcherooContext : NSObject <UIViewControllerContextTransitioning>

@property (nonatomic, copy) TSSwitcherooCompletionBlock completionBlock;

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController
                          toViewController:(UIViewController *)toViewController;

@end

@interface TSAnimatedRootViewSwitcheroo ()

@property (nonatomic, strong) UIViewController *root;

@end

@implementation TSAnimatedRootViewSwitcheroo

+ (instancetype)setupWithDelegate:(id<TSAnimatedRootViewSwitcherooDelegate>)delegate {
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        sharedContainer = [[TSAnimatedRootViewSwitcheroo alloc] initWithDelegate:delegate];
    });
    return sharedContainer;
}

+ (instancetype)switcherooWithRoot:(UIViewController *)root andDelegate:(id<TSAnimatedRootViewSwitcherooDelegate>)delegate {
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        sharedContainer = [[TSAnimatedRootViewSwitcheroo alloc] initWithRoot:root andDelegate:delegate];
    });
    return sharedContainer;
}

+ (void)useRoot:(UIViewController *)root direction:(TSSwitcherooAnimationDirection)direction {
    [sharedContainer switchToRoot:root direction:direction];
}

- (id)initWithDelegate:(id<TSAnimatedRootViewSwitcherooDelegate>)delegate {
    return [self initWithRoot:nil andDelegate:delegate];
}

- (id)initWithRoot:(UIViewController *)root andDelegate:(id<TSAnimatedRootViewSwitcherooDelegate>)delegate {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.root = root;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _switchToRoot:self.root direction:TSSwitcherooAnimationDirectionForward];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.root;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.root;
}

- (void)switchToRoot:(UIViewController *)root direction:(TSSwitcherooAnimationDirection)direction {
    NSParameterAssert (root);
    [self _switchToRoot:root direction:(TSSwitcherooAnimationDirection)direction];
    self.root = root;
}

#pragma mark Private Methods

- (BOOL)shouldSwitchToViewController:(UIViewController *)viewController {
    BOOL shouldSwitch = YES;
    if (!viewController) {
        shouldSwitch = NO;
    } else if (![self isViewLoaded]) {
        shouldSwitch = NO;
    } else if (viewController == self.root && [self.root isViewLoaded] && self.root.view.superview) {
        shouldSwitch = NO;
    }
    return shouldSwitch;
}

- (id<UIViewControllerAnimatedTransitioning>)animatorToViewController:(UIViewController *)viewController
                                                            direction:(TSSwitcherooAnimationDirection)direction {
    if (!self.root || self.root == viewController) {
        return nil;
    }

    SEL animSelector = @selector(switcheroo:animationControllerForDirection:fromViewController:toViewController:);
  if ([self.delegate respondsToSelector:animSelector]) {
    return [self.delegate switcheroo:self
                animationControllerForDirection:direction
                             fromViewController:self.root
                               toViewController:viewController];
  }

    return nil;
}

- (void)_switchToRoot:(UIViewController *)toViewController direction:(TSSwitcherooAnimationDirection)direction {

  if (![self shouldSwitchToViewController:toViewController]) {
    return;
  }

  UIViewController *fromViewController = (toViewController == self.root) ? nil : self.root;
    id<UIViewControllerAnimatedTransitioning>animator = [self animatorToViewController:toViewController
                                                                             direction:direction];

  UIView *toView = toViewController.view;
  [toView setTranslatesAutoresizingMaskIntoConstraints:YES];
  toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  toView.frame = self.view.bounds;

  [fromViewController dismissViewControllerAnimated:YES completion:nil];
  [fromViewController willMoveToParentViewController:nil];
  [self addChildViewController:toViewController];
  TSSwitcherooCompletionBlock completionBlock = ^(BOOL didComplete) {
    [fromViewController.view removeFromSuperview];
    [fromViewController removeFromParentViewController];
    [toViewController didMoveToParentViewController:self];

    if ([animator respondsToSelector:@selector (animationEnded:)]) {
      [animator animationEnded:didComplete];
    }
  };

  if (animator) {
        TSSwitcherooContext *transitionContext = [[TSSwitcherooContext alloc] initWithFromViewController:fromViewController toViewController:toViewController];
        transitionContext.completionBlock = completionBlock;
        [animator animateTransition:transitionContext];
    } else {
        [self.view addSubview:toViewController.view];
        completionBlock(YES);
    }
}

- (void)viewDidLayoutSubviews {
    [self setNeedsStatusBarAppearanceUpdate];
}

@end

#pragma mark - Private Transitionin Context

@interface TSSwitcherooContext ()
@property (nonatomic, strong) NSDictionary *privateViewControllers;
@end

@implementation TSSwitcherooContext

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController {
  NSAssert ([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view upon initializing the transition context.");

  if ((self = [super init])) {
    self.privateViewControllers = @{
      UITransitionContextFromViewControllerKey: fromViewController,
      UITransitionContextToViewControllerKey: toViewController,
    };
  }

  return self;
}

- (UIView *)containerView {
    return [self viewControllerForKey:UITransitionContextFromViewControllerKey].view.superview;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return viewController.view.frame;
    } else {
        return CGRectZero;
    }
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextToViewControllerKey]) {
        return [self viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame;
    } else {
        return CGRectZero;
    }
}

- (BOOL)isAnimated {
    return YES;
}

- (BOOL)isInteractive {
    return NO;
}

- (UIModalPresentationStyle)presentationStyle {
    return UIModalPresentationCustom;
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
  return self.privateViewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete {
  if (self.completionBlock) {
    self.completionBlock(didComplete);
  }
}

- (BOOL)transitionWasCancelled { return NO; }

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}

@end
