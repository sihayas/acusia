//
//  InstantPanGestureRecognizer.swift
//  acusia
//
//  Created by decoherence on 9/4/24.
//

import Foundation
import UIKit

public class InstantPanGestureRecognizer: UIPanGestureRecognizer {

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.state = .began
    }

}
