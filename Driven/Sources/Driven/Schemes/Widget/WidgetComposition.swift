import Foundation

class WidgetComposition: WidgetDeclaration {
    struct Metadata {
        let declarationMetadata: WidgetDeclaration.Metadata
        let components: [WidgetDeclaration]
    }

    private let metadata: Metadata
    
    init(metadata: Metadata) {
        self.metadata = metadata
        super.init(metadata: metadata.declarationMetadata)
    }

    override func compare(to other: WidgetDeclaration) -> Bool {
        guard let otherComposition = other as? WidgetComposition else {
            return false
        }
        
        return metadata.declarationMetadata == otherComposition.metadata.declarationMetadata &&
        metadata.components.compare(to: otherComposition.metadata.components)
    }
}


extension WidgetComposition.Metadata: Equatable {}
