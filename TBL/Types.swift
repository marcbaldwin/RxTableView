///
public enum When<T> {
    case Always
    case If(T -> Bool)
    case Never
}

internal extension When {

    func evaluate(value: T) -> Bool {
        switch self {
        case .Always: return true
        case .If(let handler): return handler(value)
        case .Never: return false
        }
    }
}

enum Provider<T, I> {
    case Static(T)
    case Dynamic(I -> T)

    func value(input: I) -> T {
        switch self {
        case .Static(let value): return value
        case .Dynamic(let provider): return provider(input)
        }
    }
}