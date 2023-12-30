import Foundation

enum MetadataVariant {
    
    struct Metadata {
        
        struct Argument {
            
            enum Kind {
                case int(Int)
                case string(String)
            }
            
            let name: String
            let kind: Kind
        }
        
        let id: UUID = UUID()
        let token: String
        let arguments: [Argument]
    }

    struct BuilderMetadata {
        let metadata: Metadata
        let content: [MetadataVariant]
    }
    
    case plain(Metadata)
    case builder(BuilderMetadata)
}

extension MetadataVariant: Equatable, Identifiable, ProtobufMessageDecodable, ParameterizedComparable {

    var id: UUID {
        switch self {
        case .plain(let metadata):
            return metadata.id
        case .builder(let builderMetadata):
            return builderMetadata.id
        }
    }
    
    init(_ protoMessage: MetadataVariantMessage) throws {
        guard let variantKind = protoMessage.kind else {
            throw ProtobufMessageDecodingError.messageKindNotFound
        }
        
        switch variantKind {
        case .plain(let metadataMessage):
            self = .plain(try .init(metadataMessage))
        case .builder(let builderMetadataMessage):
            self = .builder(try .init(builderMetadataMessage))
        }
    }
    
    func parameterizedCompare(_ other: MetadataVariant) -> Bool {
        switch (self, other) {
        case (.plain(let metadata1), .plain(let metadata2)):
            return metadata1.parameterizedCompare(metadata2)

        case (.builder(let builder1), .builder(let builder2)):
            return builder1.parameterizedCompare(builder2)

        default:
            return false
        }
    }
}

extension MetadataVariant.Metadata: Equatable, Identifiable, ProtobufMessageDecodable, ParameterizedComparable {

    init(_ protoMessage: MetadataVariantMessage.Metadata) throws {
        self.token = protoMessage.token
        self.arguments = try protoMessage.arguments.map(Argument.init)
    }

    func parameterizedCompare(_ other: MetadataVariant.Metadata) -> Bool {
        return token == other.token &&
               arguments.parameterizedCompare(other.arguments)
    }
}

extension MetadataVariant.BuilderMetadata: Equatable, Identifiable, ProtobufMessageDecodable, ParameterizedComparable {

    var id: UUID {
        metadata.id
    }
    
    init(_ protobufMessage: MetadataVariantMessage.BuilderMetadata) throws {
        self.metadata = try MetadataVariant.Metadata(protobufMessage.metadata)
        self.content = try protobufMessage.content.map(MetadataVariant.init)
    }

    func parameterizedCompare(_ other: MetadataVariant.BuilderMetadata) -> Bool {
        return metadata.parameterizedCompare(other.metadata) &&
               content.parameterizedCompare(other.content)
    }
}

extension MetadataVariant.Metadata.Argument: Equatable, ProtobufMessageDecodable, ParameterizedComparable {

    init(_ protobufMessage: ArgumentMessage) throws {
        self.name = protobufMessage.name
        self.kind = try .init(protobufMessage.kind)
    }

    func parameterizedCompare(_ other: MetadataVariant.Metadata.Argument) -> Bool {
        return name == other.name && kind.parameterizedCompare(other.kind)
    }
}


extension MetadataVariant.Metadata.Argument.Kind: Equatable, ProtobufMessageDecodable, ParameterizedComparable {

    init(_ protobufMessage: ArgumentKindMessage) throws {
        switch protobufMessage.value {
        case .intValue(let val):
            self = .int(Int(val))
        case .stringValue(let val):
            self = .string(val)
        case .none:
            throw ProtobufMessageDecodingError.messageKindNotFound
        }
    }
    
    func parameterizedCompare(_ other: MetadataVariant.Metadata.Argument.Kind) -> Bool {
        switch (self, other) {
        case (.int(let value1), .int(let value2)):
            return value1 == value2

        case (.string(let value1), .string(let value2)):
            return value1 == value2

        default:
            return false
        }
    }

}
