## Control Panel Interactive Animation

![](https://github.com/seedante/ControlPanelAnimation/blob/master/ControlPanelInteractiveAnimation.gif?raw=true)

Continue the topic ["Interactive Animations"](https://www.objc.io/issues/12-animations/interactive-animations/), objc.io talked two years ago. When the article was released(just before iOS 8), a key question can't be resolved by UIView Animation. Two authors of the article implement the above interacitive animation in two ways: UIKit Dynamics, and spring animation effect created by CADisplayLink, latter is admirable.


Almost two weeks ago, [Session 216: Advances in UIKit Animations and Transitions](https://developer.apple.com/videos/play/wwdc2016/216/) introduces [UIViewPropertyAnimator](https://developer.apple.com/reference/uikit/uiviewpropertyanimator) in iOS 10 to make completely interactive, interruptible animations.  


I learn related sessions and implement above animation in two ways:

1. UIView Animation/Core Animation: after iOS 8, it's easy to achieve the goal.
2. UIViewPropertyAnimator: its usage is very like UIView Animation API. Though it's a little complex to implement above animation.

## Requirements

1. Control-Panel-Interactive-Animation: iOS 8+, Swift 2.2+
2. iOS10-Control-Panel-Interactive-Animation: Xcode 8 beta, iOS 10+, Swift 3

