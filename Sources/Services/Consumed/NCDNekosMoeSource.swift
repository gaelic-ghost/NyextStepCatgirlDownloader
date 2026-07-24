import Foundation

struct NCDNekosMoeSource {
    private struct Response: Decodable {
        let images: [Image]
    }

    private struct Image: Decodable {
        let id: String
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    private static func validate(_ response: URLResponse) throws {
        guard let response = response as? HTTPURLResponse else {
            throw NCDNekosMoeError.invalidResponse
        }
        guard (200...299).contains(response.statusCode) else {
            throw NCDNekosMoeError.httpStatus(response.statusCode)
        }
    }

    func loadImage() async throws -> NCDImage {
        let endpoint = URL(string: "https://nekos.moe/api/v1/random/image?nsfw=false")!
        let (metadataData, metadataResponse) = try await session.data(from: endpoint)
        try NCDNekosMoeSource.validate(metadataResponse)

        let metadata = try JSONDecoder().decode(Response.self, from: metadataData)
        guard let identifier = metadata.images.first?.id,
              let imageURL = URL(string: "https://nekos.moe/image/\(identifier)") else {
            throw NCDNekosMoeError.missingImage
        }

        let (imageData, imageResponse) = try await session.data(from: imageURL)
        try NCDNekosMoeSource.validate(imageResponse)
        guard !imageData.isEmpty else {
            throw NCDNekosMoeError.emptyImage
        }

        return NCDImage(data: imageData, sourceURL: URL(string: "https://nekos.moe/post/\(identifier)")!, suggestedFilename: "nekos.moe_\(identifier).jpg")
    }
}

enum NCDNekosMoeError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case missingImage
    case emptyImage

    var errorDescription: String? {
        switch self {
            case .invalidResponse:
                "NekosMoe returned a response that macOS could not interpret. Check your network connection and try reloading the image."
            case let .httpStatus(statusCode):
                "NekosMoe could not provide an image (HTTP \(statusCode)). Try reloading in a moment."
            case .missingImage:
                "NekosMoe responded successfully but did not include an image identifier. Try reloading the image."
            case .emptyImage:
                "NekosMoe returned an empty image file. Try reloading the image."
        }
    }
}
