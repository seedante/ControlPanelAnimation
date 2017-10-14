//
//  ViewController.swift
//  InteractiveAnimation
//
//  Created by seedante on 16/6/14.
//  Copyright © 2016年 seedante. All rights reserved.
//

import UIKit


/**
 Continue the topic "Interactive Animations" in https://www.objc.io/issues/12-animations/interactive-animations/ ,
 use UIView Animation/Core Animation to implement control panel open/close animation, which is interactive, interruptible, smooth.
 */

class ViewController: UIViewController {
    var pan = UIPanGestureRecognizer()
    var tap = UITapGestureRecognizer()
    var panelView = UIView()
    var panelOpened = true
    
    ///0.5s is too short for interaction, you could set it longer for test.
    let duration: TimeInterval = 0.5
    let relayDuration: TimeInterval = 0.3
    let diff: CGFloat = 150
    var USE_COREANIMATION = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        panelView.frame = view.bounds
        panelView.center.y = view.center.y * (3 - 0.5)
        panelView.backgroundColor = UIColor.gray
        panelView.layer.cornerRadius = 5
        view.addSubview(panelView)
        
        pan.addTarget(self, action: #selector(ViewController.handlePan(_:)))
        panelView.addGestureRecognizer(pan)
        tap.addTarget(self, action: #selector(ViewController.handleTap(_:)))
        panelView.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stopMoveAnimation(){
        let currentPosition = (panelView.layer.presentation() as! CALayer).position
        panelView.layer.removeAllAnimations()
        panelView.layer.position = currentPosition
    }

    func handlePan(_ panGesture: UIPanGestureRecognizer){
        switch panGesture.state {
        case .began:
            stopMoveAnimation()
        case .changed:
            let point = panGesture.translation(in: view)
            panelView.center = CGPoint(x: panelView.center.x, y: panelView.center.y + point.y)
            panGesture.setTranslation(CGPoint.zero, in: view)
        case .ended, .cancelled:
            let gestureVelocity = panGesture.velocity(in: view)
            let isUp = gestureVelocity.y < 0 ? true : false
            let targetY = isUp ? view.center.y + diff : view.center.y * 2.5
            let velocity = abs(gestureVelocity.y) / abs(panelView.center.y - targetY)
            
            // Relay leave speed. You should provide .AllowUserInteraction option otherwise your touch can't interact with moving view.
            UIView.animate(withDuration: relayDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: velocity, options: .allowUserInteraction, animations: {
                self.panelView.center.y = targetY
                }, completion: nil)
            self.panelOpened = isUp ? false : true
        default:break
        }
    }
    
    func handleTap(_ geture: UITapGestureRecognizer){
        switch geture.state {
        case .ended, .cancelled:
            let targetY = panelOpened ? view.center.y + diff : view.center.y * 2.5

            if USE_COREANIMATION{
                let openOrcloseAni = CABasicAnimation(keyPath: "position.y")
                openOrcloseAni.isAdditive = true
                openOrcloseAni.duration = duration
                openOrcloseAni.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
                
                // When Core Animation is additive, scope of animation atteched to presentationLayer is: modelLayer + fromValue ~ modelLayer + toValue.
                openOrcloseAni.fromValue = panelView.center.y - targetY
                openOrcloseAni.toValue = 0
                if panelOpened{
                    panelView.layer.add(openOrcloseAni, forKey: "close")
                }else{
                    panelView.layer.add(openOrcloseAni, forKey: "open")
                }
                panelView.center.y = targetY
            }else{
                // UIView Animation is additive since iOS 8. You should provide AllowUserInteraction option otherwise your touch can't interact with moving view.
                UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 2, options: .allowUserInteraction, animations: {
                    self.panelView.center.y = targetY
                    }, completion: nil)
            }
            panelOpened = !panelOpened
        default:break
        }
    }
}

