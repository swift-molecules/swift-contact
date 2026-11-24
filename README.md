# swift-contact

Use this package when two things press into each other and the push grows with how far they press, as a fingertip on a string or a felt on a drumhead does. Start from `Contact`, a one-sided spring: no force until pressed, then F = F₀ (δ / δ₀)^α, with the energy it stores. F₀ is `push`, a `Force`, and δ₀ is `depth`, a length, so the law is typed whatever its exponent; a stiffness whose dimension depended on the exponent is what this replaces. For two elastic bodies, `Contact.hertz(radius:between:and:)` gives Hertz's contact from their `Contact.Elastic` moduli.

## Laws

- `force(pressed:)` is zero for no compression and `push × (compression / depth)^exponent` otherwise; `energy(pressed:)` is its integral, F₀ δ₀ (δ / δ₀)^(α + 1) / (α + 1), so the force is the slope of the stored energy.
- A `depth` that is a power of two of a metre (2⁻¹⁰ m is about a millimetre) scales a compression exactly, so such a contact rounds as `k × δ^α` with k = F₀ / δ₀^α does.
- Exponents 1, 1.5 and 2 take exact fast paths that give what the general power gives.
- `Contact.settle(from:toward:mass:every:…)` steps a point of a mass, pressed by a stored energy, one sample on, so that what the point loses the store gains exactly; strings use it. Places are lengths, the store's energy is an `Energy` and its slope a `Force`.
- The hot paths (`force`, `energy`, `settle`) are `@inlinable`: across modules without it, strings render about twice as slowly.
- `Contact.hertz` is Hertz's (1882) F = (4/3) E* √R δ^(3/2), with 1 / E* = (1 − ν₁²) / E₁ + (1 − ν₂²) / E₂ (Johnson 1985, eqs. 4.22–4.23), at a depth of 2⁻¹⁰ m. A steel ball dropped on glass reaches Hertz's deepest compression (15 m v² / (16 E* √R))^(2/5) to 10⁻⁴ and stays in contact his 2.94 δ* / v to 0.2%.
