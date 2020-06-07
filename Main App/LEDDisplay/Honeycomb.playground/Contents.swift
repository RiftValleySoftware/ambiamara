/**
 © Copyright 2018, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import UIKit
import PlaygroundSupport

extension CGFloat {
    var radians: CGFloat {
        let b = CGFloat(Double.pi) * (self/180)
        return b
    }
}

/* ################################################################## */
/**
 */
func pointySideUpHexagon(_ inHowBig: CGFloat = 100) -> [CGPoint] {
    let angle = CGFloat(60).radians
    let cx = CGFloat(inHowBig) // x origin
    let cy = CGFloat(inHowBig) // y origin
    let r = CGFloat(inHowBig) // radius of circle
    var points = [CGPoint]()
    var minX: CGFloat = inHowBig * 2
    var maxX: CGFloat = 0
    for i in 0...6 {
        let x = cx + r * cos(angle * CGFloat(i) - CGFloat(30).radians)
        let y = cy + r * sin(angle * CGFloat(i) - CGFloat(30).radians)
        minX = min(minX, x)
        maxX = max(maxX, x)
        points.append(CGPoint(x: x, y: y))
    }
    
    var index = 0
    for point in points {
        points[index] = CGPoint(x: point.x - minX, y: point.y)
        index += 1
    }
    
    return points
}

/* ################################################################## */
/**
 */
func getHexPath(_ inHowBig: CGFloat) -> CGMutablePath {
    let path = CGMutablePath()
    let points = pointySideUpHexagon(inHowBig)
    let cpg = points[0]
    path.move(to: cpg)
    for p in points {
        path.addLine(to: p)
    }
    path.closeSubpath()
    return path
}

class View: UIView {
    var filledWithHexagons: CGPath {
        let path = CGMutablePath()
        let sHexagonWidth = bounds.size.height / 50
        let radius: CGFloat = sHexagonWidth / 2
        
        let hexPath: CGMutablePath = getHexPath(radius)
        let oneHexWidth = hexPath.boundingBox.size.width
        let oneHexHeight = hexPath.boundingBox.size.height
        
        var nudgeX: CGFloat = 0
        let nudgeY: CGFloat = radius + ((oneHexHeight - oneHexWidth) * 2)
        
        var yOffset: CGFloat = 0
        while yOffset < bounds.size.height {
            var xOffset = nudgeX
            while xOffset < bounds.size.width {
                let transform = CGAffineTransform(translationX: xOffset, y: yOffset)
                path.addPath(hexPath, transform: transform)
                xOffset += oneHexWidth
            }
            
            nudgeX = (0 < nudgeX) ? 0 : oneHexWidth / 2.0
            yOffset += nudgeY
       }
        
        return path
    }
    
    func drawPolygonUsingPath(ctx: CGContext) {
        let path = filledWithHexagons
        ctx.addPath(path)
        ctx.setLineWidth(0.25)
        ctx.setStrokeColor(UIColor.red.cgColor)
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.strokePath()
    }
    
    override func layoutSubviews() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let drawingContext = UIGraphicsGetCurrentContext()
        
        drawPolygonUsingPath(ctx: drawingContext!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageView = UIImageView(frame: bounds)
        imageView.image = image
        
        addSubview(imageView)
    }
}

View(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
