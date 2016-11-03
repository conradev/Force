import CoreGraphics

fileprivate var jiggle: CGFloat {
    return (CGFloat(arc4random()) - CGFloat(UInt32.max / 2)) * 1e-6
}

extension CGPoint {
    internal var jiggled: CGPoint {
        var point = self
        if point.x == 0 { point.x = jiggle }
        if point.y == 0 { point.y = jiggle }
        return point
    }
    
    internal var magnitude: CGFloat {
        return sqrt(x * x + y * y)
    }
}

@inline(__always)
internal func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint  {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

@inline(__always)
internal func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint  {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

@inline(__always)
internal func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint  {
    return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
}

@inline(__always)
internal func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint  {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

@inline(__always)
internal func += (lhs: inout CGPoint, rhs: CGPoint)  {
    lhs = lhs + rhs
}

@inline(__always)
internal func -= (lhs: inout CGPoint, rhs: CGPoint)  {
    lhs = lhs - rhs
}

@inline(__always)
internal func *= (lhs: inout CGPoint, rhs: CGFloat)  {
    lhs = lhs * rhs
}

@inline(__always)
internal func /= (lhs: inout CGPoint, rhs: CGFloat)  {
    lhs = lhs / rhs
}

extension Sequence where Iterator.Element == CGPoint {
    internal var boundingRect: CGRect? {
        let xValues = map({ $0.x })
        let yValues = map({ $0.y })
        guard let minX = xValues.min(),
            let minY = yValues.min(),
            let maxX = xValues.max(),
            let maxY = yValues.max() else { return nil }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
