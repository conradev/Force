//
//  Layer.swift
//  Force
//
//  Created by Conrad Kramer on 10/3/16.
//  Copyright © 2016 Conrad Kramer. All rights reserved.
//

import UIKit

public struct ViewParticle: Particle {
    public var velocity: CGPoint
    public var position: CGPoint
    public var fixed: Bool
    fileprivate let view: Unmanaged<UIView>

    public var hashValue: Int {
        return view.takeUnretainedValue().hashValue
    }
    
    public init(view: UIView) {
        self.view = .passUnretained(view)
        self.velocity = .zero
        self.position = view.center
        self.fixed = false
    }
    
    @inline(__always)
    public func tick() {
        view.takeUnretainedValue().center = position
    }
}

public func ==(lhs: ViewParticle, rhs: ViewParticle) -> Bool {
    return lhs.view.toOpaque() == rhs.view.toOpaque()
}
