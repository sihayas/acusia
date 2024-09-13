//
//  PathView.swift
//  acusia
//
//  Created by decoherence on 9/4/24.
//

import Foundation
import UIKit

class PathView: UIView {

    private var points: [CGPoint] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    func add(_ point: CGPoint) {
        if points.count > 300 {
            points.removeFirst()
        }
        points.append(point)
    }

    func reset() {
        points.removeAll()
        setNeedsDisplay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        guard let firstPoint = points.first else {
            return
        }

        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.beginPath()

        context.move(to: firstPoint)

        points.forEach {
            context.addLine(to: $0)
        }

        context.setLineCap(.square)
        context.setStrokeColor(UIColor.systemOrange.cgColor)
        context.setLineWidth(2)
        context.strokePath()
        context.restoreGState()
    }
}
