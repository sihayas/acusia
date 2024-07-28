//
//  Auth.swift
//  acusia
//
//  Created by decoherence on 6/20/24.
//

import SwiftUI
import CoreData

class Auth: ObservableObject {
    @Published var session: Session?
    @Published var isAuthenticated = false
    @Published var user: APIUser?
    
    private let userAPI: UserAPI
    
    init(userAPI: UserAPI = UserAPI()) {
        self.userAPI = userAPI
    }
    
    @MainActor
    func initSession() async {
        await fetchSession()
        if isAuthenticated {
            await checkDeviceRegistration()
            await fetchAndSaveUserData()
        }
    }
    
    // Check if there is a session in CoreData
    @MainActor
    private func fetchSession() async {
        let fetchRequest: NSFetchRequest<Session> = Session.fetchRequest()
        do {
            let sessions = try CoreDataStack.shared.container.viewContext.fetch(fetchRequest)
            session = sessions.first
            
            isAuthenticated = session != nil &&
                              session?.sessionToken != nil &&
                              session?.authUserId != nil &&
                              session?.userId != nil
        } catch {
            print("Error fetching session: \(error.localizedDescription)")
            isAuthenticated = false
        }
    }
    
    private func checkDeviceRegistration() async {
        guard let session = session else { return }
        
        if let isDeviceRegistered = session.value(forKey: "isDeviceRegistered") as? Bool, !isDeviceRegistered {
            await registerForRemoteNotifications()
        } else {
            await registerForRemoteNotifications()
        }
    }
    
    @MainActor
    func fetchAndSaveUserData() async {
        guard let authUserID = session?.authUserId else { return }

        do {
            let userResponse = try await userAPI.fetchUserData(id: authUserID)
            let userData = userResponse.data
            
            // Update/create core data with the fetched user data
            let context = CoreDataStack.shared.container.viewContext
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", userData.id)
            let users = try context.fetch(fetchRequest)
            let user = users.first ?? User(context: context)
            
            user.username = userData.username
            user.bio = userData.bio
            user.image = userData.image
            user.followersCount = userData.followersCount
            user.artifactsCount = userData.artifactsCount
            
            try context.save()
            
            // Update the app state with the fetched user data
            self.user = userData
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }
    
    private func registerForRemoteNotifications() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } catch {
            print("Error requesting notification permissions: \(error.localizedDescription)")
        }
    }
    
    func handleDeviceToken(_ deviceToken: Data) {
        guard let session = session, let userId = session.userId else {
            print("Session not found")
            return
        }
        
        Task {
            do {
                try await userAPI.sendDeviceTokenToServer(data: deviceToken, userId: userId)
                
                if session.entity.properties.contains(where: { $0.name == "isDeviceRegistered" }) {
                    session.setValue(true, forKey: "isDeviceRegistered")
                    try CoreDataStack.shared.container.viewContext.save()
                }
            } catch {
                print("Error sending device token: \(error.localizedDescription)")
            }
        }
    }

}
