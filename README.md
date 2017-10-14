## Control Panel Interactive Animation

![](https://github.com/seedante/ControlPanelAnimation/blob/master/ControlPanelInteractiveAnimation.gif?raw=true)

Continue the topic ["Interactive Animations"](https://www.objc.io/issues/12-animations/interactive-animations/) which objc.io talked two years ago. When the article was released(just before WWDC2014 and iOS 8), a key problem can't be resolved by UIView Animation in iOS 7. Two authors of the article implement the above interacitive animation in two ways: UIKit Dynamics, and spring animation effect implemented by CADisplayLink, latter is admirable.

[WWDC 2014 Session 236: Building Interruptible and Responsive Interactions](https://developer.apple.com/videos/play/wwdc2014/236/) explains how to bulid fluid interactive animations. There are three transition problems to resolve:

1. Animation to Gesture: pause or stop animation in current position.
2. Gesture to Animation: add a spring animation with special initial velocity to make smooth transition.
3. Animation to Animation: reverse animation in BeginFromCurrentState or Additive mode.

Almost two weeks ago, [Session 216: Advances in UIKit Animations and Transitions](https://developer.apple.com/videos/play/wwdc2016/216/) introduces [UIViewPropertyAnimator](https://developer.apple.com/reference/uikit/uiviewpropertyanimator) in iOS 10 to make completely interactive, interruptible animations.  

I implement above animation in two ways:

1. UIView Animation/Core Animation: after iOS 8, it's very easy to achieve the goal; on iOS 7, there is a little limitation that UIView Animation is not additive until iOS 8 and Spring Core Animation is not public until iOS 9.
2. UIViewPropertyAnimator: it's awesome and very flexible, and relatively complex, not a little. You can use it like UIView Animation, or in its style, or combine two styles. I show you how to implement above interactive animation by `UIViewPropertyAnimator` in three ways in 'iOS10-Control-Panel-Interactive-Animation' project. 

两篇详细的博客：

1. [交互式动画(上)：iOS 10 以下的实现](http://www.jianshu.com/p/f62cc43a5d6c)，使用 UIView Animation/Core Animation 来实现上述交互动画。
2. [交互式动画(下)：UIViewPropertyAnimator in iOS 10](http://www.jianshu.com/p/bc5fce6a06db)，使用 UIViewPropertyAnimator实现上述交互动画，这个类相当灵活，可以说是面向对象版本的 UIView Animation。但在实现交互控制时，相比 UIView Animation/Core Animation，使用上复杂了许多。

## Requirements

1. Control-Panel-Interactive-Animation: iOS 8+, Swift 2.2+
2. iOS10-Control-Panel-Interactive-Animation: Xcode 8 beta, iOS 10+, Swift 3

## View Controller Transition

Before iOS 10, view controller transition is not completely interactive, interruptible, for example, push and pop in UINavigationController: if start transition in non-interactive, you’ll have to wait until the transition animation is finished before you can do anything; if start transition in interactive, after interaction end, the transition animation is no more interactive. 

iOS 10 introduce the protocol `UIViewImplicitlyAnimating`, which `UIViewPropertyAnimator` conform to, into view controller transition protocol which is very complex now. Actually, with the help of `UIViewPropertyAnimator`, we can simplify view controller transition protocol. A demo for this: [iOS10PushPop](https://github.com/seedante/iOS-ViewController-Transition-Demo/tree/master/iOS10PushPop).

详细内容已在 [iOS 视图控制器转场详解](https://github.com/seedante/iOS-Note/wiki/View-Controller-Transition-PartII#Chapter3.7)中更新。
