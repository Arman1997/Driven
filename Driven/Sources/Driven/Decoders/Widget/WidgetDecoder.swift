import SwiftSyntax
import SwiftParser

protocol WidgetDecoding {
    func decode(from code: String) throws -> WidgetDeclaration
}

struct WidgetDecoder: WidgetDecoding {
    func decode(from code: String) throws -> WidgetDeclaration {
        try widgetDeclaration(
            from: try declarationSyntax(
                in: try mainCodeBlock(
                    of: sourceFileSyntax(
                        of: code
                    )
                )
            )
        )
    }
}

extension WidgetDecoder{
    func sourceFileSyntax(of code: String) -> SourceFileSyntax {
        Parser.parse(source: code)
    }
    
    func mainCodeBlock(of sourceFileSyntax: SourceFileSyntax) throws -> CodeBlockItemSyntax {
        guard let mainBlock = sourceFileSyntax
            .statements
            .first?
            .as(CodeBlockItemSyntax.self)
        else {
            throw Error.mainBlockNotFound
        }
        
        return mainBlock
    }
    
    func items(of codeBlockList: CodeBlockItemListSyntax) -> [CodeBlockItemSyntax] {
        Array(codeBlockList)
    }
    
    func declarationSyntax(in codeBlock: CodeBlockItemSyntax) throws -> FunctionCallExprSyntax {
        guard let funcCallSyntax = codeBlock
            .item
            .as(FunctionCallExprSyntax.self)
        else {
            throw Error.declarationSyntaxNotFound
        }
        
        return funcCallSyntax
    }
    
    func widgetDeclaration(from declarationSyntax: FunctionCallExprSyntax) throws -> WidgetDeclaration {
        guard let declarationParts = declarationSyntax
            .calledExpression
            .as(DeclReferenceExprSyntax.self)
        else {
            throw Error.declarationReferenceNotFound
        }
        
        if let closureExpr = declarationSyntax.trailingClosure {
            return WidgetComposition(
                metadata: WidgetComposition.Metadata(
                    declarationMetadata: WidgetDeclaration.Metadata(
                        token: token(from: declarationParts),
                        directArguments: try arguments(from: declarationSyntax.arguments)
                    ),
                    components: try findComponents(in: closureExpr)
                )
            )
        } else {
            return WidgetDeclaration(
                metadata: WidgetDeclaration.Metadata(
                    token: token(from: declarationParts),
                    directArguments: try arguments(from: declarationSyntax.arguments)
                )
            )
        }
    }
    
    func token(from syntax: DeclReferenceExprSyntax) -> String {
        syntax.baseName.text
    }
    
    func arguments(from syntax: LabeledExprListSyntax) throws -> [Argument] {
        try Array(syntax).map { argumentNode in
            Argument(
                name: name(of: argumentNode),
                value: try value(of: argumentNode)
            )
        }
    }
    
    func name(of argument: LabeledExprSyntax) -> String {
        argument.label?.text ?? ""
    }
    
    func value(of argument: LabeledExprSyntax) throws -> ArgumentValue {
        if let intLiteral = argument.expression.as(IntegerLiteralExprSyntax.self) {
            return .init(
                kind: .int(
                    Int(intLiteral.literal.text)!
                )
            )
        } else if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
            return .init(
                kind: .string(
                    Array(
                        stringLiteral.segments
                    )
                    .compactMap {
                        $0.as(StringSegmentSyntax.self)
                    }
                    .map {
                        $0.content.text
                    }
                    .joined()
                )
            )
        }
        
        throw Error.unsupportedArgumentKind
    }
    
    func findComponents(in closureSyntax: ClosureExprSyntax) throws -> [WidgetDeclaration] {
        try items(of: closureSyntax.statements).map { codeBlock in
            try widgetDeclaration(
                from: try declarationSyntax(
                    in: codeBlock
                )
            )
        }
    }
    
}
