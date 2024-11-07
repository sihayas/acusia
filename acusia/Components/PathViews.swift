//
//  TailPath.swift
//  acusia
//
//  Created by decoherence on 8/29/24.
//

import SwiftUI

// MARK: - Imprint Paths

/// Mainly for the Imprint.
struct HeartPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.50377*width, y: 0.94841*height))
        path.addCurve(to: CGPoint(x: 0.55992*width, y: 0.86416*height), control1: CGPoint(x: 0.51099*width, y: 0.92834*height), control2: CGPoint(x: 0.53393*width, y: 0.89397*height))
        path.addCurve(to: CGPoint(x: 0.70968*width, y: 0.733*height), control1: CGPoint(x: 0.60414*width, y: 0.81352*height), control2: CGPoint(x: 0.65475*width, y: 0.76912*height))
        path.addCurve(to: CGPoint(x: 0.85063*width, y: 0.63408*height), control1: CGPoint(x: 0.79539*width, y: 0.67658*height), control2: CGPoint(x: 0.81879*width, y: 0.66016*height))
        path.addCurve(to: CGPoint(x: 0.93793*width, y: 0.54489*height), control1: CGPoint(x: 0.88596*width, y: 0.60511*height), control2: CGPoint(x: 0.9162*width, y: 0.57424*height))
        path.addCurve(to: CGPoint(x: 0.9988*width, y: 0.3913*height), control1: CGPoint(x: 0.97334*width, y: 0.49714*height), control2: CGPoint(x: 0.99355*width, y: 0.44604*height))
        path.addCurve(to: CGPoint(x: 0.99728*width, y: 0.30682*height), control1: CGPoint(x: 1.00085*width, y: 0.36978*height), control2: CGPoint(x: 1.00024*width, y: 0.33359*height))
        path.addCurve(to: CGPoint(x: 0.85876*width, y: 0.07423*height), control1: CGPoint(x: 0.98557*width, y: 0.2009*height), control2: CGPoint(x: 0.93542*width, y: 0.11666*height))
        path.addCurve(to: CGPoint(x: 0.78338*width, y: 0.04861*height), control1: CGPoint(x: 0.8365*width, y: 0.06184*height), control2: CGPoint(x: 0.81028*width, y: 0.05294*height))
        path.addCurve(to: CGPoint(x: 0.72229*width, y: 0.04785*height), control1: CGPoint(x: 0.77138*width, y: 0.04671*height), control2: CGPoint(x: 0.73612*width, y: 0.04625*height))
        path.addCurve(to: CGPoint(x: 0.54237*width, y: 0.15855*height), control1: CGPoint(x: 0.65247*width, y: 0.05591*height), control2: CGPoint(x: 0.59001*width, y: 0.0943*height))
        path.addCurve(to: CGPoint(x: 0.50187*width, y: 0.22805*height), control1: CGPoint(x: 0.52732*width, y: 0.17885*height), control2: CGPoint(x: 0.51213*width, y: 0.20494*height))
        path.addLine(to: CGPoint(x: 0.50027*width, y: 0.23178*height))
        path.addLine(to: CGPoint(x: 0.49693*width, y: 0.22463*height))
        path.addCurve(to: CGPoint(x: 0.3901*width, y: 0.09415*height), control1: CGPoint(x: 0.47071*width, y: 0.16859*height), control2: CGPoint(x: 0.43417*width, y: 0.12396*height))
        path.addCurve(to: CGPoint(x: 0.28349*width, y: 0.05241*height), control1: CGPoint(x: 0.35644*width, y: 0.07149*height), control2: CGPoint(x: 0.32194*width, y: 0.05788*height))
        path.addCurve(to: CGPoint(x: 0.22757*width, y: 0.05127*height), control1: CGPoint(x: 0.27255*width, y: 0.05081*height), control2: CGPoint(x: 0.2392*width, y: 0.05013*height))
        path.addCurve(to: CGPoint(x: 0.06124*width, y: 0.14662*height), control1: CGPoint(x: 0.16055*width, y: 0.05773*height), control2: CGPoint(x: 0.10235*width, y: 0.09119*height))
        path.addCurve(to: CGPoint(x: 0.00076*width, y: 0.32507*height), control1: CGPoint(x: 0.02629*width, y: 0.19383*height), control2: CGPoint(x: 0.0057*width, y: 0.25459*height))
        path.addCurve(to: CGPoint(x: 0.00114*width, y: 0.38962*height), control1: CGPoint(x: -0.00038*width, y: 0.34187*height), control2: CGPoint(x: -0.00023*width, y: 0.37617*height))
        path.addCurve(to: CGPoint(x: 0.03085*width, y: 0.49083*height), control1: CGPoint(x: 0.00479*width, y: 0.4262*height), control2: CGPoint(x: 0.01383*width, y: 0.45677*height))
        path.addCurve(to: CGPoint(x: 0.10645*width, y: 0.59089*height), control1: CGPoint(x: 0.04848*width, y: 0.52596*height), control2: CGPoint(x: 0.07196*width, y: 0.55698*height))
        path.addCurve(to: CGPoint(x: 0.24998*width, y: 0.70297*height), control1: CGPoint(x: 0.14095*width, y: 0.6248*height), control2: CGPoint(x: 0.17689*width, y: 0.65286*height))
        path.addCurve(to: CGPoint(x: 0.30127*width, y: 0.73901*height), control1: CGPoint(x: 0.27187*width, y: 0.71795*height), control2: CGPoint(x: 0.28843*width, y: 0.72958*height))
        path.addCurve(to: CGPoint(x: 0.48728*width, y: 0.93145*height), control1: CGPoint(x: 0.37756*width, y: 0.79497*height), control2: CGPoint(x: 0.45651*width, y: 0.87663*height))
        path.addCurve(to: CGPoint(x: 0.49617*width, y: 0.95191*height), control1: CGPoint(x: 0.49153*width, y: 0.93913*height), control2: CGPoint(x: 0.49617*width, y: 0.9497*height))
        path.addCurve(to: CGPoint(x: 0.49913*width, y: 0.95313*height), control1: CGPoint(x: 0.49617*width, y: 0.95282*height), control2: CGPoint(x: 0.49693*width, y: 0.95313*height))
        path.addCurve(to: CGPoint(x: 0.50377*width, y: 0.94841*height), control1: CGPoint(x: 0.50202*width, y: 0.95313*height), control2: CGPoint(x: 0.5021*width, y: 0.95305*height))
        path.closeSubpath()
        return path
    }
}

