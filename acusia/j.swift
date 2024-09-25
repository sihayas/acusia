//
//  j.swift
//  acusia
//
//  Created by decoherence on 9/24/24.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showSheet = false
    
    var body: some View {
        Button("Show Sheet") {
            self.showSheet = true
        }
        .sheet(isPresented: $showSheet) {
            SView()
        }
    }
}

struct SView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Button("Show Toast") {
                    ToastPresenter().show(toast: "This is a toast message")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemBlue.withAlphaComponent(0.3)))
                .navigationTitle("Sheet with Toast!")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .interactiveDismissDisabled()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


class ToastPresenter {
    private var toastWindow: UIWindow?
    
    func show(toast: String) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        toastWindow = UIWindow(windowScene: scene)
        toastWindow?.backgroundColor = .clear
        
        // Start with the window off-screen at the top
        toastWindow?.frame = CGRect(x: 50, y: -100, width: 300, height: 100)
        
        let view = Text(toast)
            .padding()
            .background(Color.red)
            .foregroundColor(Color.white)
            .cornerRadius(10)
        
        toastWindow?.rootViewController = UIHostingController(rootView: view)
        toastWindow?.rootViewController?.view.backgroundColor = .clear
        toastWindow?.makeKeyAndVisible()
        
        // Animate the window sliding down
        UIView.animate(withDuration: 0.5, animations: {
            self.toastWindow?.frame = CGRect(x: 50, y: 50, width: 300, height: 100)
        })
        
        // Hide the toast automatically after 2 seconds with slide up animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.5, animations: {
                self.toastWindow?.frame = CGRect(x: 50, y: -100, width: 300, height: 100)
            }) { _ in
                self.toastWindow?.isHidden = true
                self.toastWindow = nil
            }
        }
    }
}

#Preview {
    ContentView()
}
