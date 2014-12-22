//
//  LRNavStackContainer.m
//

#import "LRNavStackContainer.h"

typedef void (^LRTransitionCompletionBlock)(BOOL didComplete);

__strong static LRNavStackContainer *sharedContainer;

@interface LRNavStackTransitionContext : NSObject <UIViewControllerContextTransitioning>

@property (nonatomic, copy) LRTransitionCompletionBlock completionBlock;

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController
                          toViewController:(UIViewController *)toViewController;

@end

@interface LRNavStackContainer ()

@property (nonatomic, strong) UIViewController *navStack;

@end

@implementation LRNavStackContainer

+ (instancetype)setupWithDelegate:(id<LRNavStackContainerDelegate>)delegate {
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        sharedContainer = [[LRNavStackContainer alloc] initWithDelegate:delegate];
    });
    return sharedContainer;
}

+ (instancetype)setupNavStack:(UIViewController *)navStack andDelegate:(id<LRNavStackContainerDelegate>)delegate {
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        sharedContainer = [[LRNavStackContainer alloc] initWithNavStack:navStack andDelegate:delegate];
    });
    return sharedContainer;
}

+ (void)useNavStack:(UIViewController *)navStack direction:(LRNavStackAnimationDirection)direction {
    [sharedContainer switchToNavStack:navStack direction:direction];
}

- (id)initWithDelegate:(id<LRNavStackContainerDelegate>)delegate {
    return [self initWithNavStack:nil andDelegate:delegate];
}

- (id)initWithNavStack:(UIViewController *)navStack andDelegate:(id<LRNavStackContainerDelegate>)delegate {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.navStack = navStack;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _switchToNavStack:self.navStack direction:LRNavStackAnimationDirectionForward];
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
    } else if (viewController == self.navStack && [self.navStack isViewLoaded] && self.navStack.view.superview) {
        shouldSwitch = NO;
    }
    return shouldSwitch;
}

- (id<UIViewControllerAnimatedTransitioning>)animatorToViewController:(UIViewController *)viewController
                                                            direction:(LRNavStackAnimationDirection)direction {
    if (!self.navStack || self.navStack == viewController) {
        return nil;
    }
    
    SEL animSelector = @selector(navStackContainer:animationControllerForDirection:fromViewController:toViewController:);
  if ([self.delegate respondsToSelector:animSelector]) {
    return [self.delegate navStackContainer:self
                animationControllerForDirection:direction
                             fromViewController:self.navStack
                               toViewController:viewController];
  }

    return nil;
}

- (void)_switchToNavStack:(UIViewController *)toViewController direction:(LRNavStackAnimationDirection)direction {
    
  if (![self shouldSwitchToViewController:toViewController]) {
    return;
  }

  UIViewController *fromViewController = (toViewController == self.navStack) ? nil : self.navStack;
    id<UIViewControllerAnimatedTransitioning>animator = [self animatorToViewController:toViewController
                                                                             direction:direction];
    
  UIView *toView = toViewController.view;
  [toView setTranslatesAutoresizingMaskIntoConstraints:YES];
  toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  toView.frame = self.view.bounds;

    [fromViewController willMoveToParentViewController:nil];
  [self addChildViewController:toViewController];
  LRTransitionCompletionBlock completionBlock = ^(BOOL didComplete) {
    [fromViewController.view removeFromSuperview];
    [fromViewController removeFromParentViewController];
    [toViewController didMoveToParentViewController:self];
    
    if ([animator respondsToSelector:@selector (animationEnded:)]) {
      [animator animationEnded:didComplete];
    }
  };

  if (animator) {
        LRNavStackTransitionContext *transitionContext = [[LRNavStackTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController];
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

@interface LRNavStackTransitionContext ()
@property (nonatomic, strong) NSDictionary *privateViewControllers;
@end

@implementation LRNavStackTransitionContext

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
