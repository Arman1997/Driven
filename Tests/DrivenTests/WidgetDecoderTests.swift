import XCTest
@testable import Driven

final class WidgetDecoderTests: XCTestCase {
    private let sut: WidgetMetadataDecoding = WidgetMetadataDecoder()
    
    func test_GivenSourceCode_WhenDecode_ThenExpectedWidget() throws {
        XCTAssert(
            try generatedOutput(
                for: .text("Some")
            )
            .parameterizedCompare(
                MetadataVariant.plain(
                    .init(
                        token: "Text",
                        arguments: [
                            .init(
                                name: "",
                                kind: .string("Some")
                            )
                        ]
                    )
                )
            )
        )
    }
}

private extension WidgetDecoderTests {
    
    func generatedOutput(for codeExample: SourceCodeExamples) throws -> MetadataVariant {
       let variant =  try sut.decode(from: codeExample.description)
        print(variant)
        return variant
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
}
