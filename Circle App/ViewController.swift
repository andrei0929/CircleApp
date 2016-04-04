//
//  ViewController.swift
//  Circle App
//
//  Created by Andrei Oltean on 3/18/16.
//  Copyright © 2016 Andrei Oltean. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var clearShapesButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        scrollView.addSubview(clearShapesButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func clearAllShapes(sender: UIButton) {
        for view in scrollView.subviews {
            if view is ShapeView {
                view.removeFromSuperview()
            }
        }
        scrollView.contentSize = scrollView.frame.size
    }
    
    func didTap(tapGR: UITapGestureRecognizer) {
        let tapPoint = tapGR.locationInView(scrollView)
        let shapeView = ShapeView(origin: tapPoint)
        scrollView.addSubview(shapeView)
        scrollView.bringSubviewToFront(clearShapesButton)
        var contentRect: CGRect = CGRectZero;
        var leftOrTop = false
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
    
}

