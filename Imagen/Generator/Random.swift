import UIKit


class Random {

    init(seed: Int) {
        state = WhyHash(seed: UInt64(truncatingIfNeeded: seed))
    }
    
    private var state: WhyHash

    func next() -> UInt64 {
        return state.next()
    }
}


extension Random {
    
    func inRange(_ range: ClosedRange<Int>) -> Int {
        return Int.random(in: range, using: &state)
    }
    
    func inRange(_ range: Range<Int>) -> Int {
        return Int.random(in: range, using: &state)
    }

    func color() -> UIColor {
        return UIColor.random(using: &state)
    }

    func happyColor() -> UIColor {
        return UIColor.randomBright(using: &state)
    }

    func rectInSize(_ size: CGSize) -> CGRect {
        let x = inRange(0..<Int(size.width))
        let y = inRange(0..<Int(size.height))
        let width = inRange(0..<Int(size.width - CGFloat(x)))
        let height = inRange(0..<Int(size.height - CGFloat(y)))
        return CGRect(x: x, y: y, width: width, height: height)
    }
}


private extension UIColor {
    
    static func random<R:RandomNumberGenerator>(using rng: inout R) -> UIColor {
        let h: CGFloat = .random(in: 0...1, using: &rng)
        let s: CGFloat = .random(in: 0.5...1, using: &rng)
        let b: CGFloat = .random(in: 0...1, using: &rng)
        return UIColor(hue: h, saturation: s, brightness: b, alpha: 1)
    }

    static func randomBright<R:RandomNumberGenerator>(using rng: inout R) -> UIColor {
        let h: CGFloat = .random(in: 0...1, using: &rng)
        let s: CGFloat = .random(in: 0.5...1, using: &rng)
        let b: CGFloat = .random(in: 0.8...1, using: &rng)
        return UIColor(hue: h, saturation: s, brightness: b, alpha: 1)
    }
}


private class WhyHash : RandomNumberGenerator {
    
    init(seed: UInt64) {
        state = seed
    }
    
    private var state: UInt64
    
    func next() -> UInt64 {
        state &+= 0xa0761d6478bd642f
        let x = state.multipliedFullWidth(by: state ^ 0xe7037ed1a0b428db)
        return x.high ^ x.low
    }
}
