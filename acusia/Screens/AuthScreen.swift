//
//  AuthScreen.swift
//  acusia
//
//  Created by decoherence on 6/12/24.
//

import SwiftUI
import AuthenticationServices

struct AuthScreen: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                
                Spacer()
                
                Button(action: {
                    viewModel.handleAppleSignIn()
                }) {
                    Image(systemName: "applelogo")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
                .frame(height: 64)
                .background(Color(hex: "#1C1C1E"))
                .cornerRadius(32)
                .padding(.bottom)
            }
        }
        .background(
            ZStack {
                Color.black
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 760, height: 760)
                    .offset(y: UIScreen.main.bounds.height / 2)
                    .blur(radius: 200)
            }
            .edgesIgnoringSafeArea(.all)
        )
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, primaryButton: alertItem.primaryButton, secondaryButton: alertItem.secondaryButton)
        }
    }
}

class AuthViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @Published var alertItem: AlertItem?
    
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
                  let authCodeString = String(data: authorizationCode, encoding: .utf8) else {
                print("Failed to decode identityToken or authorizationCode")
                return
            }
            
            
            let backendURL = URL(string: "\(apiurl)/_allauth/app/v1/auth/provider/token")!
            var request = URLRequest(url: backendURL)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let parameters: [String: Any] = [
                "provider": "apple",
                "process": "login",
                "token": [
                    "client_id": "space.voir.voir",
                    "id_token": idTokenString,
                    "code": authCodeString,
                ]
            ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                print("Request body: \(String(data: request.httpBody!, encoding: .utf8) ?? "Invalid body")")
            } catch {
                print("Error encoding parameters: \(error.localizedDescription)")
                return
            }
            
            // Send authentication request
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                self?.handleResponse(data: data, response: response, error: error)
            }
            task.resume()
        }
    }
    
    private func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            print("Error sending request to backend: \(error.localizedDescription)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response from backend")
            return
        }
        
        // Partial success, Apple Token authenticated, prompt for username
        if httpResponse.statusCode == 401 {
            DispatchQueue.main.async {
                print("Success, init sign up flow \(httpResponse.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseString)")
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let meta = json["meta"] as? [String: Any],
                       let sessionToken = meta["session_token"] as? String {
                        self.promptForUsername(sessionToken: sessionToken)
                    }
                }
            }
        // Success/User exists, store session in keychain
        } else if (200...299).contains(httpResponse.statusCode) {
            print("Success, signing user in: \(httpResponse.statusCode)")
            self.handleSuccessfulResponse(data: data)
        // Error/Failed to create a user
        } else {
            print("Backend returned an error: \(httpResponse.statusCode)")
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response body: \(responseString)")
            }
        }
    }
    
    private func handleSuccessfulResponse(data: Data?) {
        guard let data = data else {
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let data = json["data"] as? [String: Any],
               let userDict = data["user"] as? [String: Any],
               let meta = json["meta"] as? [String: Any],
               let sessionToken = meta["session_token"] as? String,
               let authUserId = userDict["id"] as? Int {
                print("Session Token: \(sessionToken), User Data: \(userDict)")
                
                DispatchQueue.main.async {
                    let session = Session(context: CoreDataStack.shared.container.viewContext)
                    session.sessionToken = sessionToken
                    session.authUserId = String(authUserId)
                    
                    try? CoreDataStack.shared.container.viewContext.save()
                    
                    NotificationCenter.default.post(name: .authenticationSucceeded, object: nil)
                }
            }
        } catch {
            print("Error parsing JSON response: \(error.localizedDescription)")
        }
    }
    
    private func promptForUsername(sessionToken: String) {
        alertItem = AlertItem(
            title: Text("Enter Username"),
            message: nil,
            primaryButton: .default(Text("Submit"), action: {
                if let username = self.alertItem?.textFields?.first?.text {
                    self.submitUsername(username: username, sessionToken: sessionToken)
                }
            }),
            secondaryButton: .cancel()
        )
    }
    
    private func submitUsername(username: String, sessionToken: String) {
        let signupURL = URL(string: "\(apiurl)/_allauth/app/v1/auth/provider/signup")!
        var request = URLRequest(url: signupURL)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(sessionToken, forHTTPHeaderField: "X-Session-Token")
        
        let parameters: [String: Any] = [
            "username": username
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error encoding parameters: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending request to backend: \(error.localizedDescription)")
                return
            }
            
            // Successfully created user
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Successfully created new user: \(responseString)")
                }
                return
            }
            
            self.handleSuccessfulResponse(data: data)
        }
        task.resume()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization failed: \(error.localizedDescription)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window scene found.")
        }
        return window
    }
}

struct AlertItem: Identifiable {
    var id = UUID()
    var title: Text
    var message: Text?
    var primaryButton: Alert.Button
    var secondaryButton: Alert.Button
    var textFields: [AlertTextField]?
}

struct AlertTextField {
    var placeholder: String
    var text: String = ""
}
