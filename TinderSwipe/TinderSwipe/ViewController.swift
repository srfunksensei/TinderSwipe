//
//  ViewController.swift
//  TinderSwipe
//
//  Created by MB on 11/09/2020.
//  Copyright © 2020 MB. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum SwipeDirection {
        case left, right
    }
    
    var cardView: CardView!
    var animator = UIViewPropertyAnimator()
    var currentSwipeDirection: SwipeDirection = .right
    
    private var animationProgress: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        createNewCard()
    }
    
    private func createNewCard() {
        cardView = UINib(nibName: "CardView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? CardView
        
        cardView.frame = CGRect(x: 30, y: (view.frame.height - CGFloat(290)) / 2, width: view.frame.width - CGFloat(60), height: 290)
        
        view.addSubview(cardView)
        
        cardView.addGestureRecognizer(panRecognizer)
        cardView.alpha = 0
        cardView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        UIView.animate(withDuration: 0.6) {
            self.cardView.alpha = 1.0
            self.cardView.transform = CGAffineTransform.identity
        }
    }
    
    private lazy var panRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(cardViewPanned(recognizer:)))
        return recognizer
    }()
    
    @objc func cardViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            let translation = recognizer.translation(in: cardView)
            
            var swipeDirection: SwipeDirection = .left
            if translation.x > 0 {
                swipeDirection = .right
            }
            
            animateSwipe(direction: swipeDirection)
            animator.pauseAnimation()
            
            animationProgress = animator.fractionComplete
            
        case .changed:
            let translation = recognizer.translation(in: cardView)
            
            var fraction = translation.x / view.frame.width
            if currentSwipeDirection == .left {
                fraction *= -1
            }
            
            animator.fractionComplete = fraction + animationProgress
            
            if animator.fractionComplete == CGFloat(0) {
                if currentSwipeDirection == .left && translation.x > 0 {
                    refreshAnimator(direction: .right)
                } else if currentSwipeDirection == .right && translation.x < 0 {
                    refreshAnimator(direction: .left)
                }
            }
            
        case .ended:
            let velocity = recognizer.velocity(in: cardView)
            if velocity.x > 100 || animator.fractionComplete > 0.6 || velocity.x < -100 {
                animator.addCompletion { (position) in
                    self.cardView.removeFromSuperview()
                    self.createNewCard()
                }
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                break
            }
            
            animator.isReversed = true
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            
        default:
            ()
        }
    }
    
    private func animateSwipe(direction: SwipeDirection) {
        if animator.isRunning { return }
        
        currentSwipeDirection = direction
        
        animator = getUIViewPropertyAnimator(direction: direction)
        animator.startAnimation()
    }
    
    private func refreshAnimator(direction: SwipeDirection) {
        currentSwipeDirection = direction
        
        animator.stopAnimation(true)
        
        animator = getUIViewPropertyAnimator(direction: direction)
        animator.startAnimation()
        animator.pauseAnimation()
        
        animationProgress = animator.fractionComplete
    }
    
    private func getUIViewPropertyAnimator(direction: SwipeDirection) -> UIViewPropertyAnimator {
        switch direction {
        case .left:
            return getAnimatorLeft()
        case .right:
            return getAnimatorRight()
        }
    }
    
    private func getAnimatorRight() -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: 0.8, curve: .easeIn, animations: {
            
            let transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
            self.cardView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 8)).concatenating(transform)
        })
    }
    
    private func getAnimatorLeft() -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: 0.8, curve: .easeIn, animations: {
            
            let transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
            self.cardView.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi / 8)).concatenating(transform)
        })
    }
}
