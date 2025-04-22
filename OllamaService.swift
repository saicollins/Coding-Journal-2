import Foundation

class OllamaService {
    private let baseURL = "http://localhost:11434/api/generate"
    
    func sendMessage(prompt: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            print("Error: Invalid URL")
            throw OllamaError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "mistral",
            "prompt": prompt,
            "stream": false
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error serializing request body: \(error)")
            throw OllamaError.decodingError
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid HTTP response")
                throw OllamaError.invalidResponse
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error response: \(errorString)")
                }
                throw OllamaError.invalidResponse
            }
            
            do {
                let result = try JSONDecoder().decode(OllamaResponse.self, from: data)
                return result.response
            } catch {
                print("Error decoding response: \(error)")
                throw OllamaError.decodingError
            }
        } catch {
            print("Network error: \(error)")
            throw error
        }
    }
}

struct OllamaResponse: Codable {
    let response: String
}

enum OllamaError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from Ollama"
        case .decodingError:
            return "Failed to decode response"
        }
    }
} 