struct HeartbreakLeftPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.49913*width, y: 0.95313*height))
        path.addCurve(to: CGPoint(x: 0.49617*width, y: 0.95191*height), control1: CGPoint(x: 0.49693*width, y: 0.95313*height), control2: CGPoint(x: 0.49617*width, y: 0.95283*height))
        path.addCurve(to: CGPoint(x: 0.48728*width, y: 0.93146*height), control1: CGPoint(x: 0.49617*width, y: 0.94971*height), control2: CGPoint(x: 0.49153*width, y: 0.93914*height))
        path.addCurve(to: CGPoint(x: 0.30127*width, y: 0.73901*height), control1: CGPoint(x: 0.45651*width, y: 0.87664*height), control2: CGPoint(x: 0.37756*width, y: 0.79497*height))
        path.addCurve(to: CGPoint(x: 0.24998*width, y: 0.70297*height), control1: CGPoint(x: 0.28843*width, y: 0.72958*height), control2: CGPoint(x: 0.27187*width, y: 0.71795*height))
        path.addCurve(to: CGPoint(x: 0.10645*width, y: 0.5909*height), control1: CGPoint(x: 0.17689*width, y: 0.65286*height), control2: CGPoint(x: 0.14095*width, y: 0.62481*height))
        path.addCurve(to: CGPoint(x: 0.03085*width, y: 0.49083*height), control1: CGPoint(x: 0.07196*width, y: 0.55698*height), control2: CGPoint(x: 0.04848*width, y: 0.52596*height))
        path.addCurve(to: CGPoint(x: 0.00114*width, y: 0.38963*height), control1: CGPoint(x: 0.01383*width, y: 0.45677*height), control2: CGPoint(x: 0.00479*width, y: 0.4262*height))
        path.addCurve(to: CGPoint(x: 0.00076*width, y: 0.32508*height), control1: CGPoint(x: -0.00023*width, y: 0.37617*height), control2: CGPoint(x: -0.00038*width, y: 0.34188*height))
        path.addCurve(to: CGPoint(x: 0.06124*width, y: 0.14662*height), control1: CGPoint(x: 0.0057*width, y: 0.25459*height), control2: CGPoint(x: 0.02629*width, y: 0.19384*height))
        path.addCurve(to: CGPoint(x: 0.22757*width, y: 0.05127*height), control1: CGPoint(x: 0.10235*width, y: 0.09119*height), control2: CGPoint(x: 0.16055*width, y: 0.05773*height))
        path.addCurve(to: CGPoint(x: 0.28349*width, y: 0.05241*height), control1: CGPoint(x: 0.2392*width, y: 0.05013*height), control2: CGPoint(x: 0.27255*width, y: 0.05082*height))
        path.addCurve(to: CGPoint(x: 0.3901*width, y: 0.09416*height), control1: CGPoint(x: 0.32194*width, y: 0.05789*height), control2: CGPoint(x: 0.35644*width, y: 0.0715*height))
        path.addCurve(to: CGPoint(x: 0.49693*width, y: 0.22463*height), control1: CGPoint(x: 0.43417*width, y: 0.12396*height), control2: CGPoint(x: 0.47071*width, y: 0.16859*height))
        path.addLine(to: CGPoint(x: 0.50027*width, y: 0.23178*height))
        path.addLine(to: CGPoint(x: 0.45162*width, y: 0.32508*height))
        path.addLine(to: CGPoint(x: 0.50027*width, y: 0.41786*height))
        path.addLine(to: CGPoint(x: 0.45162*width, y: 0.49481*height))
        path.addLine(to: CGPoint(x: 0.50027*width, y: 0.6148*height))
        path.addLine(to: CGPoint(x: 0.45162*width, y: 0.73901*height))
        path.addLine(to: CGPoint(x: 0.49913*width, y: 0.8676*height))
        path.addLine(to: CGPoint(x: 0.49913*width, y: 0.95313*height))
        path.closeSubpath()
        return path
    }
}

