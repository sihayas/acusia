//
//  CGRect+Extensions.swift
//  acusia
//
//  Created by decoherence on 9/4/24.
//

import UIKit

extension CGRect {

    /**
     The top-left point of the rect.
     */
    var topLeft: CGPoint {
        CGPoint(x: minX, y: minY)
    }

    /**
     The top-right point of the rect.
     */
    var topRight: CGPoint {
        CGPoint(x: maxX, y: minY)
    }

    /**
     The bottom-left point of the rect.
     */
    var bottomLeft: CGPoint {
        CGPoint(x: minX, y: maxY)
    }

    /**
     The bottom-right point of the rect.
     */
    var bottomRight: CGPoint {
        CGPoint(x: maxX, y: maxY)
    }
}
