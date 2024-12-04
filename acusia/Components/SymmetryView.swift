import SwiftUI

enum Field: Hashable {
    case search
    case reply
}

struct SymmetryState {
    var leading: Properties
    var center: Properties
    var trailing: Properties
    
    struct Properties {
        var showContent: Bool
        var offset: CGPoint
        var size: CGSize
        var cornerRadius: CGFloat = 22
    }
}

struct SymmetryView: View {
    @EnvironmentObject private var windowState: UIState
    @EnvironmentObject private var musicKitManager: MusicKit
    @FocusState var focusedField: Field?
    
    // MARK: Appear State

    @State var symmetryState = SymmetryState(
        leading: .init(
            showContent: false,
            offset: .zero,
            size: CGSize(width: 128, height: 40)
        ),
        center: .init(
            showContent: false,
            offset: .zero,
            size: CGSize(width: 128, height: 40)
        ),
        trailing: .init(
            showContent: false,
            offset: .zero,
            size: CGSize(width: 128, height: 40)
        )
    )
    
    @State private var width: CGFloat = 0
    @State private var height: CGFloat = 0
    @State private var centerWidth: CGFloat = 0
    @State private var blurRadius: CGFloat = 4
    
    // Center
    @State var searchText: String = ""
    @State var rippleTrigger: Int = 0
    @State var origin: CGPoint = .zero
    @State var velocity: CGFloat = 1.0
    @State var loved: Bool = false

    @State var replyText: String = ""
    @State var replySize: CGSize = .zero
    
    let baseHeight: CGFloat = 44
    let baseWidth: CGFloat = 128
    let baseRadius: CGFloat = 22
    
    let horizontalPadding: CGFloat = 48
    let gap: CGFloat = 18
    
