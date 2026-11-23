public import Numeric

/// A one-sided spring: no force until pressed, then `stiffness × pressedᵉˣᵖᵒⁿᵉⁿᵗ`.
public struct Contact: Hashable, Sendable {
    public var stiffness: Double
    public var exponent: Double

    public init(stiffness: Double, exponent: Double = 1) {
        self.stiffness = stiffness
        self.exponent = exponent
    }
}

extension Contact {
    @inlinable
    public func force(pressed compression: Double) -> Double {
        guard compression > 0 else { return 0 }
        if exponent == 1 { return stiffness * compression }
        if exponent == 2 { return stiffness * compression * compression }
        if exponent == 1.5 { return stiffness * compression * compression.squareRoot() }
        return stiffness * Double.math.pow(compression, exponent)
    }

    @inlinable
    public func energy(pressed compression: Double) -> Double {
        guard compression > 0 else { return 0 }
        if exponent == 1 { return stiffness * compression * compression / 2 }
        if exponent == 2 { return stiffness * compression * compression * compression / 3 }
        if exponent == 1.5 { return stiffness / 2.5 * compression * compression * compression.squareRoot() }
        return stiffness / (exponent + 1) * Double.math.pow(compression, exponent + 1)
    }

    /// Where a point ends up one step on, when it would coast to `free` and a stored energy pushes back.
    ///
    /// The push is the change of stored energy over the change of place across two steps, so what the point loses the
    /// store gains exactly. `slack` is how far one unit of force moves the point in a step.
    @inlinable
    public static func settle(
        from last: Double,
        toward free: Double,
        slack: Double,
        energy: (Double) -> Double,
        slope: (Double) -> Double
    ) -> Double {
        let stored = energy(last)
        func miss(_ place: Double) -> Double {
            let change = place - last
            let mean =
                change.magnitude < 1e-12 ? slope(last + change / 2) : (energy(place) - stored) / change
            return place - free + slack * mean
        }
        let start = miss(free)
        guard start != 0 else { return free }
        var near = free
        var nearMiss = start
        var reach = Swift.max(start.magnitude, slack * slope(last).magnitude)
        var far = start > 0 ? free - reach : free + reach
        var farMiss = miss(far)
        var tries = 0
        while farMiss * start > 0, tries < 60 {
            reach *= 2
            far = start > 0 ? free - reach : free + reach
            farMiss = miss(far)
            tries += 1
        }
        guard farMiss != 0 else { return far }
        var count = 0
        while count < 100 {
            var place = (near * farMiss - far * nearMiss) / (farMiss - nearMiss)
            if !(place > Swift.min(near, far) && place < Swift.max(near, far)) {
                place = near + (far - near) / 2
            }
            if place == near || place == far { break }
            let missed = miss(place)
            if missed == 0 { return place }
            if missed * farMiss < 0 {
                near = far
                nearMiss = farMiss
            } else {
                nearMiss /= 2
            }
            far = place
            farMiss = missed
            count += 1
        }
        return farMiss.magnitude < nearMiss.magnitude ? far : near
    }
}
