import UIKit
import Foundation


class testBeacon
{
    var proximity: Int = 0
    var accuracy: Double = 0.0
    
    init(newProximity:Int, newAccuracy:Double)
    {
        self.proximity = newProximity
        self.accuracy = newAccuracy
    }
}


let beacon1 = testBeacon(newProximity: 1,newAccuracy: 3)
let beacon2 = testBeacon(newProximity: 1,newAccuracy: 8)
let beacon3 = testBeacon(newProximity: 1,newAccuracy: 14)
let beacon4 = testBeacon(newProximity: 2,newAccuracy: 30)
let beacon5 = testBeacon(newProximity: 2,newAccuracy: 55)
let beacon6 = testBeacon(newProximity: 0,newAccuracy: -2)

var beacons: [testBeacon] = [beacon1, beacon2, beacon3, beacon4, beacon5, beacon6]
let sortedBeacons = beacons.sort({ $0.accuracy < $1.accuracy})

class RangingView: UIView
{


    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let amountOfBeacons: CGFloat = CGFloat(sortedBeacons.count)
        //if max beacons > 20 cut => 20 beacons
        let startPoint: CGPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect)+25)
        let endPoint: CGPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect)-25)
        let distance: CGFloat = CGRectGetMaxY(rect)-50
        let distanceBetweenBeacons: CGFloat = distance/amountOfBeacons
        
        //UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        let shadow:UIColor = UIColor.blackColor().colorWithAlphaComponent(0.80)
        let shadowOffset = CGSizeMake(2.0, 2.0)
        let shadowBlurRadius: CGFloat = 5
        
        CGContextSetShadowWithColor(context,
                                    shadowOffset,
                                    shadowBlurRadius,
                                    shadow.CGColor)
        
        CGContextBeginTransparencyLayer(context, nil)
        
        for aBeacon in sortedBeacons
        {
            if(aBeacon.accuracy >= 0.0)
            {
             //var centerPoint = CGPointMake(CGRectGetMidX(rect), y1)
                var startAngle: Float = Float(2 * M_PI)
                var endAngle: Float = 0.0
                
                // Drawing code
                // Set the radius
                let strokeWidth = 1.0
                let radius = CGFloat((CGFloat(self.frame.size.width) - CGFloat(strokeWidth)) / 2)
                
                // Get the context
                
                // Set the stroke color
                CGContextSetStrokeColorWithColor(context, Colors.primaryColor().CGColor)
                
                // Set the line width
                CGContextSetLineWidth(context, CGFloat(strokeWidth))
                
                // Set the fill color (if you are filling the circle)
                CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
                
                // Rotate the angles so that the inputted angles are intuitive like the clock face: the top is 0 (or 2π), the right is π/2, the bottom is π and the left is 3π/2.
                // In essence, this appears like a unit circle rotated π/2 anti clockwise.
                startAngle = startAngle - Float(M_PI_2)
                endAngle = endAngle - Float(M_PI_2)
                
                // Draw the arc around the circle
                CGContextAddArc(context, center.x, center.y, CGFloat(radius), CGFloat(startAngle), CGFloat(endAngle), 0)
                
                // Draw the arc
                CGContextDrawPath(context, kCGPathStroke) // or kCGPathFillStroke to fill and stroke the circle
            }
            
            print(aBeacon.accuracy)
        }
        
        
        
        
        CGContextEndTransparencyLayer(context)
        
        //let image = UIGraphicsGetImageFromCurrentImageContext()
        //UIGraphicsEndImageContext()
    }
}


let myView = RangingView(frame:CGRectMake(0,0,150,600))
