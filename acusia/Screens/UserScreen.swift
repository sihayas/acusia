import SwiftUI
import CoreData

struct UserScreen: View {
    @StateObject private var viewModel: UserViewModel
    @EnvironmentObject var sessionManager: Auth
    
    let initialUserData: APIUser?
    let userResult: UserResult?
    
    init(initialUserData: APIUser?, userResult: UserResult?) {
         self.initialUserData = initialUserData
         self.userResult = userResult
         self._viewModel = StateObject(wrappedValue: UserViewModel())
     }
    
    private var pageUserId: String {
         userResult?.id ?? initialUserData?.id ?? ""
     }

    var body: some View {
        ScrollView {
            VStack {
                // Essentials
                VStack(spacing: -40) {
                    ForEach(0..<3) { index in
                        let essential = viewModel.getEssential(at: index)
                        let centerXOffset: CGFloat = index % 2 == 0 ? 64 : -64
                        let rotationAngle: Double = index % 2 == 0 ? 4 : -4
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color(UIColor.systemGray6))
                                .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 4)
                            
                            if let artworkUrlString = essential?.artworkUrl,
                               let artworkUrl = URL(string: artworkUrlString.replacingOccurrences(of: "{w}", with: "300").replacingOccurrences(of: "{h}", with: "300")) {
                                AsyncImage(url: artworkUrl) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .cornerRadius(32)
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                        .frame(width: 200, height: 200)
                        .offset(x: centerXOffset)
                        .rotationEffect(.degrees(rotationAngle))
                    }
                }
                
                Spacer()
                
                ZStack {
                    if let imageURL = viewModel.userData?.image ?? initialUserData?.image {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ARTIFACT")
                                .font(.system(size: 13))
                                .foregroundColor(Color.secondary)
                            
                            Text(String(0))
                                .font(.system(size: 17, weight: .black))
                                .foregroundColor(Color.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SOUND")
                                .font(.system(size: 13))
                                .foregroundColor(Color.secondary)
                            
                            Text("0")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LINK")
                                .font(.system(size: 13))
                                .foregroundColor(Color.secondary)
                            
                            Text(String(0))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color.white)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                }
                
                FeedScreen(userId: sessionManager.session?.userId ?? "", pageUserId: pageUserId)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 56)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            if let userId = sessionManager.session?.userId {
                Task {
                    await viewModel.fetchUserData(userId: userId, pageUserId: pageUserId)
                }
            }
        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }
}

