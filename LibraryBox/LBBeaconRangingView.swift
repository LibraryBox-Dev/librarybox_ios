//
//  LBBeaconRangingView.swift
//  LibraryBox
//
//  Created by David on 23/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import UIKit
import CoreLocation

///The beacon ranging view class, designable from the interface builder
@IBDesignable
class LBBeaconRangingView: UIView
{
    
    //Variables that can be changed in the interface builder
    @IBInspectable var endColor: UIColor = UIColor.darkGrayColor()
    @IBInspectable var startColor: UIColor = UIColor.lightGrayColor()
    @IBInspectable var shadow:UIColor = UIColor.blackColor().colorWithAlphaComponent(0.80)
    @IBInspectable var immediateColor: UIColor = UIColor.redColor()
    @IBInspectable var nearColor: UIColor = UIColor.redColor()
    @IBInspectable var farColor: UIColor = UIColor.orangeColor()
    @IBInspectable var defaultColor: UIColor = UIColor.whiteColor()
    
    //To set the horizontal center of the beacon ranging scale
    var yOffset: CGFloat = 80.0
    
    //Array of approximate distances of close ibeacons
    var beaconSigmaDistances:[Double] = [Double](count: 20, repeatedValue: 0.0)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    /**
     
     Returns a float value from a double value converted from a linear scale to a logarithmic scale.
     
     :returns: A float value converted from a a linear to a logarithmic scale
     */
    func convertToLogScale(data: Double, screenY0:CGFloat, screenY1:CGFloat, dataY0:Double, dataY1:CGFloat) ->CGFloat{
        
        return screenY0 + (log(CGFloat(data)) - log(CGFloat(dataY0))) / (log(CGFloat(dataY1)) - log(CGFloat(dataY0))) * (screenY1 - screenY0)
    }
    
    /**
     Draws the logarithmic beacon ranging scale. Close beacons appear as colored circles on the scale.
     */
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        //Setup constants for color gradient
        let startPGradient = CGPoint.zero
        let endPGradient = CGPoint(x:0, y:self.bounds.height)
        
        //Setup constants for scale length
        let startPoint: CGPoint = CGPointMake(rect.size.width - 50, CGRectGetMinY(rect)+95)
        let endPoint: CGPoint = CGPointMake(rect.size.width - 50, CGRectGetMaxY(rect)-yOffset)
        
        let context = UIGraphicsGetCurrentContext()
        
        //Color gradient colors
        let colors = [startColor.CGColor, endColor.CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        //The color gradient in the background of the view
        let gradient = CGGradientCreateWithColors(colorSpace,
                                                  colors,
                                                  colorLocations)
        CGContextDrawLinearGradient(context,
                                    gradient,
                                    startPGradient,
                                    endPGradient,
                                    CGGradientDrawingOptions.DrawsAfterEndLocation)
        
        CGContextSaveGState(context)
        
        //Context is flipped to match the coordinate system
        let flipVertical:CGAffineTransform = CGAffineTransformMake(1,0,0,-1,0,rect.size.height)
        CGContextConcatCTM(context, flipVertical)
        
        //Shadow drawing
        let shadowOffset = CGSizeMake(2.0, 2.0)
        let shadowBlurRadius: CGFloat = 5
        CGContextSetShadowWithColor(context,
                                    shadowOffset,
                                    shadowBlurRadius,
                                    shadow.CGColor)
        CGContextBeginTransparencyLayer(context, nil)
        
        //Scale mark drawing
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
        
        
        //Line drawing
        let linePath: UIBezierPath = UIBezierPath()
        linePath.moveToPoint(CGPointMake(rect.size.width - 50, CGRectGetMinY(rect)+75))
        linePath.addLineToPoint(endPoint)
        linePath.lineWidth = 6.0
        linePath.lineCapStyle = CGLineCap.Round
        UIColor.whiteColor().setStroke()
        linePath.stroke()
        
        //Button background drawing
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
        
        //iBeacon drawing
        for aBeaconDistance in beaconSigmaDistances
        {
            if(aBeaconDistance > 0.0)
            {
                print(aBeaconDistance)
                let beaconY: CGFloat
                if(aBeaconDistance < 1.0)
                    {
                    beaconY = self.convertToLogScale(1.0, screenY0:startPoint.y, screenY1:endPoint.y, dataY0:1.0, dataY1:80.0)
                }else
                    {
                    beaconY = self.convertToLogScale(aBeaconDistance, screenY0:startPoint.y, screenY1:endPoint.y, dataY0:1.0, dataY1:80.0)
                }
                print(beaconY)
                let centerPoint = CGPointMake(rect.size.width - 50, beaconY)
                var startAngle: CGFloat = CGFloat(Float(2 * M_PI))
                var endAngle: CGFloat = 0.0
                let strokeWidth: CGFloat = 3.0
                let radius = CGFloat((25.0 - CGFloat(strokeWidth)) / 2)
                UIColor.whiteColor().setStroke()
                
                //iBeacon coloring based on distance
                switch aBeaconDistance {
                case 0.0:
                    defaultColor.setFill()
                case 0.1..<3.0:
                    immediateColor.setFill()
                case 3.1..<20.0:
                    nearColor.setFill()
                case 20.0..<80.0:
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
