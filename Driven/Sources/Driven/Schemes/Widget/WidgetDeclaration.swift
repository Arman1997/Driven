import Foundation

class WidgetDeclaration {
    struct Metadata {
        let token: String
        let directArguments: [Argument]
    }
    
    private let metadata: Metadata
    public let id: UUID
    
    init(id: UUID = UUID(), metadata: Metadata) {
        self.metadata = metadata
        self.id = id
    }
    
    func compare(to other: WidgetDeclaration) -> Bool {
        self.metadata == other.metadata
    }
}

extension WidgetDeclaration : Equatable {
    public static func == (
        lhs: WidgetDeclaration,
        rhs: WidgetDeclaration
    ) -> Bool {
        lhs.id == rhs.id
    }
}

extension WidgetDeclaration: Identifiable {}

extension WidgetDeclaration: Comparable {}

extension WidgetDeclaration.Metadata: Equatable {}
