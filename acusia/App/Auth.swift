//
//  Auth.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//
import AuthenticationServices
import SwiftUI

struct AuthResponse: Codable {
    let token: String
    let user: User
}

class Auth: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    static let shared = Auth()

    @Published var isAuthenticated: Bool = false
    @Published var userProfile: User?
    @Published var debugInfo: String?

    override private init() {}

    // MARK: - Authentication State Management

    func authenticate() {
        guard let token = loadTokenFromKeychain() else {
            isAuthenticated = false
            return
        }

        guard let userId = decodeJWT(token) else {
            isAuthenticated = false
            return
        }

        isAuthenticated = true

        if let cachedProfile = FileCache.load(User.self, from: "\(userId)_profile.json") {
            userProfile = cachedProfile
        }
    }

    func signOut() {
        deleteTokenFromKeychain()

        if let userId = userProfile?.user_id {
            FileCache.delete("\(userId)_profile.json")
        }

        userProfile = nil
        isAuthenticated = false
    }

    // MARK: - Apple Sign-In

    func handleAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let identityToken = appleIDCredential.identityToken,
                  let authorizationCode = appleIDCredential.authorizationCode,
                  let idTokenString = String(data: identityToken, encoding: .utf8),
                  let authCodeString = String(data: authorizationCode, encoding: .utf8)
            else {
                debugInfo = "Failed to decode tokens."
                return
            }

            sendAuthRequest(idTokenString: idTokenString, authCodeString: authCodeString)
        }
    }

    private func sendAuthRequest(idTokenString: String, authCodeString: String) {
        guard let url = URL(string: "\(apiurl)/auth/apple") else {
            debugInfo = "Invalid backend URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "code": authCodeString
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            debugInfo = "Failed to encode request body: \(error.localizedDescription)"
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.debugInfo = "Error sending request: \(error.localizedDescription)"
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self?.debugInfo = "Invalid response from server."
                }
                return
            }

            guard httpResponse.statusCode == 200, let data = data else {
                DispatchQueue.main.async {
                    self?.debugInfo = "Server responded with status code: \(httpResponse.statusCode)"
                }
                return
            }

            do {
                let decoder = JSONDecoder()

                decoder.dateDecodingStrategy = .custom { decoder in
                    let dateString = try decoder.singleValueContainer().decode(String.self)
                    let iso8601Formatter = ISO8601DateFormatter()
                    iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    guard let date = iso8601Formatter.date(from: dateString) else {
                        throw DecodingError.dataCorrupted(DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Expected date string to be ISO8601-formatted with fractional seconds."
                        ))
                    }
                    return date
                }

                let authResponse = try decoder.decode(AuthResponse.self, from: data)

                saveTokenToKeychain(token: authResponse.token)

                if let userId = decodeJWT(authResponse.token) {
                    FileCache.save(authResponse.user, to: "\(userId)_profile.json")
                }

                DispatchQueue.main.async {
                    self?.debugInfo = "Authentication successful!"
                    self?.authenticate()
                }
            } catch {
                DispatchQueue.main.async {
                    self?.debugInfo = "Failed to decode response: \(error)"
                }
            }
        }
        
        task.resume()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        debugInfo = "Authorization failed: \(error.localizedDescription)"
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            fatalError("No window scene found.")
        }
        return window
    }
}
