//
//  RAFViewController.m
//  SnapBehaviorDemo
//
//  Created by Rafal Sroka on 29.03.14.
//
//  License CC0.
//  This is free and unencumbered software released into the public domain.
//
//  Anyone is free to copy, modify, publish, use, compile, sell, or
//  distribute this software, either in source code form or as a compiled
//  binary, for any purpose, commercial or non-commercial, and by any means.
//

#import "RAFViewController.h"

@interface RAFViewController ()

// View that will be dragged.
@property(nonatomic, weak) IBOutlet UIView *contentView;

// Reference to vertical and horizontal constraints that center the contentView.
@property(nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *contentViewCenterConstraints;

// Gesture recognizer that will detect dragging gestures in the content view.
@property(nonatomic, strong) UIPanGestureRecognizer *gestureRecognizer;

// Snap behavior responsible for the snap movement of the contentView after the
// dragging gesture has ended.
@property(nonatomic, strong) UISnapBehavior *snapBehavior;

// Dynamic animator that will take care of animating the snap movement.
@property(nonatomic, strong) UIDynamicAnimator *animator;

@end


@implementation RAFViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Tweak the look of the content view by adding some shadows and rounded corners.
    _contentView.layer.cornerRadius = 10.0f;
    _contentView.layer.shadowColor = [[UIColor blackColor] CGColor];
    _contentView.layer.shadowRadius = 10.0f;
    _contentView.layer.shadowOpacity = 0.7f;
    _contentView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds
                                                               cornerRadius:_contentView.layer.cornerRadius].CGPath;
    // Place the view in the center.
    _contentView.center = self.view.center;
    
    // Create a animator that will handle the animations of the contentView
    // when snap behavior is applied to it.
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    // Create a snap behavior for the contentView.
    // The view will snap to the center of the view.
    _snapBehavior = [[UISnapBehavior alloc] initWithItem:_contentView
                                             snapToPoint:self.view.center];
    
    // Create a gesture recognizer for detecting drag gesture.
    _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(handlePan:)];
    // Add gesture recognizer to the contentView.
    [_contentView addGestureRecognizer:_gestureRecognizer];
}


- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        // Remove previously added snap behavior (if any).
        [_animator removeBehavior:_snapBehavior];
        
        // Remove constraints holding the view in the center of the screen.
        // They would interfere with changes the animator does to the view
        // when animating its frame during the snap movement.
        if (_contentViewCenterConstraints)
        {
            [self.view removeConstraints:_contentViewCenterConstraints];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        // Calculate new center of the view based on the gesture recognizer's
        // translation.
        CGPoint newCenter = _contentView.center;
        newCenter.x += [gestureRecognizer translationInView:self.view].x;
        newCenter.y += [gestureRecognizer translationInView:self.view].y;
        
        // Set the new center of the view.
        _contentView.center = newCenter;
       
        // Reset the translation of the recognizer.
        [gestureRecognizer setTranslation:CGPointZero inView:self.view];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        // Dragging has ended.
        // Add snap behavior to the animator to move the view to it's starting
        // position with a nice snap movement.
        [_animator addBehavior:_snapBehavior];
    }
}


@end