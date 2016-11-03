import CoreGraphics

fileprivate typealias Charge = (CGFloat, CGPoint)

public final class ManyParticle<T: Particle>: Force {
    
    var strength: CGFloat = -75
    
    private var distanceMin2: CGFloat = 1
    private var distanceMax2: CGFloat = CGFloat.infinity
    private var theta2: CGFloat = 0.81
    
    public init() {
        
    }
    
    public func tick(alpha: CGFloat, particles: inout Set<T>) {
        let tree = QuadTree(particles: particles, initial: { (strength, $0.position) }, accumulator: { (children) -> Charge in
            var value = children.reduce((0, .zero), { (accumulated, child) -> Charge in
                guard let value = child?.value else { return accumulated }
                return (accumulated.0 + value.0, accumulated.1 + (value.1 * value.0))
            })
            value.1 /= value.0
            return value
        })
                
        for var particle in particles {
            guard !particle.fixed else { continue }
            tree?.visit({ (quad) in
                let value = quad.value
                let width = quad.bounds.width
                let delta = (value.1 - particle.position).jiggled

                var distance2 = delta.x * delta.x + delta.y * delta.y
                if distance2 < distanceMin2 {
                    distance2 = sqrt(distanceMin2 * distance2)
                }
                
                // Barnes-Hut approximation
                let barnesHut = (width * width / theta2 < distance2)
                
                if (barnesHut || quad.leaf) && distance2 < distanceMax2 {
                    particle.velocity += (delta * alpha * value.0 / distance2)
                }
                return barnesHut
            })
            particles.update(with: particle)
        }
    }
}
