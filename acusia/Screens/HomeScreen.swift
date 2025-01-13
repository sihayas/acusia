/// This took a MONTH to figure out for some reason. I spent way too long try to pull it off in pure SwiftUI.
/// https://stackoverflow.com/questions/25793141/continuous-vertical-scrolling-between-uicollectionview-nested-in-uiscrollview
import SwiftUI

struct Home: View {
    @Environment(\.viewSize) private var viewSize
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: UIState

    @StateObject private var scrollDelegate = CSVDelegate()

    @State var dragOffset: CGFloat = 0

    var body: some View {
        let upperSectionHeight = safeAreaInsets.top * 2
        let bottomSectionHeight = viewSize.height - upperSectionHeight

        CSVRepresentable(delegate: scrollDelegate) {
            ZStack(alignment: .top) {
                // MARK: - Below Scroll View

                CSVRepresentable(isInner: true, delegate: scrollDelegate) {
                    InnerContent(
                        offset: $dragOffset,
                        upperSectionHeight: upperSectionHeight,
                        bottomSectionHeight: bottomSectionHeight
                    )
                }
                .frame(height: viewSize.height)

                // MARK: - Above Scroll View

                OuterContent(
                    offset: $dragOffset,
                    upperSectionHeight: upperSectionHeight,
                    bottomSectionHeight: bottomSectionHeight
                )
            }
            .overlay(alignment: .top) {
                LinearBlurView(radius: 8, gradientColors: [.black, .clear])
                    .frame(height: upperSectionHeight + 32)
                    .ignoresSafeArea()
            }
        }
        .overlay(alignment: .top) {
            HStack(alignment: .bottom) {
                Text("alia")
                    .font(.title)
                    .foregroundColor(.white)
                    .fontWeight(.bold)

                Spacer()

                AvatarView(size: 35, imageURL: "https://i.pinimg.com/280x280_RS/1a/78/35/1a7835ae1ff5062889bbf675e0d329dc.jpg")
            }
            .shadow(radius: 12)
            .padding(.horizontal, 24)
            .frame(height: upperSectionHeight, alignment: .bottom)
        }
        .onChange(of: scrollDelegate.dragOffset) { _, offset in
            dragOffset = offset
            print("offset: \(offset)")
        }
    }
}

struct OuterContent: View {
    @Binding var offset: CGFloat
    let upperSectionHeight: CGFloat
    let bottomSectionHeight: CGFloat
 
    var body: some View {
        VStack(spacing: 0) {
            LazyVStack(spacing: 12) {
                BiomePreviewView(biome: Biome(entities: biomePreviewOne))
                BiomePreviewView(biome: Biome(entities: biomePreviewThree))
                BiomePreviewView(biome: Biome(entities: biomePreviewTwo))
            }
            .padding(.top, 24)
            .background(.black)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .border(.blue)
        .offset(y: upperSectionHeight + offset)
        .animation(.spring(), value: offset)
    }
}

struct InnerContent: View {
    @Binding var offset: CGFloat
    let upperSectionHeight: CGFloat
    let bottomSectionHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            /// User History
            LazyVStack(alignment: .trailing, spacing: 16) {
                ForEach(userHistorySample.indices, id: \.self) { index in
                    EntityHistoryView(
                        rootEntity: userHistorySample[index],
                        previousEntity: userHistorySample[index],
                        entity: userHistorySample[index]
                    )
                }
            }
        }
        .padding([.horizontal], 16)
        .border(.red)
        .offset(y: -bottomSectionHeight + offset)
        .animation(.spring(), value: offset)
    }
}

