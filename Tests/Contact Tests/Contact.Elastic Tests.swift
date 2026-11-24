import Contact
import Numeric
import Testing

@Suite struct `Contact.Elastic Tests` {
    let steel = Contact.Elastic(young: Modulus.Young.pascals(210e9), poisson: Poisson.amount(0.3))
    let glass = Contact.Elastic(young: Modulus.Young.pascals(72e9), poisson: Poisson.amount(0.22))

    @Test func `the contact modulus adds the two compliances`() {
        let expected = 1 / ((1 - 0.09) / 210e9 + (1 - 0.0484) / 72e9)
        #expect(abs(steel.contact(with: glass).underlying / expected - 1) < 1e-12)
        #expect(steel.contact(with: glass) == glass.contact(with: steel))
    }

    @Test func `Hertz's force is four thirds E* √R δ^(3/2)`() {
        let contact = Contact.hertz(radius: Space.Physical.metres(0.01), between: steel, and: glass)
        let modulus = steel.contact(with: glass).underlying
        for delta in [1e-7, 3e-6, 2e-5] {
            let expected = 4.0 / 3.0 * modulus * 0.01.squareRoot() * delta * delta.squareRoot()
            #expect(abs(contact.force(pressed: Space.Physical.metres(delta)).underlying / expected - 1) < 1e-12)
        }
    }

    @Test func `a ball dropped on a flat stays in contact Hertz's 2.94 δ* / v`() {
        // Johnson (1985, §11.4): δ* = (15 m v² / (16 E* √R))^(2/5), and the impact lasts 2.94 δ* / v.
        let radius = 0.01
        let mass = 7850 * 4.0 / 3.0 * Double.pi * radius * radius * radius
        let speed = 1.0
        let contact = Contact.hertz(radius: Space.Physical.metres(radius), between: steel, and: glass)
        let modulus = steel.contact(with: glass).underlying
        let deepest = Double.math.pow(15 * mass * speed * speed / (16 * modulus * radius.squareRoot()), 0.4)
        let step = 1e-9
        var delta = 0.0
        var velocity = speed
        var time = 0.0
        var reached = 0.0
        repeat {
            velocity -= contact.force(pressed: Space.Physical.metres(delta)).underlying / mass * step / 2
            delta += velocity * step
            velocity -= contact.force(pressed: Space.Physical.metres(delta)).underlying / mass * step / 2
            time += step
            reached = Swift.max(reached, delta)
        } while delta > 0
        #expect(abs(reached / deepest - 1) < 1e-4)
        #expect(abs(time / (2.94 * deepest / speed) - 1) < 2e-3)
    }
}
