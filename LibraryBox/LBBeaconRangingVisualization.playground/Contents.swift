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
    
    func convertToLogScale(data: Double, screenY0:CGFloat, screenY1:CGFloat, dataY0:Double, dataY1:CGFloat) ->CGFloat{
        
        return screenY0 + (log(CGFloat(data)) - log(CGFloat(dataY0))) / (log(CGFloat(dataY1)) - log(CGFloat(dataY0))) * (screenY1 - screenY0)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        //let amountOfBeacons: CGFloat = CGFloat(sortedBeacons.count)
        //if max beacons > 20 cut => 20 beacons
        let startPoint: CGPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect)+25)
        let endPoint: CGPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect)-25)
        //let distance: CGFloat = CGRectGetMaxY(rect)-50
        //let distanceBetweenBeacons: CGFloat = distance/amountOfBeacons
        
        //UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        let flipVertical:CGAffineTransform = CGAffineTransformMake(1,0,0,-1,0,rect.size.height)
        CGContextConcatCTM(context, flipVertical)
        
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
                print(aBeacon.accuracy)
                let beaconY: CGFloat = self.convertToLogScale(aBeacon.accuracy, screenY0:startPoint.y, screenY1:endPoint.y, dataY0:1.0, dataY1:80.0)
                print(beaconY)
                let centerPoint = CGPointMake(CGRectGetMidX(rect), beaconY)
                var startAngle: CGFloat = CGFloat(Float(2 * M_PI))
                var endAngle: CGFloat = 0.0
                let strokeWidth: CGFloat = 1.0
                let radius = CGFloat((CGFloat(rect.size.width/5) - CGFloat(strokeWidth)) / 2)
                
                UIColor.whiteColor().setStroke()
                
                print(aBeacon.proximity)
                switch aBeacon.proximity {
                case 0:
                    UIColor.clearColor().setFill()
                case 1:
                    UIColor.blueColor().setFill()
                case 2:
                    UIColor.lightGrayColor().setFill()
                default:
                    UIColor.clearColor().setFill()
                }
                startAngle = startAngle - CGFloat(Float(M_PI_2))
                endAngle = endAngle - CGFloat(Float(M_PI_2))
                
                let circlePath: UIBezierPath = UIBezierPath()
                circlePath.addArcWithCenter(centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                circlePath.lineWidth=strokeWidth
                circlePath.fill()
                circlePath.stroke()
            }
            
            
        }
        CGContextEndTransparencyLayer(context)
        
        
        
        
        
        //let image = UIGraphicsGetImageFromCurrentImageContext()
        //UIGraphicsEndImageContext()
    }
}


let myView = RangingView(frame:CGRectMake(0,0,150,600))
