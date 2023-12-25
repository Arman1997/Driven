import XCTest
@testable import Driven

final class WidgetDecoderTests: XCTestCase {
    private let sut: WidgetDecoding = WidgetDecoder()
    
    func test_GivenSourceCode_WhenDecode_ThenExpectedWidget() throws {
        XCTAssertTrue(
            try generatedOutput(
                for: .text("Some")
            )
            .compare(
                to: .init(
                    metadata: .init(
                        token: "Text",
                        directArguments: [
                            .init(
                                name: "",
                                value: .init(
                                    kind: .string("Some")
                                )
                            )
                        ]
                    )
                )
            )
        )
    }
}

private extension WidgetDecoderTests {
    
    func generatedOutput(for codeExample: SourceCodeExamples) throws -> WidgetDeclaration {
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
}
