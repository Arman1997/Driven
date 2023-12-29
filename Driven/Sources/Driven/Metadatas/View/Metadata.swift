import Foundation

struct Metadata {
    enum Kind {
        case plain
        case builder(content: [Metadata])
    }
    
    let id: UUID = UUID()
    let token: String
    let kind: Kind
    let arguments: [Argument]
}

extension Metadata: Equatable, Identifiable {}

extension Metadata.Kind: Equatable {}
