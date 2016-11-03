import CoreGraphics
import QuartzCore

public protocol Particle: Hashable {
    var position: CGPoint { get set }
    var velocity: CGPoint { get set }
    var fixed: Bool { get set }
    
    func tick()
}

public protocol Force {
    associatedtype Subject: Particle

    func tick(alpha: CGFloat, particles: inout Set<Subject>)
}

public class Simulation<T: Particle> {
    
    private let alphaTarget: CGFloat = 0
    private let alphaMin: CGFloat = 0.001
    private let alphaDecay: CGFloat = 1 - pow(0.001, 1 / 500)
    private let velocityDecay: CGFloat = 0.9
    
    var particles: Set<T> = []
    private var forces: [(CGFloat, inout Set<T>) -> Void] = []
    private var ticks: [(inout Set<T>) -> Void] = []
    
    private weak var displayLink: CADisplayLink?
    
    private var alpha: CGFloat = 1 {
        didSet {
            if alpha < alphaMin {
                alpha = 0
            }
            displayLink?.isPaused = (alpha < alphaMin)
        }
    }
    
    public init() {
        
    }
    
    public func insert<U: Force>(force: U) where U.Subject == T {
        forces.append(force.tick)
    }
    
    public func insert(tick: @escaping (inout Set<T>) -> Void) {
        ticks.append(tick)
    }
    
    public func insert(particle: T) {
        particles.insert(particle)
    }
    
    public func remove(particle: T) {
        particles.remove(particle)
    }
    
    public func start() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: RunLoop.main, forMode: .commonModes)
        displayLink = link
    }
    
    public func stop() {
        displayLink?.remove(from: RunLoop.main, forMode: .commonModes)
    }
    
    public func kick() {
        alpha = 1
    }
    
    @objc private func tick() {
        alpha += (alphaTarget - alpha) * alphaDecay;
        guard alpha > alphaMin else { return }
        
        for force in forces {
            force(alpha, &particles)
        }
        
        for var particle in particles {
            if particle.fixed {
                particle.velocity = .zero
            } else {
                particle.velocity *= velocityDecay
                particle.position += particle.velocity
            }
            particles.update(with: particle)
        }
        
        for particle in particles {
            particle.tick()
        }
        for tick in ticks {
            tick(&particles)
        }
    }
}
