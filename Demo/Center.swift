import CoreGraphics

public final class Center<T: Particle>: Force {
    
    public var center: CGPoint
    
    public init(_ c: CGPoint) {
        center = c
    }
    
    public func tick(alpha: CGFloat, particles: inout Set<T>) {
        let delta = center - (particles.reduce(.zero, { $0 + $1.position }) / CGFloat(particles.count))
        for var particle in particles {
            guard !particle.fixed else { continue }
            particle.position += delta
            particles.update(with: particle)
        }
    }
}
