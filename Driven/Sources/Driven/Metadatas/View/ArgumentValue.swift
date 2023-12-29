struct ArgumentValue {
    enum Kind {
        case int(Int)
        case string(String)
    }
    
    let kind: Kind
}

extension ArgumentValue : Equatable {}

extension ArgumentValue.Kind : Equatable {}
