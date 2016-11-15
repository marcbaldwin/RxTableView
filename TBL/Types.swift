///
public enum When<T> {
    case always
    case `if`((T) -> Bool)
    case never
}

internal extension When {

    func evaluate(_ value: T) -> Bool {
        switch self {
        case .always: return true
        case .if(let handler): return handler(value)
        case .never: return false
        }
    }
}

enum Provider<T, I> {
    case `static`(T)
    case dynamic((I) -> T)

    func value(_ input: I) -> T {
        switch self {
        case .static(let value): return value
        case .dynamic(let provider): return provider(input)
        }
    }
}
