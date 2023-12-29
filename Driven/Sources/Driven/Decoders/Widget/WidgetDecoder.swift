import SwiftSyntax
import SwiftParser

protocol WidgetMetadataDecoding {
    func decode(from code: String) throws -> Metadata
}

struct WidgetMetadataDecoder: WidgetMetadataDecoding {
    func decode(from code: String) throws -> Metadata {
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

extension WidgetMetadataDecoder{
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
    
    func widgetDeclaration(from declarationSyntax: FunctionCallExprSyntax) throws -> Metadata {
        guard let declarationParts = declarationSyntax
            .calledExpression
            .as(DeclReferenceExprSyntax.self)
        else {
            throw Error.declarationReferenceNotFound
        }
        
        let metadataKind: Metadata.Kind = try {
            if let closureExpr = declarationSyntax.trailingClosure {
                return .builder(content: try findComponents(in: closureExpr))
            }
            
            return .plain
        }()
        
        return Metadata(
            token: token(from: declarationParts),
            kind: metadataKind,
            arguments: try arguments(from: declarationSyntax.arguments)
        )
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
    
    func findComponents(in closureSyntax: ClosureExprSyntax) throws -> [Metadata] {
        try items(of: closureSyntax.statements).map { codeBlock in
            try widgetDeclaration(
                from: try declarationSyntax(
                    in: codeBlock
                )
            )
        }
    }
    
}
