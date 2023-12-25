import Foundation

protocol Comparable {
    func compare(to other: Self) -> Bool
}

extension Array: Comparable where Element: WidgetDeclaration {
    func compare(to other: Array<Element>) -> Bool {
        var firstIterator = makeIterator()
        var secondIterator = other.makeIterator()
        
        while let firstArr = firstIterator.next(), 
              let secondArr = secondIterator.next() {
            
            if !firstArr.compare(to: secondArr) {
                return false
            }
        }
        
        return true
    }
}
