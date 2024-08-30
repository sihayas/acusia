//
//  TailPath.swift
//  acusia
//
//  Created by decoherence on 8/29/24.
//

import SwiftUI

struct TailPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.53335*width, y: 0.04967*height))
        path.addCurve(to: CGPoint(x: width, y: 0.28913*height), control1: CGPoint(x: 0.51718*width, y: 0.09534*height), control2: CGPoint(x: 0.35126*width, y: 0.28913*height))
        path.addLine(to: CGPoint(x: 0.00506*width, y: height))
        path.addCurve(to: CGPoint(x: 0.03338*width, y: 0.57235*height), control1: CGPoint(x: 0.00506*width, y: height), control2: CGPoint(x: -0.01771*width, y: 0.7149*height))
        path.addCurve(to: CGPoint(x: 0.23337*width, y: 0.22786*height), control1: CGPoint(x: 0.08446*width, y: 0.4298*height), control2: CGPoint(x: 0.11671*width, y: 0.34665*height))
        path.addCurve(to: CGPoint(x: 0.46669*width, y: 0.01403*height), control1: CGPoint(x: 0.35003*width, y: 0.10906*height), control2: CGPoint(x: 0.43353*width, y: 0.03773*height))
        path.addCurve(to: CGPoint(x: 0.53335*width, y: 0.04967*height), control1: CGPoint(x: 0.49986*width, y: -0.00966*height), control2: CGPoint(x: 0.55336*width, y: -0.00682*height))
        path.closeSubpath()
        return path
    }
}

struct AvatarPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.60089*width, y: 0.94947*height))
        path.addCurve(to: CGPoint(x: 0.56032*width, y: 0.9964*height), control1: CGPoint(x: 0.60032*width, y: 0.97307*height), control2: CGPoint(x: 0.58374*width, y: 0.99358*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: height), control1: CGPoint(x: 0.54054*width, y: 0.99878*height), control2: CGPoint(x: 0.52041*width, y: height))
        path.addCurve(to: CGPoint(x: 0, y: 0.5*height), control1: CGPoint(x: 0.22386*width, y: height), control2: CGPoint(x: 0, y: 0.77614*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0), control1: CGPoint(x: 0, y: 0.22386*height), control2: CGPoint(x: 0.22386*width, y: 0))
        path.addCurve(to: CGPoint(x: width, y: 0.5*height), control1: CGPoint(x: 0.77614*width, y: 0), control2: CGPoint(x: width, y: 0.22386*height))
        path.addCurve(to: CGPoint(x: 0.9964*width, y: 0.56032*height), control1: CGPoint(x: width, y: 0.52042*height), control2: CGPoint(x: 0.99878*width, y: 0.54054*height))
        path.addCurve(to: CGPoint(x: 0.94947*width, y: 0.60089*height), control1: CGPoint(x: 0.99358*width, y: 0.58374*height), control2: CGPoint(x: 0.97307*width, y: 0.60032*height))
        path.addCurve(to: CGPoint(x: 0.7638*width, y: 0.6327*height), control1: CGPoint(x: 0.86325*width, y: 0.60296*height), control2: CGPoint(x: 0.80868*width, y: 0.60983*height))
        path.addCurve(to: CGPoint(x: 0.6327*width, y: 0.7638*height), control1: CGPoint(x: 0.70735*width, y: 0.66146*height), control2: CGPoint(x: 0.66146*width, y: 0.70735*height))
        path.addCurve(to: CGPoint(x: 0.60089*width, y: 0.94947*height), control1: CGPoint(x: 0.60983*width, y: 0.80868*height), control2: CGPoint(x: 0.60296*width, y: 0.86325*height))
        path.closeSubpath()
        return path
    }
}
