//
//  ShapeView.swift
//  Circle App
//
//  Created by Andrei Oltean on 3/18/16.
//  Copyright © 2016 Andrei Oltean. All rights reserved.
//

import UIKit

public class ShapeView: UIView {
    private let size: CGFloat = 100.0
    private let lineWidth: CGFloat = 3
    private var fillColor: UIColor!
    private var path: UIBezierPath!
    private var timer: NSTimer = NSTimer()
    public init(origin: CGPoint) {
        super.init(frame: CGRectMake(0.0, 0.0, size, size))
        self.fillColor = randomColor()
        self.path = randomPath()
        self.center = origin
        self.backgroundColor = UIColor.clearColor()
        initGestureRecognizers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initGestureRecognizers() {
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan)))
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(didPinch)))
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPress)))
        addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(didRotate)))
    }
    
    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if self.path.containsPoint(point) {
            return true
        }
        else {
            return false
        }
    }
    
    private func fixDepthOrder() {
        self.superview!.bringSubviewToFront(self)
        for view in self.superview!.subviews {
            if view is UIButton {
                self.superview!.bringSubviewToFront(view)
            }
        }
    }
    
    public func didPan(panGR: UIPanGestureRecognizer) {
        fixDepthOrder()
        
        var translation = panGR.translationInView(self)
        
        translation = CGPointApplyAffineTransform(translation, self.transform)
        
        self.center.x += translation.x
        self.center.y += translation.y
        
        panGR.setTranslation(CGPointZero, inView: self)
        
        var contentRect: CGRect = CGRectZero;
        var leftOrTop = false
        let scrollView: UIScrollView = self.superview! as! UIScrollView
        for view in scrollView.subviews {
            contentRect = CGRectUnion(contentRect, view.frame);
            if view.frame.origin.x < scrollView.frame.origin.x || view.frame.origin.y < scrollView.frame.origin.y {
                leftOrTop = true
            }
        }
        let initial = scrollView.contentSize
        scrollView.contentSize = contentRect.size
        if leftOrTop {
            for view in scrollView.subviews {
                view.center.x += contentRect.width - initial.width
                view.center.y += contentRect.height - initial.height
            }
            scrollView.bounds.origin.x += contentRect.width - initial.width
            scrollView.bounds.origin.y += contentRect.height - initial.height
        }

    }
    
    public func didPinch(pinchGR: UIPinchGestureRecognizer) {
        fixDepthOrder()
        
        scaleUpPath(pinchGR.scale)
        
        pinchGR.scale = 1.0
        
        var contentRect: CGRect = CGRectZero;
        var leftOrTop = false
        let scrollView: UIScrollView = self.superview! as! UIScrollView
        for view in scrollView.subviews {
            contentRect = CGRectUnion(contentRect, view.frame);
            if view.frame.origin.x < scrollView.frame.origin.x || view.frame.origin.y < scrollView.frame.origin.y {
                leftOrTop = true
            }
        }
        let initial = scrollView.contentSize
        scrollView.contentSize = contentRect.size
        if leftOrTop {
            for view in scrollView.subviews {
                view.center.x += contentRect.width - initial.width
                view.center.y += contentRect.height - initial.height
            }
            scrollView.bounds.origin.x += contentRect.width - initial.width
            scrollView.bounds.origin.y += contentRect.height - initial.height
        }
    }
    
    public func grow() {
        scaleUpPath()
        
        var contentRect: CGRect = CGRectZero;
        var leftOrTop = false
        let scrollView: UIScrollView = self.superview! as! UIScrollView
        for view in scrollView.subviews {
            contentRect = CGRectUnion(contentRect, view.frame);
            if view.frame.origin.x < scrollView.frame.origin.x || view.frame.origin.y < scrollView.frame.origin.y {
                leftOrTop = true
            }
        }
        let initial = scrollView.contentSize
        scrollView.contentSize = contentRect.size
        if leftOrTop {
            for view in scrollView.subviews {
                view.center.x += contentRect.width - initial.width
                view.center.y += contentRect.height - initial.height
            }
            scrollView.bounds.origin.x += contentRect.width - initial.width
            scrollView.bounds.origin.y += contentRect.height - initial.height
        }
    }
    
    public func didLongPress(longPressGR: UILongPressGestureRecognizer) {
        fixDepthOrder()
        
        if longPressGR.state == UIGestureRecognizerState.Began {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: #selector(grow), userInfo: nil, repeats: true)
        }
        if longPressGR.state == UIGestureRecognizerState.Ended {
            self.timer.invalidate()
        }
    }
    
    public func didRotate(rotationGR: UIRotationGestureRecognizer) {
        fixDepthOrder()
        
        let rotation = rotationGR.rotation
        
        self.transform = CGAffineTransformRotate(self.transform, rotation)
        
        rotationGR.rotation = 0.0
    }
    
    public override func drawRect(rect: CGRect) {
        self.fillColor.setFill()
        self.path.fill()
        
        self.path.lineWidth = self.lineWidth
        UIColor.blackColor().setStroke()
        self.path.stroke()
    }
    
    func scaleUpPath(scale: CGFloat = (105.0/100.0)) {
        let transf = CGAffineTransformScale(self.transform, scale, scale)
        let aux = self.layer.position
        self.frame = CGRectApplyAffineTransform(self.frame, transf)
        self.path.applyTransform(transf)
        self.layer.position = aux
        self.setNeedsDisplay()
    }
    
    private func randomColor() -> UIColor {
        let hue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        return UIColor(hue: hue, saturation: 0.8, brightness: 1.0, alpha: 0.8)
    }
    
    private func trianglePathInRect(rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.moveToPoint(CGPointMake(rect.width / 2.0, rect.origin.y))
        path.addLineToPoint(CGPointMake(rect.width, rect.height))
        path.addLineToPoint(CGPointMake(rect.origin.x, rect.height))
        path.closePath()
        
        return path
    }
    
    func starPathInRect(rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        
        let starExtrusion:CGFloat = rect.width / 4.0
        
        let center = CGPointMake(rect.width / 2.0, rect.height / 2.0)
        
        let pointsOnStar = 5 + arc4random() % 10
        
        var angle:CGFloat = -CGFloat(M_PI / 2.0)
        let angleIncrement = CGFloat(M_PI * 2.0 / Double(pointsOnStar))
        let radius = rect.width / 2.0
        
        var firstPoint = true
        
        for _ in 1...pointsOnStar {
            let point = CGPointMake(radius * cos(angle) + center.x, radius * sin(angle) + center.y)
            let nextPoint = CGPointMake(radius * cos(angle + angleIncrement) + center.x, radius * sin(angle + angleIncrement) + center.y)
            let midPoint = CGPointMake(starExtrusion * cos(angle + angleIncrement / 2.0) + center.x, starExtrusion * sin(angle + angleIncrement / 2.0) + center.y)
            if firstPoint {
                firstPoint = false
                path.moveToPoint(point)
            }
            
            path.addLineToPoint(midPoint)
            path.addLineToPoint(nextPoint)
            
            angle += angleIncrement
        }
        
        path.closePath()
        
        return path
    }
    
    private func randomPath() -> UIBezierPath {
        let insetRect = CGRectInset(self.bounds, lineWidth, lineWidth)
        let shapeType = arc4random() % 4
        
        //square
        if shapeType == 0 {
            return UIBezierPath(roundedRect: insetRect, cornerRadius: 10.0)
        }
        
        //circle
        if shapeType == 1 {
            return UIBezierPath(ovalInRect: insetRect)
        }
        
        //triangle
        if shapeType == 1 {
            return trianglePathInRect(insetRect)
        }
        
        return starPathInRect(insetRect)
    }
}
