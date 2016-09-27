//
//  TSAnimatedRootViewSwitcheroo.h
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TSSwitcherooAnimationDirection) {
    TSSwitcherooAnimationDirectionForward,
    TSSwitcherooAnimationDirectionReverse
};

@protocol TSAnimatedRootViewSwitcherooDelegate;

@interface TSAnimatedRootViewSwitcheroo : UIViewController

@property (nonatomic, weak) id<TSAnimatedRootViewSwitcherooDelegate>delegate;

+ (instancetype)setupWithDelegate:(id<TSAnimatedRootViewSwitcherooDelegate>)delegate;
+ (instancetype)switcherooWithRoot:(UIViewController *)root andDelegate:(id<TSAnimatedRootViewSwitcherooDelegate>)delegate;
+ (void)useRoot:(UIViewController *)root direction:(TSSwitcherooAnimationDirection)direction;

- (id)initWithRoot:(UIViewController *)root andDelegate:(id<TSAnimatedRootViewSwitcherooDelegate>)delegate;
- (void)switchToRoot:(UIViewController *)root direction:(TSSwitcherooAnimationDirection)direction;

@end


@protocol TSAnimatedRootViewSwitcherooDelegate <NSObject>
- (id <UIViewControllerAnimatedTransitioning>)switcheroo:(TSAnimatedRootViewSwitcheroo *)switcheroo
                                animationControllerForDirection:(TSSwitcherooAnimationDirection)direction
                                             fromViewController:(UIViewController *)fromViewController
                                               toViewController:(UIViewController *)toViewController;
@end
