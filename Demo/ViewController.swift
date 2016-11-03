//
//  ViewController.swift
//  Force
//
//  Created by Conrad Kramer on 9/3/16.
//  Copyright © 2016 Conrad Kramer. All rights reserved.
//

import UIKit

extension UIColor {
    fileprivate convenience init(rgbaValue: UInt32) {
        let max = CGFloat(UInt8.max)
        self.init(red: CGFloat((rgbaValue >> 24) & 0xFF) / max,
                  green: CGFloat((rgbaValue >> 16) & 0xFF) / max,
                  blue: CGFloat((rgbaValue >> 8) & 0xFF) / max,
                  alpha: CGFloat(rgbaValue & 0xFF) / max)
    }
}

class ViewController: UIViewController {
    
    private let center: Center<ViewParticle> = Center(.zero)
    
    private let manyParticle: ManyParticle<ViewParticle> = ManyParticle()
    
    private let links: Links<ViewParticle> = Links()
    
    private lazy var linkLayer: CAShapeLayer = {
        let linkLayer = CAShapeLayer()
        linkLayer.strokeColor = UIColor.gray.cgColor
        linkLayer.fillColor = UIColor.clear.cgColor
        linkLayer.lineWidth = 2
        self.view.layer.insertSublayer(linkLayer, at: 0)
        return linkLayer
    }()
    
    fileprivate lazy var simulation: Simulation<ViewParticle> = {
        let simulation: Simulation<ViewParticle>  = Simulation()
        simulation.insert(force: self.manyParticle)
        simulation.insert(force: self.links)
        simulation.insert(force: self.center)
        simulation.insert(tick: { self.linkLayer.path = self.links.path(from: &$0) })
        return simulation
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        func particle(color: UIColor) -> ViewParticle {
            let view = UIView()
            view.center = CGPoint(x: CGFloat(arc4random_uniform(320)), y: -CGFloat(arc4random_uniform(100)))
            view.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
            self.view.addSubview(view)

            let gestureRecogizer = UIPanGestureRecognizer(target: self, action: #selector(dragged(_:)))
            view.addGestureRecognizer(gestureRecogizer)
            
            let layer = CAShapeLayer()
            layer.frame = view.bounds
            layer.path = UIBezierPath(ovalIn: CGRect(x: 10, y: 10, width: 30, height: 30)).cgPath
            layer.fillColor = color.cgColor
            layer.strokeColor = UIColor.gray.cgColor
            layer.lineWidth = 2
            view.layer.addSublayer(layer)
            
            let particle = ViewParticle(view: view)
            simulation.insert(particle: particle)
            return particle
        }
        
        let size = 5
        var particles: [ViewParticle] = []
        for _ in 0..<(size * size) {
            particles.append(particle(color: UIColor(rgbaValue: 0x4CB3BCFF)))
        }
        
        for y in 0..<size {
            for x in 0..<size {
                let current = y * size + x
                if x < size - 1 {
                    links.link(between: particles[current], and: particles[current + 1])
                }
                if y < size - 1 {
                    links.link(between: particles[current], and: particles[current + size])
                }
            }
        }
        
//        let a = particle(color: UIColor(rgbaValue: 0xCC4250FF))
//        let b = particle(color: UIColor(rgbaValue: 0x43BD47FF))
//        let c = particle(color: UIColor(rgbaValue: 0x43BD47FF))
//        let d = particle(color: UIColor(rgbaValue: 0x4CB3BCFF))
//        let e = particle(color: UIColor(rgbaValue: 0x4CB3BCFF))
//        let f = particle(color: UIColor(rgbaValue: 0xCB824AFF))
//        
//        links.link(between: a, and: b, distance: 100)
//        links.link(between: a, and: c, distance: 100)
//        links.link(between: c, and: b, distance: 40)
//        links.link(between: d, and: b, distance: 100)
//        links.link(between: e, and: c, distance: 100)
//        links.link(between: e, and: f, distance: 100)
    }
    
    override func viewWillLayoutSubviews() {
        linkLayer.frame = view.bounds
        center.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        simulation.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        simulation.stop()
    }
    
    @objc private func dragged(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view, let index = simulation.particles.index(of: ViewParticle(view: view)) else { return }
        var particle = simulation.particles[index]
        switch gestureRecognizer.state {
        case .began:
            particle.fixed = true
        case .changed:
            particle.position = gestureRecognizer.location(in: self.view)
            simulation.kick()
        case .cancelled, .ended:
            particle.fixed = false
            particle.velocity += gestureRecognizer.velocity(in: self.view) * 0.05
        default:
            break
        }
        simulation.particles.update(with: particle)
    }
}