    var body: some View {
        GeometryReader { geometry in
            let centerPoint = CGPoint(x: width / 2, y: height / 2)
            
            ZStack {
                // MARK: Canvas

                Rectangle()
                    .background(.ultraThinMaterial)
                    .foregroundStyle(.clear)
                    .mask {
                        Canvas { ctx, _ in
                            let leading = ctx.resolveSymbol(id: 0)!
                            let trailing = ctx.resolveSymbol(id: 1)!
                            let center = ctx.resolveSymbol(id: 2)!
                            
                            ctx.addFilter(.alphaThreshold(min: 0.5))
                            ctx.addFilter(.blur(radius: blurRadius))
                            
                            ctx.drawLayer { ctx1 in
                                ctx1.draw(leading, at: centerPoint)
                                ctx1.draw(trailing, at: centerPoint)
                                ctx1.draw(center, at: centerPoint)
                            }
                        } symbols: {
                            createSymbol(
                                shape: RoundedRectangle(cornerRadius: symmetryState.leading.cornerRadius, style: .continuous),
                                fillColor: .black,
                                overlayContent: EmptyView(),
                                size: symmetryState.leading.size,
                                offset: symmetryState.leading.offset,
                                width: width,
                                height: height,
                                tag: 0
                            )

                            createCenterSymbol(
                                fillColor: .black,
                                overlayContent: EmptyView(),
                                width: width,
                                height: height,
                                tag: 1
                            )
                            
                            createSymbol(
                                shape: RoundedRectangle(cornerRadius: symmetryState.trailing.cornerRadius, style: .continuous),
                                fillColor: .black,
                                overlayContent: EmptyView(),
                                size: symmetryState.trailing.size,
                                offset: symmetryState.trailing.offset,
                                width: width,
                                height: height,
                                tag: 2
                            )
                        }
                    }
                    .allowsHitTesting(false)
                
                // MARK: Overlay

                Group {
                    createSymbol(
                        shape: RoundedRectangle(cornerRadius: symmetryState.leading.cornerRadius, style: .continuous),
                        fillColor: .clear,
                        overlayContent:
                        ZStack {
                            if windowState.symmetryState == .feed {
                                AvatarView(size: 40, imageURL: "https://i.pinimg.com/474x/36/21/cb/3621cbc3ccededfd4591ff199aa0ef0d.jpg")
                            }
                            
                            if windowState.symmetryState == .reply, let result = windowState.selectedResult {
                                GeometryReader { _ in
                                    AsyncImage(url: result.artwork?.url(width: 1000, height: 1000)) { image in
                                        image
                                            .resizable()
                                    } placeholder: {
                                        Rectangle()
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: symmetryState.center.cornerRadius - 2, style: .continuous))
                                    .aspectRatio(contentMode: .fit)
                                    .padding(2)
                                    .coordinateSpace(name: "AsyncImage")
                                    .onTapGesture(count: 2) { location in
                                        loved = true
                                        origin = location
                                        velocity = 1.5
                                        rippleTrigger += 1
                                    }
                                    .onTapGesture(count: 1) { location in
                                        loved = false
                                        origin = location // Ripple
                                        velocity = 0.5
                                        rippleTrigger += 1
                                    }
                                    .modifier(RippleEffect(at: origin, trigger: rippleTrigger, velocity: velocity))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(symmetryState.leading.showContent ? 1 : 0)
                        .animation(nil, value: symmetryState.leading.showContent),
                        size: symmetryState.leading.size,
                        offset: symmetryState.leading.offset,
                        width: width,
                        height: height,
                        tag: 0
                    )
                    
                    createCenterSymbol(
                        fillColor: .clear,
                        overlayContent:
                        ZStack {}
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(symmetryState.center.showContent ? 1 : 0)
                            .animation(nil, value: symmetryState.center.showContent),
                        width: width,
                        height: height,
                        tag: 1
                    )
                    
                    createSymbol(
                        shape: RoundedRectangle(cornerRadius: symmetryState.trailing.cornerRadius, style: .continuous),
                        fillColor: .clear,
                        overlayContent:
                        ZStack {
                            if windowState.symmetryState == .feed {
                                Button(action: {
                                    windowState.symmetryState = .search
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.white.opacity(0.5))
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.gray.opacity(0.001))
                            }
                            
                            if windowState.symmetryState == .reply {
                                Button(action: {
                                    print("Send")
                                }) {
                                    Image(systemName: "pencil.and.outline")
                                        .foregroundColor(replyText.isEmpty ? .gray : .white)
                                        .font(.system(size: 18))
                                        .padding(8)
                                }
                                .disabled(replyText.isEmpty)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(symmetryState.trailing.showContent ? 1 : 0)
                        .animation(nil, value: symmetryState.trailing.showContent),
                        size: symmetryState.trailing.size,
                        offset: symmetryState.trailing.offset,
                        width: width,
                        height: height,
                        tag: 2
                    )
                }
                
                // ControlButtons()
            }
            .onAppear {
                self.width = geometry.size.width
                self.height = geometry.size.height
                self.centerWidth = geometry.size.width / 2
                
                // windowState.symmetryState = .reply
            }
            .onChange(of: windowState.symmetryState) { _, _ in
                switch windowState.symmetryState {
                case .collapsed:
                    resetState()
                case .feed:
                    feedState()
                case .search:
                    searchState()
                case .reply:
                    replyState()
                case .form:
                    resetState()
                }
            }
            .onChange(of: searchText) { _, newValue in
                Task {
                    await MusicKit.shared.loadCatalogSearchTopResults(searchTerm: newValue)
                }
            }
            .onChange(of: replySize.height) { _, newHeight in
                if windowState.symmetryState == .reply {
                    withAnimation(.interpolatingSpring(
                        mass: 2.0,
                        stiffness: pow(2 * .pi / 0.5, 2),
                        damping: 4 * .pi * 0.7 / 0.5,
                        initialVelocity: 0.0
                    )) {
                        blurRadius = 1
                        symmetryState.leading.offset.y = -newHeight - 4
                    } completion: {
                        blurRadius = 0
                    }
                }
            }
        }
    }
}

// MARK: View Builders

extension SymmetryView {
    func createSymbol<ShapeType: Shape, Content: View>(
        shape: ShapeType,
        fillColor: Color,
        overlayContent: Content,
        size: CGSize,
        offset: CGPoint,
        width: CGFloat,
        height: CGFloat,
        tag: Int
    ) -> some View {
        shape
            .fill(fillColor)
            .frame(width: size.width, height: size.height)
            .overlay(overlayContent)
            .offset(x: offset.x, y: offset.y)
            .frame(width: width, height: height, alignment: .bottom)
            .tag(tag)
    }
    
    func createCenterSymbol<Content: View>(
        fillColor: Color,
        overlayContent: Content,
        width: CGFloat,
        height: CGFloat,
        tag: Int
    ) -> some View {
        VStack(spacing: 0) {
            Group {
                TextEditor(text: windowState.symmetryState == .reply ? $replyText : $searchText)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .padding([.top, .horizontal], 8)
                    .focused($focusedField, equals: .reply)
                    .focused($focusedField, equals: .search)
                    .textEditorBackground(.clear)
                
                
                if windowState.symmetryState == .reply {
                    HStack(alignment: .bottom) {
                        if let result = windowState.selectedResult {
                            HStack(spacing: 4) {
                                Image(systemName: "music.note")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.secondary)
                                
                                Text("\(result.artistName),")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                                    .lineLimit(1)
                                
                                Text(result.title)
                                    .foregroundColor(.white)
                                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.ultraThickMaterial, in: Capsule())
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            print("context menu")
                        }) {
                            Image(systemName: "ellipsis")
                                .contentTransition(.symbolEffect(.replace))
                                .foregroundColor(.secondary)
                                .animation(.smooth, value: replyText.isEmpty)
                                .font(.system(size: 20))
                                .frame(width: 27, height: 27 )
                        }
                        
                        
                        Button(action: {
                            replyText.isEmpty ? windowState.symmetryState = .search : print("send")
                        }) {
                            Image(systemName: replyText.isEmpty ? "xmark" : "arrow.up.circle.fill")
                                .contentTransition(.symbolEffect(.replace))
                                .foregroundColor(replyText.isEmpty ? Color(UIColor.systemRed) : .white)
                                .animation(.smooth, value: replyText.isEmpty)
                                .font(.system(size: 27))
                        }
                    }
                    .padding([.horizontal, .bottom], 8)
                }
            }
            .opacity(windowState.symmetryState != .reply && windowState.symmetryState != .search ? 0 : 1)
        }
        .frame(width: symmetryState.center.size.width)
        .frame(minHeight: symmetryState.center.size.height)
        .background(fillColor, in: RoundedRectangle(cornerRadius: symmetryState.center.cornerRadius, style: .continuous))
        .measure($replySize)
        .frame(maxHeight: 180)
        .fixedSize(horizontal: false, vertical: true)
        .overlay(overlayContent)
        .offset(x: symmetryState.center.offset.x, y: symmetryState.center.offset.y)
        .frame(width: width, height: height, alignment: .bottom)
        .tag(tag)
    }
}

// MARK: Control Buttons

extension SymmetryView {
    func resetState() {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2),
            damping: 4 * .pi * 0.7 / 0.5,
            initialVelocity: 0.0
        )) {
            windowState.selectedResult = nil
            focusedField = nil
            replyText = ""
            searchText = ""
            blurRadius = 4
            symmetryState = SymmetryState(
                leading: .init(
                    showContent: false,
                    offset: .zero,
                    size: CGSize(width: baseWidth, height: baseHeight),
                    cornerRadius: baseRadius
                ),
                center: .init(
                    showContent: false,
                    offset: .zero,
                    size: CGSize(width: baseWidth, height: baseHeight),
                    cornerRadius: baseRadius
                ),
                trailing: .init(
                    showContent: false,
                    offset: .zero,
                    size: CGSize(width: baseWidth, height: baseHeight),
                    cornerRadius: baseRadius
                )
            )
        } completion: {
            blurRadius = 0
        }
    }
    
    /// Move the leading capsule to the left & shrink
    /// Show the center capsule content, content is FeedState
    /// Move the trailing capsule to the right a bit for symmetry
    func feedState() {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2),
            damping: 4 * .pi * 0.7 / 0.5,
            initialVelocity: 0.0
        )) {
            windowState.selectedResult = nil
            focusedField = nil
            blurRadius = 4
            symmetryState = SymmetryState(
                leading: .init(
                    showContent: true,
                    offset: CGPoint(x: -centerWidth + 20 + 32, y: 0),
                    size: CGSize(width: baseHeight, height: baseHeight)
                ),
                center: .init(
                    showContent: true,
                    offset: .zero,
                    size: CGSize(width: baseWidth, height: baseHeight),
                    cornerRadius: baseRadius
                ),
                trailing: .init(
                    showContent: true,
                    offset: CGPoint(x: centerWidth - 20 - 32, y: 0),
                    size: CGSize(width: baseHeight, height: baseHeight)
                )
            )
        } completion: {
            blurRadius = 0
        }
    }
    
    /// Move the trailing capsule to the right & expand
    /// Move the leading capsule to the left, shrink
    /// Show the center capsule up, content is the selected result.
    func replyState() {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2),
            damping: 4 * .pi * 0.7 / 0.5,
            initialVelocity: 0.0
        )) {
            let height: CGFloat = 80
            
            blurRadius = 4
            focusedField = .reply
            symmetryState = SymmetryState(
                leading: .init(
                    showContent: true,
                    offset: CGPoint(x: -centerWidth + (224 / 2) + 24, y: -height - 4),
                    size: CGSize(width: 224, height: 224)
                ),
                center: .init(
                    showContent: true,
                    offset: .zero,
                    size: CGSize(width: width - horizontalPadding, height: height),
                    cornerRadius: baseRadius
                ),
                trailing: .init(
                    showContent: false,
                    offset: .zero,
                    size: CGSize(width: baseWidth, height: baseHeight)
                )
            )
        } completion: {
            blurRadius = 0
        }
    }
    
    /// Expand the center capsule
    func searchState() {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2),
            damping: 4 * .pi * 0.7 / 0.5,
            initialVelocity: 0.0
        )) {
            focusedField = .search
            symmetryState = SymmetryState(
                leading: .init(
                    showContent: false,
                    offset: .zero,
                    size: CGSize(width: baseWidth, height: baseHeight)
                ),
                center: .init(
                    showContent: true,
                    offset: .zero,
                    size: CGSize(width: width - horizontalPadding, height: 52),
                    cornerRadius: baseRadius
                ),
                trailing: .init(
                    showContent: false,
                    offset: .zero,
                    size: CGSize(width: baseWidth, height: baseHeight)
                )
            )
        }
    }
}

