//
//  CreateSheet.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//
import SwiftUI

struct CreateSheet: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: UIState
    @EnvironmentObject private var musicKitManager: MusicKit

    @State private var users: [UserDev] = userDevs

    @State private var count = 4
    @State private var limitedRead = false
    @State private var closedWrite = false

    @State private var messageNotifications = false
    @State private var requestNotifications = false
    @State private var mentionNotifications = false

    var body: some View {
        List { /// List is a ScrollView.
            CollageLayout {
                ForEach(0 ..< count, id: \.self) { _ in
                    Circle()
                        .fill(.black)
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.width * 0.7)
            .padding(.horizontal, 24)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 4)
            .listRowBackground(
                Rectangle()
                    .foregroundStyle(.clear)
                    .background(.clear)
            )

            // Stepper("Count: \(count)", value: $count.animation(), in: 1 ... 10)
            //     .padding()

            // MARK: - User Management

            Section {
                // MARK: - Active
                HStack {
                    Image(systemName: "chevron.up.dotted.2")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                    
                    Menu {
                        ControlGroup {
                            Button {} label: {
                                Label("Add Users", systemImage: "person.crop.circle.fill.badge.plus")
                            }
                        }

                        ForEach(users, id: \.id) { user in
                            /// Create a sub menu for each user.
                            Menu {
                                ControlGroup {
                                    Button {
                                        print("View Profile for User: \(user.alias)")
                                    } label: {
                                        Label("Expand Profile", systemImage: "person.and.background.dotted")
                                    }

                                    Button {
                                        print("Send request to User: \(user.alias)")
                                    } label: {
                                        Label("Request Friend", systemImage: "person.line.dotted.person.fill")
                                    }
                                }

                                Menu {
                                    Button {} label: {
                                        Label("Remove", systemImage: "figure.kickboxing")
                                    }

                                    Button(role: .destructive) {
                                        if let index = users.firstIndex(where: { $0.id == user.id }) {
                                            users.remove(at: index)
                                        }
                                    } label: {
                                        Label("Block", systemImage: "hand.raised.slash.fill")
                                    }
                                } label: {
                                    Label {
                                        Text("Destructive")

                                    } icon: {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundStyle(.white, .white, .yellow)
                                    }
                                }
                            } label: {
                                Label {
                                    Text(user.alias)
                                } icon: {
                                    AsyncImage(url: URL(string: user.imageUrl)) { image in
                                        let size = CGSize(width: 40, height: 40)
                                        Image(size: size) { gc in
                                            gc.clip(to: Path(ellipseIn: .init(origin: .zero, size: size)))
                                            gc.draw(image, in: .init(origin: .zero, size: size))
                                        }
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                .accentColor(.white)

                                Text("Online")
                            }
                            .menuActionDismissBehavior(.disabled)
                        }
                    } label: {
                        Label {
                            Text("Core")
                                .font(.body)
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "point.3.filled.connected.trianglepath.dotted")
                        }
                        .accentColor(.white)
                    }
                    .menuOrder(.priority)

                    Spacer()

                    Text("8 / 32")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // MARK: - Permitted
                HStack {
                    Image(systemName: "chevron.up.dotted.2")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                    
                    Menu {
                        ControlGroup {
                            Button {} label: {
                                Label("Add Users", systemImage: "person.crop.circle.fill.badge.plus")
                            }
                        }

                        ForEach(users, id: \.id) { user in
                            /// Create a sub menu for each user.
                            Menu {
                                ControlGroup {
                                    Button {
                                        print("View Profile for User: \(user.alias)")
                                    } label: {
                                        Label("Expand Profile", systemImage: "person.and.background.dotted")
                                    }

                                    Button {
                                        print("Send request to User: \(user.alias)")
                                    } label: {
                                        Label("Request Friend", systemImage: "person.line.dotted.person.fill")
                                    }
                                }

                                Menu {
                                    Button {} label: {
                                        Label("Remove", systemImage: "figure.kickboxing")
                                    }

                                    Button(role: .destructive) {
                                        if let index = users.firstIndex(where: { $0.id == user.id }) {
                                            users.remove(at: index)
                                        }
                                    } label: {
                                        Label("Block", systemImage: "hand.raised.slash.fill")
                                    }
                                } label: {
                                    Label {
                                        Text("Destructive")

                                    } icon: {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundStyle(.white, .white, .yellow)
                                    }
                                }
                            } label: {
                                Label {
                                    Text(user.alias)
                                } icon: {
                                    AsyncImage(url: URL(string: user.imageUrl)) { image in
                                        let size = CGSize(width: 40, height: 40)
                                        Image(size: size) { gc in
                                            gc.clip(to: Path(ellipseIn: .init(origin: .zero, size: size)))
                                            gc.draw(image, in: .init(origin: .zero, size: size))
                                        }
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                .accentColor(.white)

                                Text("Online")
                            }
                            .menuActionDismissBehavior(.disabled)
                        }
                    } label: { // a core user has blocked this user. to allow them to interact with the biome, they must be unblocked.
                        Label {
                            Text("Peripheral")
                                .font(.body)
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "point.3.connected.trianglepath.dotted")
                        }
                        .accentColor(.white)
                    }
                    .menuOrder(.priority)

                    Spacer()

                    Text("832")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // MARK: - Blocked
                HStack {
                    Image(systemName: "chevron.up.dotted.2")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                    
                    Menu {
                        ControlGroup {
                            Button {} label: {
                                Label("Add Users", systemImage: "person.crop.circle.fill.badge.plus")
                            }
                        }

                        ForEach(users, id: \.id) { user in
                            /// Create a sub menu for each user.
                            Menu {
                                ControlGroup {
                                    Button {
                                        print("View Profile for User: \(user.alias)")
                                    } label: {
                                        Label("Expand Profile", systemImage: "person.and.background.dotted")
                                    }

                                    Button {
                                        print("Send request to User: \(user.alias)")
                                    } label: {
                                        Label("Request Friend", systemImage: "person.line.dotted.person.fill")
                                    }
                                }

                                Menu {
                                    Button {} label: {
                                        Label("Remove", systemImage: "figure.kickboxing")
                                    }

                                    Button(role: .destructive) {
                                        if let index = users.firstIndex(where: { $0.id == user.id }) {
                                            users.remove(at: index)
                                        }
                                    } label: {
                                        Label("Block", systemImage: "hand.raised.slash.fill")
                                    }
                                } label: {
                                    Label {
                                        Text("Destructive")

                                    } icon: {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundStyle(.white, .white, .yellow)
                                    }
                                }
                            } label: {
                                Label {
                                    Text(user.alias)
                                } icon: {
                                    AsyncImage(url: URL(string: user.imageUrl)) { image in
                                        let size = CGSize(width: 40, height: 40)
                                        Image(size: size) { gc in
                                            gc.clip(to: Path(ellipseIn: .init(origin: .zero, size: size)))
                                            gc.draw(image, in: .init(origin: .zero, size: size))
                                        }
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                .accentColor(.white)

                                Text("Online")
                            }
                            .menuActionDismissBehavior(.disabled)
                        }
                    } label: {
                        Label {
                            Text("Blocked")
                                .font(.body)
                                .foregroundColor(.red)
                        } icon: {
                            Image(systemName: "point.3.connected.trianglepath.dotted")
                        }
                        .accentColor(.red)
                    }
                    .menuOrder(.priority)

                    Spacer()

                    Text("5")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            } header: {
                Text("Users")
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            } footer: {
                Text("Blocked users will not be able to view or interact with this Biome in any capacity.")
            }

            // MARK: - Biome Type

            Section {
                Toggle(isOn: $limitedRead) {
                    Label("Limited Read", systemImage: limitedRead ? "circle.dotted.circle" : "circle.dotted")
                        .accentColor(.white)
                }
                .tint(.white)
                .contentTransition(.symbolEffect(.replace))
            } header: {
                Text("Biome")
                    .fontWeight(.semibold)
                    .foregroundStyle(.yellow)
            } footer: {
                Text("Non-native users can only read and react to the most recent messages. However, Biome highlights will still appear in their feed.")
            }

            Section {
                Toggle(isOn: $closedWrite) {
                    Label("Closed Write", systemImage: closedWrite ? "lock.circle.dotted" : "circle.dotted")
                        .accentColor(.white)
                }
                .tint(.white)
                .contentTransition(.symbolEffect(.replace))
            } footer: {
                Text("Non-native users are restricted from submitting message requests.")
            }

            // MARK: - Alerts

            Section {
                Toggle(isOn: $messageNotifications) {
                    Label("Messages", systemImage: "message.badge.filled.fill")
                        .accentColor(.white)
                }
                .tint(.white)
                .contentTransition(.symbolEffect(.replace))

                Toggle(isOn: $requestNotifications) {
                    Label("Requests", systemImage: "plus.message.fill")
                        .accentColor(.white)
                }
                .tint(.white)
                .contentTransition(.symbolEffect(.replace))

                Toggle(isOn: $mentionNotifications) {
                    Label("Mentions", systemImage: "at")
                        .accentColor(.white)
                }
                .tint(.white)
                .contentTransition(.symbolEffect(.replace))
            } header: {
                Text("Alerts")
                    .fontWeight(.semibold)
                    .foregroundStyle(.yellow)
            } footer: {
                Text("")
            }
        }
        .scrollContentBackground(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            HStack {
                Text("Biome")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 32)
            .frame(height: safeAreaInsets.top * 1.5)
        }
    }
}