struct HeartbreakRightPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.55992*width, y: 0.86416*height))
        path.addCurve(to: CGPoint(x: 0.50377*width, y: 0.94841*height), control1: CGPoint(x: 0.53393*width, y: 0.89397*height), control2: CGPoint(x: 0.51099*width, y: 0.92834*height))
        path.addCurve(to: CGPoint(x: 0.49913*width, y: 0.95313*height), control1: CGPoint(x: 0.5021*width, y: 0.95305*height), control2: CGPoint(x: 0.50202*width, y: 0.95313*height))
        path.addLine(to: CGPoint(x: 0.49913*width, y: 0.8676*height))
        path.addLine(to: CGPoint(x: 0.45162*width, y: 0.73901*height))
        path.addLine(to: CGPoint(x: 0.50027*width, y: 0.61479*height))
        path.addLine(to: CGPoint(x: 0.45162*width, y: 0.4948*height))
        path.addLine(to: CGPoint(x: 0.50027*width, y: 0.41785*height))
        path.addLine(to: CGPoint(x: 0.45162*width, y: 0.32507*height))
        path.addLine(to: CGPoint(x: 0.50027*width, y: 0.23178*height))
        path.addLine(to: CGPoint(x: 0.50187*width, y: 0.22805*height))
        path.addCurve(to: CGPoint(x: 0.54237*width, y: 0.15855*height), control1: CGPoint(x: 0.51213*width, y: 0.20494*height), control2: CGPoint(x: 0.52732*width, y: 0.17885*height))
        path.addCurve(to: CGPoint(x: 0.72229*width, y: 0.04785*height), control1: CGPoint(x: 0.59001*width, y: 0.0943*height), control2: CGPoint(x: 0.65247*width, y: 0.05591*height))
        path.addCurve(to: CGPoint(x: 0.78338*width, y: 0.04861*height), control1: CGPoint(x: 0.73612*width, y: 0.04625*height), control2: CGPoint(x: 0.77138*width, y: 0.04671*height))
        path.addCurve(to: CGPoint(x: 0.85876*width, y: 0.07423*height), control1: CGPoint(x: 0.81028*width, y: 0.05294*height), control2: CGPoint(x: 0.8365*width, y: 0.06184*height))
        path.addCurve(to: CGPoint(x: 0.99728*width, y: 0.30682*height), control1: CGPoint(x: 0.93542*width, y: 0.11666*height), control2: CGPoint(x: 0.98557*width, y: 0.2009*height))
        path.addCurve(to: CGPoint(x: 0.9988*width, y: 0.3913*height), control1: CGPoint(x: 1.00024*width, y: 0.33359*height), control2: CGPoint(x: 1.00085*width, y: 0.36978*height))
        path.addCurve(to: CGPoint(x: 0.93793*width, y: 0.54489*height), control1: CGPoint(x: 0.99355*width, y: 0.44604*height), control2: CGPoint(x: 0.97334*width, y: 0.49714*height))
        path.addCurve(to: CGPoint(x: 0.85063*width, y: 0.63408*height), control1: CGPoint(x: 0.9162*width, y: 0.57424*height), control2: CGPoint(x: 0.88596*width, y: 0.60511*height))
        path.addCurve(to: CGPoint(x: 0.70968*width, y: 0.733*height), control1: CGPoint(x: 0.81879*width, y: 0.66016*height), control2: CGPoint(x: 0.79539*width, y: 0.67658*height))
        path.addCurve(to: CGPoint(x: 0.55992*width, y: 0.86416*height), control1: CGPoint(x: 0.65475*width, y: 0.76912*height), control2: CGPoint(x: 0.60414*width, y: 0.81352*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.00738*width, y: 0.27409*height))
        path.addCurve(to: CGPoint(x: 0.00076*width, y: 0.32507*height), control1: CGPoint(x: 0.00421*width, y: 0.29044*height), control2: CGPoint(x: 0.002*width, y: 0.30745*height))
        path.addCurve(to: CGPoint(x: 0.00114*width, y: 0.38962*height), control1: CGPoint(x: -0.00038*width, y: 0.34187*height), control2: CGPoint(x: -0.00023*width, y: 0.37617*height))
        path.addCurve(to: CGPoint(x: 0.00391*width, y: 0.41039*height), control1: CGPoint(x: 0.00185*width, y: 0.39675*height), control2: CGPoint(x: 0.00277*width, y: 0.40365*height))
        path.addCurve(to: CGPoint(x: 0.00114*width, y: 0.38962*height), control1: CGPoint(x: 0.00277*width, y: 0.40365*height), control2: CGPoint(x: 0.00185*width, y: 0.39675*height))
        path.addCurve(to: CGPoint(x: 0.00076*width, y: 0.32507*height), control1: CGPoint(x: -0.00023*width, y: 0.37617*height), control2: CGPoint(x: -0.00038*width, y: 0.34187*height))
        path.addCurve(to: CGPoint(x: 0.00738*width, y: 0.27409*height), control1: CGPoint(x: 0.002*width, y: 0.30745*height), control2: CGPoint(x: 0.00421*width, y: 0.29044*height))
        path.closeSubpath()
        return path
    }
}

