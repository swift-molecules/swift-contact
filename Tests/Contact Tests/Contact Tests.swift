import Contact
import Testing

enum `Contact Tests` {}

extension `Contact Tests` {
    @Suite struct Law {}
}

extension `Contact Tests`.Law {
    static func metres(_ scalar: Double) -> Length<Space.Physical, Double> { Space.Physical.metres(scalar) }

    @Test func `A contact of exponent one and a half gives what the general power gives`() {
        let fast = Contact(pushing: Force.newtons(12.5), at: Self.metres(0.001), exponent: 1.5)
        let plain = Contact(pushing: Force.newtons(12.5), at: Self.metres(0.001), exponent: 1.5000000000000002)
        for pressed in [1e-9, 3e-6, 2e-4, 0.0071] {
            #expect(abs(fast.force(pressed: Self.metres(pressed)) / plain.force(pressed: Self.metres(pressed)) - 1) < 1e-12)
            #expect(abs(fast.energy(pressed: Self.metres(pressed)) / plain.energy(pressed: Self.metres(pressed)) - 1) < 1e-12)
        }
    }

    @Test(arguments: [1.0, 1.5, 2.0, 2.7])
    func `Pressed to its depth, a contact pushes with its push`(exponent: Double) {
        let contact = Contact(pushing: Force.newtons(8), at: Self.metres(0.002), exponent: exponent)
        #expect(abs(contact.force(pressed: Self.metres(0.002)) / Force.newtons(8) - 1) < 1e-12)
        #expect(contact.force(pressed: Self.metres(-0.001)) == .zero)
        #expect(contact.energy(pressed: .zero) == .zero)
    }

    @Test(arguments: [1.0, 1.5, 2.0, 2.7])
    func `The force is the slope of the stored energy`(exponent: Double) {
        let contact = Contact(pushing: Force.newtons(3), at: Self.metres(0.001), exponent: exponent)
        for pressed in [2e-4, 1e-3, 4e-3] {
            let step = pressed * 1e-6
            let slope =
                (contact.energy(pressed: Self.metres(pressed + step)) - contact.energy(pressed: Self.metres(pressed - step)))
                .underlying / (2 * step)
            #expect(abs(slope / contact.force(pressed: Self.metres(pressed)).underlying - 1) < 1e-8)
        }
    }

    @Test func `The law's dimensions balance: energy is force times length`() {
        #expect(Quantity.Dimension.of(Energy.self) == .of(Force.self) * .of(Measure<1, Space.Physical>.self))
    }

    @Test func `A point settling against a contact keeps the energy the contact stores`() {
        let contact = Contact(pushing: Force.newtons(12), at: Self.metres(0.001), exponent: 1.5)
        let last = Self.metres(0.0005)
        let mass = Mass.kilograms(0.002)
        let interval = Time.Duration.seconds(1e-4)
        let next = Contact.settle(
            from: last,
            toward: Self.metres(0.0015),
            mass: mass,
            every: interval,
            energy: { contact.energy(pressed: $0) },
            slope: { contact.force(pressed: $0) }
        )
        let slack = interval.underlying * interval.underlying / mass.underlying
        let pushed = (contact.energy(pressed: next) - contact.energy(pressed: last)).underlying / (next - last).underlying
        #expect(abs(next.underlying - 0.0015 + slack * pushed) < 1e-15)
        #expect(next < Self.metres(0.0015))
    }
}
