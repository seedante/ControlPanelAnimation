//
//  ViewControllerOne.swift
//  iOS10InteractiveAnimation
//
//  Created by seedante on 16/6/22.
//  Copyright © 2016年 seedante. All rights reserved.
//

import UIKit

/**
 Continue the topic "Interactive Animations" in https://www.objc.io/issues/12-animations/interactive-animations/ , use UIViewPropertyAnimator 
 introduced in iOS 10 to implement control pane open/close interactive animation with the style of UIView Animation. UIViewPropertyAnimator is 
 additive except that inited with UISpringTimingParameters and initialVelocity isn't (0,0).
 */

class ViewControllerOne: UIViewController {

    var pan = UIPanGestureRecognizer()
    var tap = UITapGestureRecognizer()
    var paneView = UIView()
    var paneOpened = true
    
    var animator: UIViewPropertyAnimator = UIViewPropertyAnimator()
    let duration: TimeInterval = 0.5
    let relayDuration: TimeInterval = 0.3
    let dampingRatio: CGFloat = 0.7
    let diff: CGFloat = 150

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        paneView.frame = view.bounds
        paneView.center.y = view.center.y * (3 - 0.5)
        paneView.backgroundColor = UIColor.gray()
        paneView.layer.cornerRadius = 5
        view.addSubview(paneView)
        
        pan.addTarget(self, action: #selector(ViewControllerOne.handlePan(gesture:)))
        paneView.addGestureRecognizer(pan)
        tap.addTarget(self, action: #selector(ViewControllerOne.handleTap(gesture:)))
        paneView.addGestureRecognizer(tap)
        
        let timeing = UISpringTimingParameters(dampingRatio: dampingRatio, initialVelocity: CGVector(dx: 0, dy: 1))
        animator = UIViewPropertyAnimator(duration: duration, timingParameters: timeing)
        // If isInterruptible == false, except startAnimation(), other methods and writeable property in Protocol UIViewAnimating can't use, otherwise it raise exception.
        // And isRunning will be false always, state won't be stoped, just inactive and active. In this situation, use UIViewPropertyAnimator likes UIView Animation.
        animator.isInterruptible = false
    }

    func handleTap(gesture: UITapGestureRecognizer){
        switch gesture.state {
        case .ended, .cancelled:
            let targetY = paneOpened ? view.center.y + diff : view.center.y * 2.5
            paneOpened = !paneOpened
            // when isInterruptible == false, UIViewPropertyAnimator is like UIView Animation.
            animator.addAnimations({ [unowned self] in
                self.paneView.center.y = targetY
                })
            if animator.state == .inactive{
                animator.startAnimation()
            }
        default:break
        }
    }
    
    
    //MARK: Handle Gesture
    func handlePan(gesture: UIPanGestureRecognizer){
        switch gesture.state {
        case .began:
            if animator.state == .active{
                let currentFrame = (paneView.layer.presentation()! as CALayer).frame
                // Remove animation of view in an UIViewPropertyAnimator's animation block, even not all views in the block, will break UIViewPropertyAnimator's state to be inactive.
                paneView.layer.removeAllAnimations()
                paneView.layer.frame = currentFrame
            }
        case .changed:
            let point = gesture.translation(in: view)
            paneView.center.y += point.y
            gesture.setTranslation(CGPoint(x: 0, y: 0), in: view)
        case .ended, .cancelled:
            paneOpened = !paneOpened
            let gestureVelocity = gesture.velocity(in: view)
            let isUp = gestureVelocity.y < 0 ? true : false
            let targetY = isUp ? view.center.y + diff : view.center.y * 2.5
            let velocityY = abs(gestureVelocity.y) / abs(paneView.center.y - targetY)
            let timeing = UISpringTimingParameters(dampingRatio: dampingRatio, initialVelocity: CGVector(dx: 0, dy: velocityY))
            
            //You could assign this new UIViewPropertyAnimator to 'animator', and in Tap gesture, you must reassign a new objct with original timing.
            let relayAnimator = UIViewPropertyAnimator(duration: relayDuration, timingParameters: timeing)
            relayAnimator.addAnimations({[unowned self] in
                self.paneView.center.y = targetY
                })
            relayAnimator.startAnimation()
        default:break
        }
    }
}
