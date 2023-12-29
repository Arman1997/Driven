import XCTest
@testable import Driven

final class WidgetDecoderTests: XCTestCase {
    private let sut: WidgetMetadataDecoding = WidgetMetadataDecoder()
    
    func test_GivenSourceCode_WhenDecode_ThenExpectedWidget() throws {
        XCTAssertTrue(
            compare(
            try generatedOutput(
                for: .text("Some")
            ), Metadata(
                token: "Text",
                kind: .plain,
                arguments: [
                    .init(
                        name: "",
                        value: .init(kind: .string("Some"))
                    )
                ]
            ))
        )
    }
}

private extension WidgetDecoderTests {
    
    func generatedOutput(for codeExample: SourceCodeExamples) throws -> Metadata {
        try sut.decode(from: codeExample.description)
    }
    
    enum SourceCodeExamples: CustomStringConvertible {
        case text(_ arguments: String)
        case vStack(_ content: String)
        
        var description: String {
            switch self {
            case .text(let arguments):
                return "Text(\"\(arguments)\")"
            case .vStack(let content):
                return """
                VStack {
                    \(content)
                }
                """
            }
        }
    }
    
    func compare(_ lhs: Metadata, _ rhs: Metadata) -> Bool {
        return lhs.kind == rhs.kind &&
        lhs.token == rhs.token &&
        lhs.arguments == rhs.arguments
    }
}
