//
//  ViewControllerTwo.swift
//  iOS10InteractiveAnimation
//
//  Created by seedante on 16/6/24.
//  Copyright © 2016年 seedante. All rights reserved.
//

import UIKit

/**
 Continue the topic "Interactive Animations" in https://www.objc.io/issues/12-animations/interactive-animations/ , use UIViewPropertyAnimator
 introduced in iOS 10 to implement control pane open/close interactive animation with the style of UIView Animation. UIViewPropertyAnimator is
 additive except that inited with UISpringTimingParameters and initialVelocity isn't (0,0).
 */

class ViewControllerTwo: UIViewController {

    var pan = UIPanGestureRecognizer()
    var tap = UITapGestureRecognizer()
    var paneView = UIView()
    var paneOpened = true
    
    let duration: TimeInterval = 0.5 //0.5s is too short for test mix tap and pan
    let relayDuration: TimeInterval = 0.3
    let dampingRatio: CGFloat = 0.7
    let diff: CGFloat = 150

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paneView.frame = view.bounds
        paneView.center.y = view.center.y * (3 - 0.5)
        paneView.backgroundColor = UIColor.gray()
        paneView.layer.cornerRadius = 5
        view.addSubview(paneView)
        
        pan.addTarget(self, action: #selector(ViewControllerOne.handlePan(gesture:)))
        paneView.addGestureRecognizer(pan)
        tap.addTarget(self, action: #selector(ViewControllerOne.handleTap(gesture:)))
        paneView.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Handle Gesture
    func handlePan(gesture: UIPanGestureRecognizer){
        switch gesture.state {
        case .began:
            stopMoveAnimation(of: [paneView])
        case .changed:
            let point = gesture.translation(in: view)
            paneView.center.y += point.y
            gesture.setTranslation(CGPoint(x: 0, y: 0), in: view)
        case .ended, .cancelled:
            let gestureVelocity = gesture.velocity(in: view)
            let isUp = gestureVelocity.y < 0 ? true : false
            paneOpened = isUp ? false : true
            let targetY = isUp ? view.center.y + diff : view.center.y * 2.5
            let velocityY = abs(gestureVelocity.y) / abs(paneView.center.y - targetY)
            let timeing = UISpringTimingParameters(dampingRatio: dampingRatio, initialVelocity: CGVector(dx: 0, dy: velocityY))
            
            // Thought UIViewPropertyAnimator is not additive when initialVelocity is not (0, 0), it can works with other UIViewPropertyAnimator is additive, the result is still additive.
            let relayAnimator = UIViewPropertyAnimator(duration: relayDuration, timingParameters: timeing)
            relayAnimator.addAnimations({[unowned self] in
                self.paneView.center.y = targetY
                })
            relayAnimator.startAnimation()
        default:break
        }
    }
        
    func stopMoveAnimation(of views:[UIView]){
        for anyView in views{
            let currentFrame = (anyView.layer.presentation()! as CALayer).frame
            // Remove animation of view in an UIViewPropertyAnimator's animation block, even not all views in the block, will break UIViewPropertyAnimator's state to be inactive.
            anyView.layer.removeAllAnimations()
            anyView.layer.frame = currentFrame
        }
    }
    
    func handleTap(gesture: UITapGestureRecognizer){
        switch gesture.state {
        case .ended, .cancelled:
            let targetY = paneOpened ? view.center.y + diff : view.center.y * 2.5
            paneOpened = !paneOpened
            
            // This method is also additive, use it like UIView Animation API, just it has no spring animation interface, So this method can't start animation with specifed speed.
            // And the effect is not completely same with the animation in gif.
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {[unowned self] in
                self.paneView.center.y = targetY
                }, completion: nil)
        default:break
        }
    }


}
