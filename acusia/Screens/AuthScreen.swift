//
//  AuthScreen.swift
//  acusia
//
//  Created by decoherence on 6/12/24.
//

import AuthenticationServices
import SwiftUI

let apiurl = "http://127.0.0.1:3000"

struct AuthScreen: View {
    @EnvironmentObject var auth: Auth

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Button(action: {
                    auth.handleAppleSignIn()
                }) {
                    Image(systemName: "applelogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
    }
}
