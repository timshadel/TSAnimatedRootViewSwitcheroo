//
//  LRNavStackContainer.h
//

@import UIKit;
@import Foundation;

typedef NS_ENUM(NSUInteger, LRNavStackAnimationDirection) {
    LRNavStackAnimationDirectionForward,
    LRNavStackAnimationDirectionReverse
};

@protocol LRNavStackContainerDelegate;

@interface LRNavStackContainer : UIViewController

@property (nonatomic, weak) id<LRNavStackContainerDelegate>delegate;

+ (instancetype)setupWithDelegate:(id<LRNavStackContainerDelegate>)delegate;
+ (instancetype)setupNavStack:(UIViewController *)navStack andDelegate:(id<LRNavStackContainerDelegate>)delegate;
+ (void)useNavStack:(UIViewController *)navStack direction:(LRNavStackAnimationDirection)direction;

- (id)initWithNavStack:(UIViewController *)navStack andDelegate:(id<LRNavStackContainerDelegate>)delegate;
- (void)switchToNavStack:(UIViewController *)navStack direction:(LRNavStackAnimationDirection)direction;

@end


@protocol LRNavStackContainerDelegate <NSObject>
- (id <UIViewControllerAnimatedTransitioning>)navStackContainer:(LRNavStackContainer *)navStackContainer
                                animationControllerForDirection:(LRNavStackAnimationDirection)direction
                                             fromViewController:(UIViewController *)fromViewController
                                               toViewController:(UIViewController *)toViewController;
@end
