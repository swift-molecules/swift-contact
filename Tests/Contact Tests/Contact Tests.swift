import Contact
import Testing

enum `Contact Tests` {}

extension `Contact Tests` {
    @Suite struct Law {}
}

extension `Contact Tests`.Law {
    @Test func `A contact of exponent one and a half gives what the general power gives`() {
        let fast = Contact(stiffness: 4e5, exponent: 1.5)
        let plain = Contact(stiffness: 4e5, exponent: 1.5000000000000002)
        for pressed in [1e-9, 3e-6, 2e-4, 0.0071] {
            #expect(abs(fast.force(pressed: pressed) / plain.force(pressed: pressed) - 1) < 1e-12)
            #expect(abs(fast.energy(pressed: pressed) / plain.energy(pressed: pressed) - 1) < 1e-12)
        }
    }
}
