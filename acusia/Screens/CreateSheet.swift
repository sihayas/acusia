//
//  CreateSheet.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//
import SwiftUI

enum Topping: String, CaseIterable, Identifiable {
    case pepperoni, mushrooms, extraCheese, olives
    var id: String { self.rawValue }
}

struct CreateSheet: View {
    @EnvironmentObject private var windowState: UIState
    @EnvironmentObject private var musicKitManager: MusicKit
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @State private var users: [UserDev] = userDevs

    @State private var biomeName: String = ""
    @State private var messageNotifications = false
    @State private var requestNotifications = false
    @State private var mentionNotifications = false

    @State private var mode: Int = 0

    var body: some View {
        List { /// List is a ScrollView.
            CollageLayout {
                ForEach(self.users.prefix(3), id: \.id) { user in
                    Circle()
                        .background(
                            AsyncImage(url: URL(string: user.imageUrl)) { image in
                                image
                                    .resizable()
                            } placeholder: {
                                Rectangle()
                            }
                        )
                        .foregroundStyle(.clear)
                        .clipShape(Circle())
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.width * 0.5)
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

            // MARK: - Biome Type

            HStack {
                TextField("Biome", text: $biomeName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .textFieldStyle(PlainTextFieldStyle())

            }
            .listRowBackground(
                Rectangle()
                    .foregroundStyle(.clear)
                    .background(.clear)
            )

            Section {
                Picker("Biome Type", selection: self.$mode) {
                    Image(systemName: "network")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .tag(0)

                    Image(systemName: "network.badge.shield.half.filled")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
            } header: {
                Text("\(self.mode == 0 ? "Interlaced" : "Interlinked")")
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                    .transition(.scale)
                    .animation(.spring(), value: self.mode)
            } footer: {
                ZStack {
                    if self.mode == 0 {
                        Text("Anyone can freely message and interact within the Biome.")
                    } else {
                        Text("Users on the periphery must send a request to join.")
                    }
                }
            }
            .listRowBackground(
                Rectangle()
                    .foregroundStyle(.clear)
                    .background(.clear)
            )

            // MARK: - User Management

            Section {
                // MARK: - Core

                HStack {
                    Image(systemName: "chevron.up.dotted.2")
                        .foregroundStyle(.secondary)
                        .font(.footnote)

                    Menu {
                        /// Main menu listing all core users.
                        ControlGroup {
                            Button {
                                /// Add a new user to the biome.
                            } label: {
                                Label("Add Users", systemImage: "")
                            }
                        }

                        ForEach(self.users, id: \.id) { user in

                            Divider()

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

                                /// Biome specific management menu for each user.
                                Menu {
                                    ControlGroup {
                                        Button(role: .destructive) {} label: {
                                            Label("Block", systemImage: "circle.badge.xmark.fill")
                                        }

                                        Button {
                                            if let index = users.firstIndex(where: { $0.id == user.id }) {
                                                self.users.remove(at: index)
                                            }
                                        } label: {
                                            Label("Remove", systemImage: "circle.badge.minus.fill")
                                        }
                                    }

                                } label: {
                                    Label {
                                        Text("Biome Presence")

                                    } icon: {
                                        Image(systemName: "circle.badge.exclamationmark")
                                        // .foregroundStyle(.black, .white, .white)
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

                                Text("Online")
                            }
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
                    .menuActionDismissBehavior(.disabled)

                    Spacer()

                    Text("32")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // MARK: - Peripheral

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

                        ForEach(self.users, id: \.id) { user in
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
                                            self.users.remove(at: index)
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

                        ForEach(self.users, id: \.id) { user in
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
                                            self.users.remove(at: index)
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
            } footer: {
                Text("Blocked users will not be able to view or interact with this Biome in any capacity.")
            }

            // MARK: - Alerts

            Section {
                Toggle(isOn: self.$messageNotifications) {
                    Label("Messages", systemImage: "message.badge.filled.fill")
                        .accentColor(.white)
                }
                .tint(.white)
                .contentTransition(.symbolEffect(.replace))

                Toggle(isOn: self.$requestNotifications) {
                    Label("Requests", systemImage: "plus.message.fill")
                        .accentColor(.white)
                }
                .tint(.white)
                .contentTransition(.symbolEffect(.replace))

                Toggle(isOn: self.$mentionNotifications) {
                    Label("Mentions", systemImage: "at")
                        .accentColor(.white)
                }
                .tint(.white)
                .contentTransition(.symbolEffect(.replace))
            } header: {
                Text("Alerts")
                    .fontWeight(.semibold)
            } footer: {
                Text("")
            }


        }
        .scrollContentBackground(.hidden)
        .safeAreaPadding(.bottom)
    }
}
