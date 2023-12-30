import SwiftSyntax
import SwiftParser

protocol WidgetMetadataDecoding {
    func decode(from code: String) throws -> MetadataVariant
}

struct WidgetMetadataDecoder: WidgetMetadataDecoding {
    func decode(from code: String) throws -> MetadataVariant {
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
    
    func widgetDeclaration(from declarationSyntax: FunctionCallExprSyntax) throws -> MetadataVariant {
        guard let declarationParts = declarationSyntax
            .calledExpression
            .as(DeclReferenceExprSyntax.self)
        else {
            throw Error.declarationReferenceNotFound
        }
        
        let metadata = MetadataVariant.Metadata(
            token: token(from: declarationParts),
            arguments: try arguments(from: declarationSyntax.arguments)
        )
        
        if let closureExpr = declarationSyntax.trailingClosure {
            return .builder(
                .init(
                    metadata: metadata,
                    content: try findComponents(in: closureExpr)
                )
            )
        } else {
            return .plain(metadata)
        }
    }
    
    func token(from syntax: DeclReferenceExprSyntax) -> String {
        syntax.baseName.text
    }
    
    func arguments(from syntax: LabeledExprListSyntax) throws -> [MetadataVariant.Metadata.Argument] {
        try Array(syntax).map { argumentNode in
            MetadataVariant.Metadata.Argument(
                name: name(of: argumentNode),
                kind: try kind(of: argumentNode)
            )
        }
    }
    
    func name(of argument: LabeledExprSyntax) -> String {
        argument.label?.text ?? ""
    }
    
    func kind(of argument: LabeledExprSyntax) throws -> MetadataVariant.Metadata.Argument.Kind {
        if let intLiteral = argument.expression.as(IntegerLiteralExprSyntax.self) {
            return  .int(
                Int(intLiteral.literal.text)!
            )
        } else if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
            return .string(
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
        }
        
        throw Error.unsupportedArgumentKind
    }
    
    func findComponents(in closureSyntax: ClosureExprSyntax) throws -> [MetadataVariant] {
        try items(of: closureSyntax.statements).map { codeBlock in
            try widgetDeclaration(
                from: try declarationSyntax(
                    in: codeBlock
                )
            )
        }
    }
    
}
