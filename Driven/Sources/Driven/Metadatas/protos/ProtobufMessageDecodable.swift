import SwiftProtobuf

protocol ProtobufMessageDecodable {
    associatedtype MessageType: Message
    init(_ protoMessage: MessageType) throws
}
