//
//  FlickViewController.swift
//  Example
//
//  Created by Jake Lawson on 04/06/2016.
//  Copyright © 2016 Jake Lawson. All rights reserved.
//

import UIKit

/// Options used to customize the appearance and interaction.
public enum FlickViewOptions {
    case BackgroundColor(UIColor)
    case FlickThreshold(CGFloat)
    case FlickVelocityMultiplier(CGFloat)
    case SnapDamping(CGFloat)
    case Animation(AnimationType)
}

/// Different animation styles for presenting the flickable view.
public enum AnimationType: String {
    case None
    case Scale
}

/// Presents a UIView which can dismissed by flicking it off the screen.
@IBDesignable
public class FlickToDismissViewController: UIViewController {

    // MARK:- Properties
    
    /// Flickable UIView.
    @IBOutlet private var flickView: UIView!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    /// Array of FlickViewOptions.
    private var options: [FlickViewOptions]?
    /// Indicates how fast the view must be moving in order to have the view continue moving.
    @IBInspectable var flickThreshold: CGFloat = 1000
    /// The amount of oscillation of the flickView during the conclusion of a snap.
    @IBInspectable var snapDamping: CGFloat = 0.5
    /// Affects how fast or slow the toss should be.
    @IBInspectable var flickVelocityMultiplier: CGFloat = 0.2
    /// Animation presentation type. See AnimationType for all possible values.
    @IBInspectable var animationType: String = "None"
    /// Center of the flickable view before the pan starts
    private var originalCenter: CGPoint!
    // UIKit Dynamics
    private var animator: UIDynamicAnimator!
    private var attachmentBehavior: UIAttachmentBehavior!
    private var snapBehaviour: UISnapBehavior!
    private var pushBehaviour: UIPushBehavior!
    
    // MARK:- Life Cycle
    
    init(flickView: UIView, options: [FlickViewOptions]?) {
        super.init(nibName: nil, bundle: nil)
        self.flickView = flickView
        self.options = options
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Perform animation when view will appear
        switch AnimationType.init(rawValue: animationType) ?? .None {
        case .Scale:
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5.0, options: .CurveEaseInOut, animations: ({
                self.flickView.transform = CGAffineTransformIdentity
                self.flickView.alpha = 1.0
            }), completion: nil)
        default:
            break
        }
    }
    
    // MARK:- Setup

    private func setup() {
        // Setup pan gesture
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(FlickToDismissViewController.handleAttachmentGesture(_:)))
        // Setup animator
        animator = UIDynamicAnimator(referenceView: view)
        // Apply options
        if let options = options {
            for option in options {
                switch option {
                case .BackgroundColor(let color):
                    view.backgroundColor = color
                case .FlickThreshold(let threshold):
                    flickThreshold = threshold
                case .FlickVelocityMultiplier(let multiplier):
                    flickVelocityMultiplier = multiplier
                case .SnapDamping(let damping):
                    snapDamping = damping
                case .Animation(let animation):
                    animationType = animation.rawValue
                }
            }
        }
        // Setup animation
        switch AnimationType.init(rawValue: animationType) ?? .None {
        case .Scale:
            flickView.transform = CGAffineTransformMakeScale(0.8, 0.8)
            flickView.alpha = 0.0
        default:
            break
        }
        flickView.addGestureRecognizer(panGestureRecognizer)
        view.addSubview(flickView)
    }
    
    // MARK:- Pan Gesture
    
    @objc private func handleAttachmentGesture(panGesture: UIPanGestureRecognizer) {
        let location = panGesture.locationInView(view)
        let boxLocation = panGesture.locationInView(flickView)
        switch panGesture.state {
        case .Began:
            animator.removeAllBehaviors()
            let centerOffset = UIOffset(horizontal: boxLocation.x-flickView.bounds.midX, vertical: boxLocation.y-flickView.bounds.midY)
            attachmentBehavior = UIAttachmentBehavior(item: flickView, offsetFromCenter: centerOffset, attachedToAnchor: location)
            animator.addBehavior(attachmentBehavior)
            originalCenter = flickView.center
        case .Ended:
            animator.removeAllBehaviors()
            let velocity = panGesture.velocityInView(view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            guard magnitude > flickThreshold else {
                snapBehaviour = UISnapBehavior(item: flickView, snapToPoint: originalCenter)
                snapBehaviour.damping = snapDamping
                animator.addBehavior(snapBehaviour)
                return
            }
            let centerOffset = UIOffset(horizontal: boxLocation.x-flickView.bounds.midX, vertical: boxLocation.y-flickView.bounds.midY)
            pushBehaviour = UIPushBehavior(items: [flickView], mode: .Instantaneous)
            pushBehaviour.pushDirection = CGVector(dx: velocity.x, dy: velocity.y)
            pushBehaviour.setTargetOffsetFromCenter(centerOffset, forItem: flickView)
            pushBehaviour.magnitude = magnitude * flickVelocityMultiplier
            animator.addBehavior(pushBehaviour)
            dismissViewControllerAnimated(true, completion: nil)
        default:
            attachmentBehavior.anchorPoint = location
        }
    }
    
    // MARK:- Convinience Methods
    
    /// Connect this to a button to dismiss the view controller.
    @IBAction func dismissViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK:- Rotation
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // Remove behaviors on rotation in order to satisfy constraints
        animator.removeAllBehaviors()
    }
    
}