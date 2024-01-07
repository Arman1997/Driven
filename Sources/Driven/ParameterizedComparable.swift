protocol ParameterizedComparable {
    func parameterizedCompare(_ other: Self) -> Bool
}

extension Array: ParameterizedComparable where Element: ParameterizedComparable {
    func parameterizedCompare(_ other: Array<Element>) -> Bool {
        guard self.count == other.count else {
            return false
        }
        
        return !zip(self, other)
            .map { $0.0.parameterizedCompare($0.1) }
            .contains(false)
    }
}