struct NoodleIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.20743*width, y: 0.22529*height))
        path.addCurve(to: CGPoint(x: 0.41576*width, y: 0.58954*height), control1: CGPoint(x: 0.23801*width, y: 0.36667*height), control2: CGPoint(x: 0.31216*width, y: 0.48463*height))
        path.addCurve(to: CGPoint(x: 0.89289*width, y: 0.80689*height), control1: CGPoint(x: 0.55211*width, y: 0.72033*height), control2: CGPoint(x: 0.70496*width, y: 0.80287*height))
        path.addCurve(to: CGPoint(x: 0.97219*width, y: 0.89223*height), control1: CGPoint(x: 0.94107*width, y: 0.80792*height), control2: CGPoint(x: 0.97328*width, y: 0.84791*height))
        path.addCurve(to: CGPoint(x: 0.89034*width, y: 0.97213*height), control1: CGPoint(x: 0.97115*width, y: 0.93466*height), control2: CGPoint(x: 0.93938*width, y: 0.97448*height))
        path.addCurve(to: CGPoint(x: 0.88342*width, y: 0.9718*height), control1: CGPoint(x: 0.88804*width, y: 0.97202*height), control2: CGPoint(x: 0.88573*width, y: 0.97191*height))
        path.addCurve(to: CGPoint(x: 0.74369*width, y: 0.95718*height), control1: CGPoint(x: 0.83849*width, y: 0.96967*height), control2: CGPoint(x: 0.79024*width, y: 0.96738*height))
        path.addCurve(to: CGPoint(x: 0.21121*width, y: 0.61031*height), control1: CGPoint(x: 0.52228*width, y: 0.90868*height), control2: CGPoint(x: 0.34787*width, y: 0.78566*height))
        path.addCurve(to: CGPoint(x: 0.0278*width, y: 0.11974*height), control1: CGPoint(x: 0.09998*width, y: 0.46759*height), control2: CGPoint(x: 0.03094*width, y: 0.30588*height))
        path.addCurve(to: CGPoint(x: 0.04798*width, y: 0.0553*height), control1: CGPoint(x: 0.02739*width, y: 0.09554*height), control2: CGPoint(x: 0.03338*width, y: 0.0727*height))
        path.addCurve(to: CGPoint(x: 0.10769*width, y: 0.02783*height), control1: CGPoint(x: 0.06294*width, y: 0.03746*height), control2: CGPoint(x: 0.08427*width, y: 0.02855*height))
        path.addCurve(to: CGPoint(x: 0.17005*width, y: 0.05275*height), control1: CGPoint(x: 0.13213*width, y: 0.02707*height), control2: CGPoint(x: 0.15411*width, y: 0.03539*height))
        path.addCurve(to: CGPoint(x: 0.19443*width, y: 0.11572*height), control1: CGPoint(x: 0.18542*width, y: 0.06949*height), control2: CGPoint(x: 0.19278*width, y: 0.09197*height))
        path.addCurve(to: CGPoint(x: 0.20743*width, y: 0.22529*height), control1: CGPoint(x: 0.19708*width, y: 0.15391*height), control2: CGPoint(x: 0.19989*width, y: 0.19042*height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Entry Paths

struct BubbleWithTailShape: Shape {
    var scale: CGFloat

    func path(in rect: CGRect) -> Path {
        let bubbleRect = rect
        let bubble = RoundedRectangle(cornerRadius: 20, style: .continuous)
            .path(in: bubbleRect)

        let firstCircleSize: CGFloat = 12
        let firstCircleOffsetX: CGFloat = 0
        let firstCircleOffsetY: CGFloat = bubbleRect.height - firstCircleSize

        let tailRect = CGRect(
            x: bubbleRect.minX + firstCircleOffsetX,
            y: bubbleRect.minY + firstCircleOffsetY,
            width: firstCircleSize,
            height: firstCircleSize
        )
        let tail = Circle().path(in: tailRect)

        let secondCircleSize: CGFloat = 6
        let secondCircleOffsetX = tailRect.minX - secondCircleSize
        let secondCircleOffsetY = tailRect.maxY - secondCircleSize / 2
        let secondCircleRect = CGRect(
            x: secondCircleOffsetX,
            y: secondCircleOffsetY,
            width: secondCircleSize,
            height: secondCircleSize
        )
        let secondCircle = Circle().path(in: secondCircleRect)

        let combined = bubble.union(tail).union(secondCircle)

        return combined
    }

    var animatableData: CGFloat {
        get { scale }
        set { scale = newValue }
    }
}

/// Same as above shape, but used for context-auxilliary preview.
struct BubbleWithTailPath {
    func path(in rect: CGRect) -> UIBezierPath {
        let cornerRadius: CGFloat = 20
        let firstCircleSize: CGFloat = 12
        let secondCircleSize: CGFloat = 6

        let bubblePath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        
        // First circle (tail)
        let firstCircleRect = CGRect(
            x: rect.minX,
            y: rect.maxY - firstCircleSize,
            width: firstCircleSize,
            height: firstCircleSize
        )
        bubblePath.append(UIBezierPath(ovalIn: firstCircleRect))
        
        // Second smaller circle
        let secondCircleRect = CGRect(
            x: firstCircleRect.minX - secondCircleSize,
            y: firstCircleRect.maxY - secondCircleSize / 2,
            width: secondCircleSize,
            height: secondCircleSize
        )
        bubblePath.append(UIBezierPath(ovalIn: secondCircleRect))
        
        return bubblePath
    }
}

struct SoundBubbleWithTail: Shape {
    func path(in rect: CGRect) -> Path {
        let bubbleRect = rect
        let bubble = Circle().path(in: bubbleRect)

        let tailSize: CGFloat = 12
        let tailOffsetX: CGFloat = 0
        let tailOffsetY: CGFloat = bubbleRect.height - tailSize

        let tailRect = CGRect(
            x: bubbleRect.minX + tailOffsetX,
            y: bubbleRect.minY + tailOffsetY,
            width: tailSize,
            height: tailSize
        )
        let tail = Circle().path(in: tailRect)

        let secondCircleSize: CGFloat = 6
        let secondCircleOffsetX = tailRect.maxX
        let secondCircleOffsetY = tailRect.maxY
        let secondCircleRect = CGRect(
            x: secondCircleOffsetX,
            y: secondCircleOffsetY,
            width: secondCircleSize,
            height: secondCircleSize
        )
        let secondCircle = Circle().path(in: secondCircleRect)

        let combined = bubble.union(tail).union(secondCircle)

        return combined
    }
}

struct BlipBubbleWithTail: Shape {
    func path(in rect: CGRect) -> Path {
        let bubbleRect = rect
        let bubble = Circle().path(in: bubbleRect)

        let tailSize: CGFloat = 12
        let tailOffsetY: CGFloat = bubbleRect.height - tailSize

        let tailRect = CGRect(
            x: bubbleRect.maxX - tailSize,
            y: bubbleRect.maxY - tailSize,
            width: tailSize,
            height: tailSize
        )
        let tail = Circle().path(in: tailRect)

        let secondCircleSize: CGFloat = 6
        let secondCircleRect = CGRect(
            x: tailRect.maxX,
            y: tailRect.maxY,
            width: secondCircleSize,
            height: secondCircleSize
        )
        let secondCircle = Circle().path(in: secondCircleRect)

        let combined = bubble.union(tail).union(secondCircle)

        return combined
    }
}



struct TopLeadingToBottomCenterPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))

        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + rect.width / 2))

        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.minY)
        )

        return path
    }
}

struct TopCenterToBottomTrailingPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top center
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))

        // Draw the vertical line downwards, leaving space for the curve
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - rect.width / 2))

        // Draw the rounded corner curve to the right center
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                          control: CGPoint(x: rect.midX, y: rect.maxY))

        return path
    }
}

struct ConnectedRepliesPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // Draw the top curve to the center
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY + rect.width / 2),
                          control: CGPoint(x: rect.midX, y: rect.minY))

        // Draw the vertical line downwards, leaving space for the bottom curve
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - rect.width / 2))

        // Draw the bottom curve back to the left
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY),
                          control: CGPoint(x: rect.midX, y: rect.maxY))

        return path
    }
}

struct LoopPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.5*width, y: 0.95*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.75*height))
        path.addCurve(to: CGPoint(x: 0.20953*width, y: 0.26027*height), control1: CGPoint(x: 0.5*width, y: 0.51429*height), control2: CGPoint(x: 0.36032*width, y: 0.26027*height))
        path.addCurve(to: CGPoint(x: 0.03333*width, y: 0.50961*height), control1: CGPoint(x: 0.05874*width, y: 0.26027*height), control2: CGPoint(x: 0.03333*width, y: 0.41697*height))
        path.addCurve(to: CGPoint(x: 0.20956*width, y: 0.74652*height), control1: CGPoint(x: 0.03333*width, y: 0.60226*height), control2: CGPoint(x: 0.06435*width, y: 0.74652*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.25*height), control1: CGPoint(x: 0.3771*width, y: 0.74652*height), control2: CGPoint(x: 0.5*width, y: 0.50267*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.05*height))
        return path
    }
}

// MARK: Entry Paths
