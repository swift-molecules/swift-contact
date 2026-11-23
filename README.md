# swift-contact

Use this package when two things press into each other and the push grows with how far they press, as a fingertip on a string or a felt on a drumhead does. Start from `Contact`, a one-sided spring: no force until pressed, then `stiffness × pressed^exponent`, with the energy it stores.

## Laws

- `force(pressed:)` is zero for no compression and `stiffness × compression^exponent` otherwise; `energy(pressed:)` is its integral, so the force is the slope of the stored energy.
- Exponents 1, 1.5 and 2 take exact fast paths that give what the general power gives.
- `Contact.settle(from:toward:…)` steps a point pressed by a contact one sample on, so that what the point loses the contact stores exactly; strings and strikers use it.
