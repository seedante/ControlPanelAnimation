//
//  ViewController.swift
//  iOS10InteractiveAnimation
//
//  Created by seedante on 16/6/21.
//  Copyright © 2016年 seedante. All rights reserved.
//

import UIKit

extension UIViewAnimatingState{
    var description: String{
        switch self {
        case .inactive:
            return "inactive"
        case .active:
            return "active"
        case .stopped:
            return "stopped"
        }
    }
}

extension UIViewAnimatingPosition{
    var description: String{
        switch self {
        case .end:
            return "end"
        case .current:
            return "current"
        case .start:
            return "start"
        }
    }
}

/**
 Continue the topic "Interactive Animations" in https://www.objc.io/issues/12-animations/interactive-animations/ , use UIViewPropertyAnimator
 introduced in iOS 10 to implement control panel open/close interactive animation in its way. UIViewPropertyAnimator is additive except that 
 inited with UISpringTimingParameters and initialVelocity isn't (0,0).
 */

class ViewControllerZero: UIViewController {

    var pan = UIPanGestureRecognizer()
    var tap = UITapGestureRecognizer()
    var panelView = UIView()
    var panelOpened = true
    
    var animator: UIViewPropertyAnimator = UIViewPropertyAnimator()
    let duration: TimeInterval = 0.5
    let relayDuration: TimeInterval = 0.3
    let dampingRatio: CGFloat = 0.7
    let diff: CGFloat = 150
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panelView.frame = view.bounds
        panelView.center.y = view.center.y * (3 - 0.5)
        panelView.backgroundColor = UIColor.gray()
        panelView.layer.cornerRadius = 5
        view.addSubview(panelView)
        