struct ControlButtons: View {
    // MARK: Buttons

    @EnvironmentObject private var windowState: UIState
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    windowState.symmetryState = .feed
                }) {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    windowState.symmetryState = .collapsed
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    windowState.symmetryState = .search
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    windowState.symmetryState = .reply
                }) {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    SymmetryView()
        .environmentObject(UIState())
        .background(.black)
}

private func viewHeight(for binding: Binding<CGFloat>) -> some View {
    GeometryReader { geometry -> Color in
        let rect = geometry.frame(in: .local)

        DispatchQueue.main.async {
            binding.wrappedValue = rect.size.height
        }
        return .clear
    }
}

extension View {
    func textEditorBackground(_ content: Color) -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden)
                .background(content)
        } else {
            UITextView.appearance().backgroundColor = .clear
            return background(content)
        }
    }
}

// overlayContent:
// ZStack {
//     if windowState.symmetryState == .search {
//         HStack {
//             TextField("Index", text: $searchText, axis: .horizontal)
//                 .textFieldStyle(PlainTextFieldStyle())
//                 .foregroundColor(.white)
//                 .font(.system(size: 17))
//                 .focused($focusedField, equals: .search)
//         }
//         .padding(.horizontal, 16)
//     }
//
//     if windowState.symmetryState == .reply, let result = windowState.selectedResult {
//         GeometryReader { _ in
//             AsyncImage(url: result.artwork?.url(width: 1000, height: 1000)) { image in
//                 image
//                     .resizable()
//             } placeholder: {
//                 Rectangle()
//             }
//             .clipShape(RoundedRectangle(cornerRadius: symmetryState.center.cornerRadius - 2, style: .continuous))
//             .aspectRatio(contentMode: .fit)
//             .padding(4)
//             .coordinateSpace(name: "AsyncImage")
//             .onTapGesture(count: 2) { location in
//                 loved = true
//                 origin = location
//                 velocity = 1.5
//                 rippleTrigger += 1
//             }
//             .onTapGesture(count: 1) { location in
//                 loved = false
//                 origin = location // Ripple
//                 velocity = 0.5
//                 rippleTrigger += 1
//             }
//             .modifier(RippleEffect(at: origin, trigger: rippleTrigger, velocity: velocity))
//         }
//     }
// }
