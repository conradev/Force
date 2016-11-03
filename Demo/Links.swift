//
//  Links.swift
//  Force
//
//  Created by Conrad Kramer on 9/3/16.
//  Copyright © 2016 Conrad Kramer. All rights reserved.
//

import CoreGraphics

fileprivate struct Link<T: Particle>: Hashable {
    let a: T
    let b: T
    let strength: CGFloat?
    let distance: CGFloat?
    
    var hashValue: Int {
        return a.hashValue ^ b.hashValue
    }
    
    init(between a: T, and b: T, strength: CGFloat? = nil, distance: CGFloat? = nil) {
        self.a = a
        self.b = b
        self.strength = strength
        self.distance = distance
    }
    
    public func tick(alpha: CGFloat, degrees: Dictionary<T, UInt>, distance: CGFloat, particles: inout Set<T>) {
        guard let fromIndex = particles.index(of: a),
            let toIndex = particles.index(of: b) else { return }
        
        var from = particles[fromIndex]
        var to = particles[toIndex]
        
        let fromDegree = CGFloat(degrees[a] ?? 0)
        let toDegree = CGFloat(degrees[b] ?? 0)
        
        let bias = fromDegree / (fromDegree + toDegree)
        let distance = (self.distance ?? distance)
        let strength = (self.strength ?? 0.7 / CGFloat(min(fromDegree, toDegree)))
        
        let delta = (to.position + to.velocity - from.position - from.velocity).jiggled
        let magnitude = delta.magnitude
        let value = delta * ((magnitude - distance) / magnitude) * alpha * strength
        
        to.velocity -= value * bias;
        from.velocity += (value * (1 - bias))
        
        particles.update(with: from)
        particles.update(with: to)
    }
}

public final class Links<T: Particle>: Force {
    
    var distance: CGFloat = 40
        
    private var links: Set<Link<T>> = []
    private var degrees: Dictionary<T, UInt> = [:]
    
    public init() {
        
    }
    
    public func link(between a: T, and b: T, strength: CGFloat? = nil, distance: CGFloat? = nil) {
        if links.update(with: Link(between: a, and: b, strength: strength, distance: distance)) == nil {
            degrees[a] = (degrees[a] ?? 0) + 1
            degrees[b] = (degrees[b] ?? 0) + 1
        }
    }

    public func unlink(between a: T, and b: T) {
        if links.remove(Link(between: a, and: b, strength: nil, distance: distance)) != nil {
            degrees[a] = (degrees[a] ?? 0) - 1
            degrees[b] = (degrees[b] ?? 0) - 1
        }
    }

    public func tick(alpha: CGFloat, particles: inout Set<T>) {
        for link in links {            
            link.tick(alpha: alpha, degrees: degrees, distance: distance, particles: &particles)
        }
    }
    
    public func path(from particles: inout Set<T>) -> CGPath {
        let path = CGMutablePath()
        for link in links {
            guard let fromIndex = particles.index(of: link.a),
                let toIndex = particles.index(of: link.b) else { continue }
            path.move(to: particles[fromIndex].position)
            path.addLine(to: particles[toIndex].position)
        }
        return path
    }
}

fileprivate func ==<T: Particle>(lhs: Link<T>, rhs: Link<T>) -> Bool {
    return ((lhs.a == rhs.a && lhs.b == rhs.b) || (lhs.a == rhs.b && lhs.b == rhs.a))
}
