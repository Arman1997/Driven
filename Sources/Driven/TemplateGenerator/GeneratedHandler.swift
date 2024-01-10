import Foundation
import Stencil

public struct GeneratedHandler {
    private let metadatas: [MetadataVariant]
    
    private func context() throws -> [String: Any] {
        let jsonData = try JSONEncoder().encode(metadatas)
        let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]]
        return [
            "metadatas": jsonDictionary as Any
        ]
    }
    
    public init(metadatas: [MetadataVariant]) {
        self.metadatas = metadatas
    }
    
    public func generate() throws -> String {
        let currentFilePath = #file
        // Derive the package directory from the current file's path
        let packageDirectory = URL(fileURLWithPath: currentFilePath)
            .deletingLastPathComponent()  // Remove the filename// Remove the directory containing the Swift file
            .path

        // Specify the relative path to the target directory within the package
        let targetDirectoryPath = "Templates/go"

        // Create the full path to the target directory
        let directoryPath = (packageDirectory as NSString).appendingPathComponent(targetDirectoryPath)
        
        let environment = Environment(loader: FileSystemLoader(paths: [.init(directoryPath)]))
    
        
        // Load the main template
        let template = try environment.loadTemplate(names: ["base.stencil"])
        
        print("\n\n\n\n")
        print(try context())
        print("\n\n\n\n")
        
        return try template.render(context())
    }
}
