import SwiftUI

extension Array {
    func index(for position: CGFloat, in width: CGFloat) -> Int {
        return self.index(forProgress: position / width)
    }

    func index(forProgress progress: CGFloat) -> Int {
        return Int(CGFloat(self.count) * progress).bound(by: self.indices)
    }

    func element(forProgress progress: CGFloat) -> Element {
        return self[index(forProgress: progress)]
    }

    func position(for index: Int, in width: CGFloat) -> CGFloat {
        return width * (CGFloat(index)/CGFloat(self.count)) + elementWidth(in: width) / 2
    }

    func progress(for index: Int, in width: CGFloat) -> CGFloat {
        return position(for: index, in: width) / width
    }

    func elementWidth(in width: CGFloat) -> CGFloat {
        return width / CGFloat(self.count)
    }

    func thumbOffset(for progress: CGFloat, in width: CGFloat) -> CGFloat {
        return (width * progress - elementWidth(in: width) / 2)
            .bound(by: 0..<(width - elementWidth(in: width)))
    }
}

extension FloatingPoint {
    func bound(by range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

extension Int {
    func bound(by range: Range<Self>) -> Self {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound - 1)
    }
}

extension Numeric where Self: Comparable {
    func bound(by range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }

    func bound(by range: Range<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
