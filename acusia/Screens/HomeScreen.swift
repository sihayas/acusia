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

                InnerContent(
                    offset: $dragOffset,
                    scrollDelegate: scrollDelegate,
                    viewSize: viewSize,
                    upperSectionHeight: upperSectionHeight,
                    bottomSectionHeight: bottomSectionHeight
                )

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
            if scrollDelegate.trackDragOffset {
                dragOffset = offset
            }
        }
        .onChange(of: scrollDelegate.isExpanded) { _, isExpanded in
            withAnimation(.spring()) {
                if isExpanded {
                    dragOffset = 999
                }
            }
        }
    }
}

struct OuterContent: View {
    @Binding var offset: CGFloat
    let upperSectionHeight: CGFloat
    let bottomSectionHeight: CGFloat

    // Compute bounded offset for outer content
    private var boundedOffset: CGFloat {
        // Start at upperSectionHeight (minimum)
        // Can increase up to upperSectionHeight + bottomSectionHeight (maximum)
        let minOffset = upperSectionHeight
        let maxOffset = upperSectionHeight + bottomSectionHeight
        return min(maxOffset, max(minOffset, upperSectionHeight + offset))
    }

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
        .offset(y: boundedOffset)
    }
}

struct InnerContent: View {
    @Binding var offset: CGFloat
    let scrollDelegate: CSVDelegate
    let viewSize: CGSize
    let upperSectionHeight: CGFloat
    let bottomSectionHeight: CGFloat

    // Compute bounded offset for inner content
    private var boundedOffset: CGFloat {
        // Start at -bottomSectionHeight (minimum)
        // Can increase up to 0 (maximum)
        let minOffset = -bottomSectionHeight
        let maxOffset: CGFloat = 0
        return min(maxOffset, max(minOffset, -bottomSectionHeight + offset))
    }

    var body: some View {
        CSVRepresentable(isInner: true, delegate: scrollDelegate) {
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
        }
        .frame(height: viewSize.height)
        .offset(y: boundedOffset)
    }
}