        pan.addTarget(self, action: #selector(ViewControllerOne.handlePan(gesture:)))
        panelView.addGestureRecognizer(pan)
        tap.addTarget(self, action: #selector(ViewControllerOne.handleTap(gesture:)))
        panelView.addGestureRecognizer(tap)
    }

    // MARK: Helper Method
    /// Return an UIViewPropertyAnimator configured with the animation of open or close control panel.
    func interactiveAnimator() -> UIViewPropertyAnimator{
        // UIViewPropertyAnimator's animation is additive and can mix multiple animation blocks except UISpringTimingParameters with initialVelocity not equal (0, 0).
        let timing = UISpringTimingParameters(dampingRatio: dampingRatio, initialVelocity: CGVector(dx: 0, dy: 1))
        let targetY = panelOpened ? view.center.y + diff : view.center.y * 2.5
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
        animator.addAnimations({ [unowned self] in
            self.panelView.center.y = targetY
            })
        animator.addCompletion({ [unowned self] position in
            if position == .end{
                self.panelOpened = !self.panelOpened
            }
            print("Original Animation Completed with panel opened: \(self.panelOpened), poistion: \(position.description)")
            })
        return animator
    }
    
    /// Return a list (UISpringTimingParameters, Bool, CGFloat) to congigure new UIViewPropertyAnimator object and animation when pan gesture is ended.
    ///
    /// - Returns:
    ///     - relayTiming: An UISpringTimingParameters use to configure new UIViewPropertyAnimator object to continue animation smoothly;
    ///     - isUp: finger leave direction in Y axis: up or down;
    ///     - targetY: panelView's destination in Y axis.
    func relayTiming_direction_targetY(withPangesture panGesture: UIPanGestureRecognizer) -> (relayTiming:UISpringTimingParameters, isUp:Bool, targetY:CGFloat) {
        let gestureVelocity = panGesture.velocity(in: view)
        let isUp = gestureVelocity.y < 0 ? true : false
        let targetY = isUp ? view.center.y + diff : view.center.y * 2.5
        let velocityY = abs(gestureVelocity.y) / abs(panelView.center.y - targetY)
        let velocity = CGVector(dx: 0, dy: velocityY)
        let timing = UISpringTimingParameters(dampingRatio: dampingRatio, initialVelocity: velocity)
        return (timing, isUp, targetY)
    }
    
    /// Move panel view by your finger on the screen, just Y axis.
    func movePanelWithPan(gesture: UIPanGestureRecognizer){
        let point = gesture.translation(in: view)
        panelView.center.y += point.y
        gesture.setTranslation(CGPoint(x: 0, y: 0), in: view)
    }
    
    func checkState(of animator: UIViewPropertyAnimator){
        print(animator)
        print("state: \(animator.state.description)")
        print("isRunning: \(animator.isRunning)")
        print("isReversed: \(animator.isReversed)")
        print("timing: \(animator.timingParameters!)")
        print("duration: \(animator.duration)")
    }
    
    // MARK: Handle Gesture 
    /// After tap on panelView, it will go to opposite, if it's moving, go back. If you keep tap panelView before it reach opposite, it always go to opposite again.
    func handleTap(gesture: UITapGestureRecognizer){
        switch gesture.state {
        case .ended, .cancelled:
            switch animator.state {
            // If animator is not active, it means animator has completed its animation block or has not any animatin block to run.
            // But its configuration, include timing and duration, maybe changed in pan gesture, so must create a new animator with original configuration.
            case .inactive, .stopped:
                animator = interactiveAnimator()
                animator.startAnimation()
                print("Tap: start animation")
            // If animator is active, it's sure that there is an animation block is running. Pause and reverse it.
            case .active:
                animator.pauseAnimation()
                print(String(format: "Tap: Reverse from fractionComplete: %.2f", (animator.fractionComplete * 100)) + "%")
                animator.isReversed = !(animator.isReversed)
                animator.startAnimation()
            }
        default:break
        }
    }
    
    func handlePan(gesture: UIPanGestureRecognizer){
        //Run only one follow method.
        
        // Style I: Pause animation, then continue it after pan gesture is ended.
//        PauseAndContinueAnimation(withPanGesture: gesture)
        // Style II: Stop animation, then add a new animation complete the rest move after pan gesture is ended.
//        StopAndRenewAnimation(withPanGesture: gesture)
        /// Right way.
        fixDefect_PauseAndContinueAnimation(withPanGesture: gesture)
    }

    /// Pause the animator in pan gesture's 'began' stage if the animator is running, and then continue animator with new timing in 'ended' stage.
    /// If animator is not running in 'began' stage, when pan is ended, create a new aniamtor with new timing and add animation to run.
    /// There is a bug in this way like use stopAnimation(): if you drag panelView with pan gesture first, reverse animation before it finish, the panelView
    /// will go back to where your finger leave the screen, and it's not place we expect. 
    /// How to fix it? look fixDefect_PauseAndContinueAnimation(withPanGesture panGesture: UIPanGestureRecognizer)
    func PauseAndContinueAnimation(withPanGesture panGesture: UIPanGestureRecognizer){
        switch panGesture.state {
        case .began:
            if animator.isRunning{
                print("Pan: pauseAnimation")
                animator.pauseAnimation()
                // Why cancel reverse here? When pan is ended, need combine velocity direction and panel opened/closed to judge the animation's derection,
                // if isReversed is true, count it in, it's more complex. Cancel it here don't affect later judgement.
                if animator.isReversed{
                    animator.isReversed = false
                }
            }
        case .changed:
            movePanelWithPan(gesture: panGesture)
        case .ended, .cancelled:
            // With pan gesture, we can get a new timing to continue to move smoothly, animation continue direction and panelView's destination position.
            let (timing, isUp, targetY) = relayTiming_direction_targetY(withPangesture: panGesture)
            
            switch animator.state {
            // If the animator is not active, it means it has no animation block to run. Because even if animator is paused, it's still active.
            // Here we need to continue with new timing, but there's no way to modify timing directly. Yeah, we have continueAnimation:,
            // but this method must called after startAnimation(), otherwise animation doesn't run. So I create a new animator with new timing.
            case .inactive, .stopped:
                print("Pan: No animation is running, renew Animation.")
                animator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
                animator.addAnimations({
                    self.panelView.center.y = targetY
                })
                animator.addCompletion({[unowned self] position in
                    if position == .end{
                        self.panelOpened = isUp ? false : true
                    }
                    print("Pan: completion at \(position.description), panelOpened: \(self.panelOpened)")
                })
                animator.startAnimation()
                
            // There is an animation block waitting for continue if animator's state is active
            case .active:
                let isSameDirection: Bool = (panelOpened && isUp) || (!panelOpened && !isUp)
                animator.isReversed = isSameDirection ? false : true
                print("Pan: continue original animation.")
                
                // This method temporarily modify the timing and use new duration to run animation from current state to pre-set state.
                // This method won't change original timing to new timing, but it may changes original 'duration' by some rules, it's very weird design.
                // In this scene, we need the same configuration to run animation in tap gesture, luckily, it won't change original duration if 'durationFactor' is 0.
                // How much is animation's running time after call this method? runing time = durationFactor * original duration, if durationFactor is 0,
                // it will be original 'duration' time. After call this method, if you need original configure to run animation, reassign a new animator.
                animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
            }
        default:break
        }

    }
    
    /// Stop the animator in current position if animator is running, and then use a new animator with a new timing to continue to move after pan is ended.
    /// Before the new animator, which is created in pan gesture's ended stage, finish its animation, if reverse it with tap panelView, it will back to position
    /// where finger leave the screen, also is the place animation start, and it's must not be where we expect. Actually in real scene, the bug is hard to trigger,
    /// because a normal animation's duration is 0.3~0.5 second, it is too fast to user tap to reverse it. How to fix it, use pauseAnimation() correctly.
    /// Look fixDefect_PauseAndContinueAnimation(withPanGesture panGesture: UIPanGestureRecognizer).
    func StopAndRenewAnimation(withPanGesture panGesture: UIPanGestureRecognizer){
        switch panGesture.state {
        case .began:
            // Stop animation and stay current position if animator is runing its animation.
            if animator.isRunning{
                print("Pan: stop animtion")
                //This make animator to inactive, and panelView stop at its current position.
                animator.stopAnimation(true)
                
                /* Or, like this, this make animator's state to be stoped
                animator.stopAnimation(false)
                //Only call this method after stopAnimation(false). if animator have no animation to run, this method will raise exeception.
                animator.finishAnimation(at: .current)
                 */
            }
        case .changed:
            movePanelWithPan(gesture: panGesture)
        case .ended, .cancelled:
            // With pan gesture, we can get a new timing to continue to move smoothly, animation continue direction and panelView's destination position.
            let (timing, isUp, targetY) = relayTiming_direction_targetY(withPangesture: panGesture)
            animator = UIViewPropertyAnimator(duration: relayDuration, timingParameters: timing)
            animator.addAnimations({[unowned self] in
                self.panelView.center.y = targetY
            })
            animator.addCompletion({[unowned self] position in
                if position == .end{
                    self.panelOpened = isUp ? false : true
                }
            })
            animator.startAnimation()
            print("Pan: continue stoped animation with new timing")
        default:break
        }
    }
    
    
    /// Right way to interactive with animation: start animation from pan gesture's began stage, which make animation completed.
    func fixDefect_PauseAndContinueAnimation(withPanGesture panGesture: UIPanGestureRecognizer){
        switch panGesture.state {
        // Establish a babis from here, in ended stage, just continue animation.
        case .began:
            switch animator.state {
            // If animator is inactive, it means no animation is running and panelView must be at bottom or top position.
            // Create a new animator, add animation, and pasue it, when pan gesture is ended, continue it.
            case .inactive:
                animator = interactiveAnimator()
                animator.startAnimation() //must start animation, otherwise continueAnimation: doesn't work.
                animator.pauseAnimation()
                print("Pan: renew and pause animation")
            // An animator is running, pause it.
            case .active:
                animator.pauseAnimation() //Note: after pause, animator's state is still active
                if animator.isReversed{
                    animator.isReversed = false
                }
                print("Pan: pause running animation")
            case .stopped:break
            }
        case .changed:
            movePanelWithPan(gesture: panGesture)
        case .ended, .cancelled:
            // With pan gesture, we can get a new timing to continue to move smoothly, animation continue direction and panelView's destination position.
            let (timing, isUp, _) = relayTiming_direction_targetY(withPangesture: panGesture)
            let isSameDirection: Bool = (panelOpened && isUp) || (!panelOpened && !isUp)
            animator.isReversed = isSameDirection ? false : true
            // If durationFactor is not 0, it will change animator's 'duration'.
            animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
            print("Pan: continue animation with new timing")
        default:break
        }
    }

}
