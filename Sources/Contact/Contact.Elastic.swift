extension Contact {
    /// An elastic, isotropic body's stiffness as a contact sees it: its Young's modulus and Poisson's ratio.
    public struct Elastic: Hashable, Sendable {
        public var young: Modulus.Young.Value<Double>
        public var poisson: Poisson.Value<Double>

        public init(young: Modulus.Young.Value<Double>, poisson: Poisson.Value<Double>) {
            self.young = young
            self.poisson = poisson
        }
    }
}

extension Contact.Elastic {
    /// The contact modulus of this body pressed against `other`: 1 / E* = (1 − ν₁²) / E₁ + (1 − ν₂²) / E₂
    /// (Johnson 1985, *Contact Mechanics*, eq. 4.22).
    public func contact(with other: Self) -> Modulus.Young.Value<Double> {
        let a = (1 - poisson.underlying * poisson.underlying) / young.underlying
        let b = (1 - other.poisson.underlying * other.poisson.underlying) / other.young.underlying
        return Modulus.Young.pascals(1 / (a + b))
    }
}

extension Contact {
    /// Hertz's (1882) contact of two elastic bodies whose surfaces meet with relative radius `radius`
    /// (1 / R = 1 / R₁ + 1 / R₂; a sphere on a flat is its own radius): F = (4/3) E* √R δ^(3/2) (Johnson 1985, eq. 4.23).
    ///
    /// Its depth is 2⁻¹⁰ m, so a compression scales exactly, and its push is the Hertz force there.
    public static func hertz(radius: Length<Space.Physical, Double>, between first: Elastic, and second: Elastic) -> Self {
        let depth = 0x1p-10
        let modulus = first.contact(with: second).underlying
        let push = 4.0 / 3.0 * modulus * radius.underlying.squareRoot() * depth * depth.squareRoot()
        return Self(pushing: Force.newtons(push), at: Space.Physical.metres(depth), exponent: 1.5)
    }
}
