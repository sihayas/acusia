//
//  BiomePreviewView.swift
//  acusia
//
//  Created by decoherence on 12/6/24.
//
import SwiftUI

struct BiomePreviewView: View {
    @EnvironmentObject private var windowState: UIState

    let biome: Biome

    @State private var showSheet: Bool = false
    @State private var frameSize: CGSize = .zero
    @State private var firstMessageSize: CGSize = .zero
    @Namespace var animation

    private var adjustedHeight: CGFloat? {
        guard frameSize.height > 0, firstMessageSize.height > 0 else {
            return nil
        }
        return frameSize.height - firstMessageSize.height
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                /// Ranked Messages
                ForEach(0 ..< biome.entities.count, id: \.self) { index in
                    let previousEntity = index > 0 ? biome.entities[index - 1] : nil

                    EntityView(
                        rootEntity: biome.entities[0],
                        previousEntity: previousEntity,
                        entity: biome.entities[index]
                    )
                    .readSize { newSize in
                        if index == 2 {
                            firstMessageSize = newSize
                            print("firstMessageSize: \(firstMessageSize)")
                        }
                    }
                }
            }
            .padding([.horizontal, .top], 24)
            .readSize { newSize in
                frameSize = newSize
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(
                height: frameSize.height > 0
                    ? frameSize.height - firstMessageSize.height + 80
                    : nil,
                alignment: .top
            )
            .background(.ultraThickMaterial)
            .overlay(alignment: .bottom) {
                ZStack(alignment: .bottom) {
                    LinearBlurView(radius: 2, gradientColors: [.clear, .black])
                        .frame(maxWidth: .infinity, maxHeight: 112)
                        .padding(.horizontal, 20)
                    
                    LinearGradientMask(gradientColors: [.clear, Color(.systemGray6)])
                        .frame(maxWidth: .infinity, maxHeight: 112)
                        .padding(.horizontal, 20)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .padding(.horizontal, 12)

            HStack(alignment: .bottom) {
                CollageLayout {
                    ForEach(userDevs.shuffled().prefix(4), id: \.id) { user in
                        Circle()
                            .stroke(.ultraThinMaterial)
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
                .frame(width: 56, height: 56)

                /// Biome Metadata
                HStack(alignment: .bottom, spacing: 8) {
                    // TypingIndicator()
                    Text("lorem ipsum")
                        .fontWeight(.bold)
                        .font(.title3)
                        .foregroundColor(.white)

                    Spacer()

                    ReplyButton()

                    Button {
                        // Perform button action here
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                TintedBlurView(style: .systemChromeMaterialDark, backgroundColor: .brown, blurMutingFactor: 0.25)
                            )
                            .clipShape(Capsule())
                    }
                }
                .frame(height: 56, alignment: .bottom)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 16)
            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
            .frame(maxWidth: .infinity)
        }
        .matchedTransitionSource(id: "hi", in: animation)
        .sheet(isPresented: $showSheet) {
            BiomeExpandedView(biome: Biome(entities: biomeOneExpanded))
                .navigationTransition(.zoom(sourceID: "hi", in: animation))
                .presentationBackground(.black)
        }
        .onTapGesture { showSheet = true }
    }
}

struct UserDev: Identifiable {
    let id: String
    let alias: String
    let imageUrl: String
}

let userDevs = [
    UserDev(id: UUID().uuidString, alias: "coldhealing", imageUrl: "https://pbs.twimg.com/profile_images/1759706838319161344/QZE066Lr_400x400.jpg"),
    UserDev(id: UUID().uuidString, alias: "apple.user7456", imageUrl: "https://pbs.twimg.com/profile_images/1828581255069241344/QySOaDzU_400x400.jpg"),
    UserDev(id: UUID().uuidString, alias: "jxnlco", imageUrl: "https://pbs.twimg.com/profile_images/1855940230362103808/_8fGXfK6_400x400.jpg"),
    UserDev(id: UUID().uuidString, alias: "yieldcurved", imageUrl: "https://pbs.twimg.com/profile_images/1562843260304863232/s_Cv2vdy_400x400.jpg"),
    UserDev(id: UUID().uuidString, alias: "quiet.frame", imageUrl: "https://pbs.twimg.com/profile_images/1709499954711142400/sHmbME_7_400x400.jpg"),
    UserDev(id: UUID().uuidString, alias: "lunarsocket", imageUrl: "https://i.pinimg.com/474x/72/ca/b5/72cab57cce1ac8e7c1141078ff05c141.jpg"),
    UserDev(id: UUID().uuidString, alias: "velvetdrive", imageUrl: "https://pbs.twimg.com/profile_images/1805385770192322566/dinq0ojH_400x400.jpg"),
    UserDev(id: UUID().uuidString, alias: "sliptrails", imageUrl: "https://i.pinimg.com/280x280_RS/46/2c/23/462c230588dcb4884c65f5eae3f39dc3.jpg"),
    UserDev(id: UUID().uuidString, alias: "softflares", imageUrl: "https://i.pinimg.com/280x280_RS/07/24/97/0724977eb9e1b0154bb3a5d6d82e0b33.jpg"),
    UserDev(id: UUID().uuidString, alias: "cozy.plan", imageUrl: "https://i.pinimg.com/280x280_RS/5a/c7/da/5ac7dabeb65f63e25950ca54fae03393.jpg"),
    UserDev(id: UUID().uuidString, alias: "winter.signal", imageUrl: "https://i.pinimg.com/280x280_RS/6a/08/16/6a081649460fa6f2ca716079c824b5b6.jpg"),
    UserDev(id: UUID().uuidString, alias: "sequoia.trace", imageUrl: "https://i.pinimg.com/280x280_RS/83/11/fb/8311fb2afaeb6dd10dab81886cc603ac.jpg"),
    UserDev(id: UUID().uuidString, alias: "hazelnet", imageUrl: "https://i.pinimg.com/280x280_RS/7a/7a/d2/7a7ad25b2bcc8f5fd7fe7100c9449399.jpg"),
    UserDev(id: UUID().uuidString, alias: "shadownexus", imageUrl: "https://i.pinimg.com/280x280_RS/40/01/0b/40010bb8fb1dda219f37a22bf412713a.jpg"),
    UserDev(id: UUID().uuidString, alias: "maplelane", imageUrl: "https://i.pinimg.com/280x280_RS/97/91/4e/97914e8e6557a18d5b34065690b1d43d.jpg"),
    UserDev(id: UUID().uuidString, alias: "evermint", imageUrl: "https://i.pinimg.com/280x280_RS/40/c7/ce/40c7ced7b37fcb5d83ff26399f5d38f6.jpg"),
    UserDev(id: UUID().uuidString, alias: "orbit.coast", imageUrl: "https://i.pinimg.com/280x280_RS/8b/79/a4/8b79a4432454bb33c713d25182be5a6b.jpg"),
    UserDev(id: UUID().uuidString, alias: "venusrising", imageUrl: "https://i.pinimg.com/280x280_RS/f5/4c/27/f54c27582e5760cd8df2bf08e7dc39b4.jpg"),
    UserDev(id: UUID().uuidString, alias: "mist.arcade", imageUrl: "https://i.pinimg.com/280x280_RS/63/83/3e/63833ed6c6c9e18ec8a164770e996003.jpg"),
    UserDev(id: UUID().uuidString, alias: "duskgrain", imageUrl: "https://i.pinimg.com/280x280_RS/a7/9b/b1/a79bb12753eb37c62e7b3f96e95c9367.jpg"),
    UserDev(id: UUID().uuidString, alias: "solar.forge", imageUrl: "https://i.pinimg.com/280x280_RS/f5/b8/ad/f5b8ad8d86b0dda8559e4d96832c1342.jpg"),
    UserDev(id: UUID().uuidString, alias: "emberlines", imageUrl: "https://i.pinimg.com/280x280_RS/cb/4c/86/cb4c86ff35c2b318e6ba92c4e4d2bae7.jpg"),
    UserDev(id: UUID().uuidString, alias: "frostedphase", imageUrl: "https://i.pinimg.com/280x280_RS/2f/89/5e/2f895e3c687868f4389fa55ff4ef0090.jpg"),
    UserDev(id: UUID().uuidString, alias: "coastaltide", imageUrl: "https://i.pinimg.com/280x280_RS/cc/86/b3/cc86b311d291d782466e4ed2efcfc6d6.jpg"),
    UserDev(id: UUID().uuidString, alias: "nightfall", imageUrl: "https://i.pinimg.com/280x280_RS/d1/0a/b3/d10ab33c36d05155c2b785533425e0fd.jpg"),
    UserDev(id: UUID().uuidString, alias: "warmgaze", imageUrl: "https://i.pinimg.com/280x280_RS/59/23/7b/59237bcdda00a6bd3a5c2e6dbabacb98.jpg")
]
