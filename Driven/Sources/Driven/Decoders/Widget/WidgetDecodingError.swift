extension WidgetDecoder {
    enum Error: String, Swift.Error {
        case mainBlockNotFound
        case declarationSyntaxNotFound
        case declarationReferenceNotFound
        case unsupportedArgumentKind
    }
}
