//
//  LBBeaconRangingView.swift
//  LibraryBox
//
//  Created by David on 23/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import UIKit
import CoreLocation

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

let beacon1 = testBeacon(newProximity: 1,newAccuracy: 0.3)
let beacon2 = testBeacon(newProximity: 2,newAccuracy: 1.5)
let beacon3 = testBeacon(newProximity: 2,newAccuracy: 4.8)
let beacon4 = testBeacon(newProximity: 3,newAccuracy: 30.456666)
let beacon5 = testBeacon(newProximity: 3,newAccuracy: 55.246356723)
let beacon6 = testBeacon(newProximity: 0,newAccuracy: -2)

var beacons: [testBeacon] = [beacon1, beacon2, beacon3, beacon4, beacon5, beacon6]
var sortedBeacons = beacons.sort({ $0.accuracy < $1.accuracy})

@IBDesignable
class LBBeaconRangingView: UIView
{
    //labels
    @IBInspectable var endColor: UIColor = UIColor.darkGrayColor()
    @IBInspectable var startColor: UIColor = UIColor.lightGrayColor()
    @IBInspectable var shadow:UIColor = UIColor.blackColor().colorWithAlphaComponent(0.80)
    @IBInspectable var immediateColor: UIColor = UIColor.redColor()
    @IBInspectable var nearColor: UIColor = UIColor.blueColor()
    @IBInspectable var farColor: UIColor = UIColor.lightGrayColor()
    @IBInspectable var defaultColor: UIColor = UIColor.clearColor()
    var yOffset: CGFloat = 80.0
    var beaconSigmaDistances:[Double] = []
    
    
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
        let startPGradient = CGPoint.zero
        let endPGradient = CGPoint(x:0, y:self.bounds.height)
        let startPoint: CGPoint = CGPointMake(rect.size.width - 50, CGRectGetMinY(rect)+95)
        let endPoint: CGPoint = CGPointMake(rect.size.width - 50, CGRectGetMaxY(rect)-yOffset)
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.CGColor, endColor.CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace,
                                                  colors,
                                                  colorLocations)
        CGContextDrawLinearGradient(context,
                                    gradient,
                                    startPGradient,
                                    endPGradient,
                                    CGGradientDrawingOptions.DrawsAfterEndLocation)
        CGContextSaveGState(context)
        let flipVertical:CGAffineTransform = CGAffineTransformMake(1,0,0,-1,0,rect.size.height)
        CGContextConcatCTM(context, flipVertical)
        let shadowOffset = CGSizeMake(2.0, 2.0)
        let shadowBlurRadius: CGFloat = 5
        CGContextSetShadowWithColor(context,
                                    shadowOffset,
                                    shadowBlurRadius,
                                    shadow.CGColor)
        CGContextBeginTransparencyLayer(context, nil)
        let fiveMeterMark: UIBezierPath = UIBezierPath()
        let fiveMeterMarkerY: CGFloat = self.convertToLogScale(5.0, screenY0:startPoint.y, screenY1:endPoint.y, dataY0:1.0, dataY1:80.0)
        fiveMeterMark.moveToPoint(CGPointMake(rect.size.width - 50, fiveMeterMarkerY))
        fiveMeterMark.addLineToPoint(CGPointMake(rect.size.width - 40, fiveMeterMarkerY))
        fiveMeterMark.lineWidth = 3.0
        fiveMeterMark.lineCapStyle = CGLineCap.Round
        UIColor.darkGrayColor().setStroke()
        fiveMeterMark.stroke()
        let twentyMeterMark: UIBezierPath = UIBezierPath()
        let twentyMeterMarkerY: CGFloat = self.convertToLogScale(20.0, screenY0:startPoint.y, screenY1:endPoint.y, dataY0:1.0, dataY1:80.0)
        twentyMeterMark.moveToPoint(CGPointMake(rect.size.width - 50, twentyMeterMarkerY))
        twentyMeterMark.addLineToPoint(CGPointMake(rect.size.width - 40, twentyMeterMarkerY))
        twentyMeterMark.lineWidth = 2.4
        twentyMeterMark.lineCapStyle = CGLineCap.Round
        UIColor.darkGrayColor().setStroke()
        twentyMeterMark.stroke()
        let fiftyMeterMark: UIBezierPath = UIBezierPath()
        let fiftyMeterMarkerY: CGFloat = self.convertToLogScale(50.0, screenY0:startPoint.y, screenY1:endPoint.y, dataY0:1.0, dataY1:80.0)
        fiftyMeterMark.moveToPoint(CGPointMake(rect.size.width - 50, fiftyMeterMarkerY))
        fiftyMeterMark.addLineToPoint(CGPointMake(rect.size.width - 40, fiftyMeterMarkerY))
        fiftyMeterMark.lineWidth = 1.5
        fiftyMeterMark.lineCapStyle = CGLineCap.Round
        UIColor.darkGrayColor().setStroke()
        fiftyMeterMark.stroke()
        let linePath: UIBezierPath = UIBezierPath()
        linePath.moveToPoint(CGPointMake(rect.size.width - 50, CGRectGetMinY(rect)+75))
        linePath.addLineToPoint(endPoint)
        linePath.lineWidth = 6.0
        linePath.lineCapStyle = CGLineCap.Round
        UIColor.whiteColor().setStroke()
        linePath.stroke()
        let aCenterPoint = CGPointMake(rect.size.width - 50, CGRectGetMinY(rect)+50)
        var aStartAngle: CGFloat = CGFloat(Float(2 * M_PI))
        var anEndAngle: CGFloat = 0.0
        let aStrokeWidth: CGFloat = 3.0
        let aRadius = CGFloat((50.0 - CGFloat(aStrokeWidth)) / 2)
        UIColor.whiteColor().setStroke()
        UIColor.whiteColor().setFill()
        aStartAngle = aStartAngle - CGFloat(Float(M_PI_2))
        anEndAngle = anEndAngle - CGFloat(Float(M_PI_2))
        let lowerCirclePath: UIBezierPath = UIBezierPath()
        lowerCirclePath.addArcWithCenter(aCenterPoint, radius: aRadius, startAngle: aStartAngle, endAngle: anEndAngle, clockwise: true)
        lowerCirclePath.lineWidth=aStrokeWidth
        lowerCirclePath.fill()
        lowerCirclePath.stroke()
        //REDO FOR SIGMA DISTANCES!!
        for aBeacon in sortedBeacons
        {
            if(aBeacon.accuracy >= 0.0)
            {
                print(aBeacon.accuracy)
                let beaconY: CGFloat
                if(aBeacon.accuracy < 1.0)
                    {
                    beaconY = self.convertToLogScale(1.0, screenY0:startPoint.y, screenY1:endPoint.y, dataY0:1.0, dataY1:80.0)
                }else
                    {
                    beaconY = self.convertToLogScale(aBeacon.accuracy, screenY0:startPoint.y, screenY1:endPoint.y, dataY0:1.0, dataY1:80.0)
                }
                print(beaconY)
                let centerPoint = CGPointMake(rect.size.width - 50, beaconY)
                var startAngle: CGFloat = CGFloat(Float(2 * M_PI))
                var endAngle: CGFloat = 0.0
                let strokeWidth: CGFloat = 3.0
                let radius = CGFloat((25.0 - CGFloat(strokeWidth)) / 2)
                UIColor.whiteColor().setStroke()
                print(aBeacon.proximity)
                switch aBeacon.proximity {
                case 0:
                    defaultColor.setFill()
                case 1:
                    immediateColor.setFill()
                case 2:
                    nearColor.setFill()
                case 3:
                    farColor.setFill()
                default:
                    defaultColor.setFill()
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
        CGContextRestoreGState(context)
    }
}
