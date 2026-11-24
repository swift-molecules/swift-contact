public import Numeric

/// A one-sided spring: no force until pressed, then `push × (pressed / depth)ᵉˣᵖᵒⁿᵉⁿᵗ`.
///
/// The law is F = F₀ (δ / δ₀)^α: `push` is the force F₀ at the compression `depth` δ₀, so both are typed whatever the
/// exponent. A `depth` that is a power of two of a metre scales the compression exactly.
public struct Contact: Hashable, Sendable {
    /// The force at a compression of `depth`.
    public var push: Force.Value<Double>
    /// The compression at which the force is `push`.
    public var depth: Length<Space.Physical, Double>
    /// How fast the force grows with compression: 1 for a linear spring, 1.5 for a Hertzian contact.
    public var exponent: Double

    public init(pushing push: Force.Value<Double>, at depth: Length<Space.Physical, Double>, exponent: Double = 1) {
        self.push = push
        self.depth = depth
        self.exponent = exponent
    }
}

extension Contact {
    /// The force at a compression; none while not pressed.
    @inlinable
    public func force(pressed compression: Length<Space.Physical, Double>) -> Force.Value<Double> {
        let pressed = compression.underlying / depth.underlying
        guard pressed > 0 else { return .zero }
        let push = push.underlying
        if exponent == 1 { return Force.newtons(push * pressed) }
        if exponent == 2 { return Force.newtons(push * pressed * pressed) }
        if exponent == 1.5 { return Force.newtons(push * pressed * pressed.squareRoot()) }
        return Force.newtons(push * Double.math.pow(pressed, exponent))
    }

    /// The energy stored at a compression, F₀ δ₀ (δ / δ₀)^(α + 1) / (α + 1); none while not pressed.
    @inlinable
    public func energy(pressed compression: Length<Space.Physical, Double>) -> Energy.Value<Double> {
        let pressed = compression.underlying / depth.underlying
        guard pressed > 0 else { return .zero }
        let work = push.underlying * depth.underlying
        if exponent == 1 { return Energy.joules(work * pressed * pressed / 2) }
        if exponent == 2 { return Energy.joules(work * pressed * pressed * pressed / 3) }
        if exponent == 1.5 { return Energy.joules(work / 2.5 * pressed * pressed * pressed.squareRoot()) }
        return Energy.joules(work / (exponent + 1) * Double.math.pow(pressed, exponent + 1))
    }

    /// Where a point ends up one step on, when it would coast to `free` and a stored energy pushes back.
    ///
    /// The push is the change of stored energy over the change of place across two steps, so what the point loses the
    /// store gains exactly. The point moves as `mass` and is stepped every `interval`; `slope` is the slope of the
    /// stored energy, the force the store pushes back with, reversed.
    @inlinable
    public static func settle(
        from last: Length<Space.Physical, Double>,
        toward free: Length<Space.Physical, Double>,
        mass: Mass.Value<Double>,
        every interval: Time.Duration.Value<Double>,
        energy: (Length<Space.Physical, Double>) -> Energy.Value<Double>,
        slope: (Length<Space.Physical, Double>) -> Force.Value<Double>
    ) -> Length<Space.Physical, Double> {
        Space.Physical.metres(
            settle(
                last.underlying,
                free.underlying,
                interval.underlying * interval.underlying / mass.underlying,
                { energy(Space.Physical.metres($0)).underlying },
                { slope(Space.Physical.metres($0)).underlying }
            )
        )
    }

    /// `settle` in metres, joules and newtons; `slack` is how far one newton moves the point in a step.
    @inlinable
    static func settle(
        _ last: Double,
        _ free: Double,
        _ slack: Double,
        _ energy: (Double) -> Double,
        _ slope: (Double) -> Double
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
