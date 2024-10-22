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
        var cornerRadius: CGFloat = 20
    }
}

struct SymmetryView: View {
    @EnvironmentObject private var windowState: WindowState
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
    
    // Trailing
    @State var replyText: String = ""
    @State var replyHeight: CGFloat = .zero
    
    @State var keyboardHeight: CGFloat = 0
    
    let horizontalPadding: CGFloat = 48
    let gap: CGFloat = 18
    
    var body: some View {
        GeometryReader { geometry in
            let centerPoint = CGPoint(x: width / 2, y: height / 2)
            
            ZStack {
                // MARK: Canvas

                Rectangle()
                    .foregroundColor(.clear)
                    .background(.ultraThinMaterial)
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
                            // Leading
                            Capsule()
                                .frame(
                                    width: symmetryState.leading.size.width,
                                    height: symmetryState.leading.size.height
                                )
                                .offset(
                                    x: symmetryState.leading.offset.x,
                                    y: symmetryState.leading.offset.y
                                )
                                .frame(width: width, height: height, alignment: .bottom)
                                .tag(0)

                            // Center
                            RoundedRectangle(cornerRadius: symmetryState.center.cornerRadius, style: .continuous)
                                .frame(
                                    width: symmetryState.center.size.width,
                                    height: symmetryState.center.size.height
                                )
                                .offset(
                                    x: symmetryState.center.offset.x,
                                    y: symmetryState.center.offset.y
                                )
                                .frame(width: width, height: height, alignment: .bottom)
                                .tag(2)
                            
                            // Trailing (Modifier placement is very important here)
                            VStack() {
                                TextEditor(text: $replyText)
                                    .textEditorStyle(.plain)
                                    .font(.system(size: 17))
                                    .focused($focusedField, equals: .reply)
                                    .foregroundColor(.white)
                                    .disabled(windowState.symmetryState != .reply)
                                    .frame(
                                        minHeight: symmetryState.trailing.size.height,
                                        alignment: .leading
                                    )
                            }
                            .frame(width: symmetryState.trailing.size.width)
                            .frame(
                                minHeight: symmetryState.trailing.size.height,
                                alignment: .leading
                            )
                            .background(.black, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .fixedSize(horizontal: false, vertical: true) // Placement is important!
                            .background(viewHeight(for: $replyHeight))
                            .overlay(alignment: .bottomLeading) {
                                ZStack {
                                    if windowState.symmetryState == .reply {
                                        Circle()
                                            .fill(.black)
                                            .frame(width: 12, height: 12)
                                        
                                        Circle()
                                            .fill(.black)
                                            .frame(width: 6, height: 6)
                                            .offset(x: -12, y: 0)
                                    }
                                }
                            }
                            .offset(
                                x: symmetryState.trailing.offset.x,
                                y: symmetryState.trailing.offset.y
                            )
                            .frame(width: width, height: height, alignment: .bottom)
                            .tag(1)
                        }
                    }
                    .allowsHitTesting(false)
                
                // MARK: Overlay

                Group {
                    // Leading
                    Capsule()
                        .fill(.clear)
                        .frame(
                            width: symmetryState.leading.size.width,
                            height: symmetryState.leading.size.height
                        )
                        .overlay {
                            AsyncImage(url: URL(string: "https://i.pinimg.com/474x/36/21/cb/3621cbc3ccededfd4591ff199aa0ef0d.jpg")) { image in
                                image
                                    .resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            .opacity(symmetryState.leading.showContent ? 1 : 0)
                            .animation(nil, value: symmetryState.trailing.showContent)
                        }
                        .offset(
                            x: symmetryState.leading.offset.x,
                            y: symmetryState.leading.offset.y
                        )
                        .frame(width: width, height: height, alignment: .bottom)
                    
                    // Center
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.clear)
                        .frame(
                            width: symmetryState.center.size.width,
                            height: symmetryState.center.size.height
                        )
                        .overlay {
                            ZStack {
                                if windowState.symmetryState == .search {
                                    HStack {
                                        TextField("Index", text: $searchText, axis: .horizontal)
                                            .textFieldStyle(PlainTextFieldStyle())
                                            .foregroundColor(.white)
                                            .font(.system(size: 17))
                                            .focused($focusedField, equals: .search)
                                    }
                                    .padding(.horizontal, 16)
                                }
                                
                                if windowState.symmetryState == .reply, let result = windowState.selectedResult {
                                    AsyncImage(url: result.artwork?.url(width: 1000, height: 1000)) { image in
                                        image
                                            .resizable()
                                    } placeholder: {
                                        Rectangle()
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: symmetryState.center.cornerRadius, style: .continuous))
                                    .aspectRatio(contentMode: .fit)
                                    .padding(2)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(symmetryState.center.showContent ? 1 : 0)
                        }
                        .offset(
                            x: symmetryState.center.offset.x,
                            y: symmetryState.center.offset.y
                        )
                        .frame(width: width, height: height, alignment: .bottom)
                    
                    // Trailing
                    VStack() {
                        TextEditor(text: $replyText)
                            .textEditorStyle(.plain)
                            .font(.system(size: 17))
                            .focused($focusedField, equals: .reply)
                            .foregroundColor(.white)
                            .disabled(windowState.symmetryState != .reply)
                            .lineLimit(2)
                            .frame(
                                minHeight: symmetryState.trailing.size.height,
                                alignment: .leading
                            )
                    }
                    .frame(width: symmetryState.trailing.size.width)
                    .frame(
                        minHeight: symmetryState.trailing.size.height,
                        alignment: .leading
                    )
                    .background(.clear, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .fixedSize(horizontal: false, vertical: true) // Placement is important!
                    .overlay(
                        ZStack {
                            if windowState.symmetryState == .feed {
                                Button(action: {
                                    windowState.symmetryState = .search
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 15))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(symmetryState.trailing.showContent ? 1 : 0)
                        .animation(nil, value: symmetryState.trailing.showContent)
                    )
                    .offset(
                        x: symmetryState.trailing.offset.x,
                        y: symmetryState.trailing.offset.y
                    )
                    .frame(width: width, height: height, alignment: .bottom)
                }
            }
            .onAppear {
                self.width = geometry.size.width
                self.height = geometry.size.height
                self.centerWidth = geometry.size.width / 2
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
            .onChange(of: replyHeight) { _, newHeight in
                if windowState.symmetryState == .reply {
                    withAnimation(.interpolatingSpring(
                        mass: 2.0,
                        stiffness: pow(2 * .pi / 0.5, 2),
                        damping: 4 * .pi * 0.7 / 0.5,
                        initialVelocity: 0.0
                    )) {
                        blurRadius = 1
                        symmetryState.center.offset = CGPoint(x: 24, y: -newHeight - 4)
                    } completion: {
                        blurRadius = 0
                    }
                }
            }
        }
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
            focusedField = nil
            replyText = ""
            searchText = ""
            blurRadius = 4
            symmetryState = SymmetryState(
                leading: .init(
                    showContent: false,
                    offset: .zero,
                    size: CGSize(width: 128, height: 40)
                ),
                center: .init(
                    showContent: false,
                    offset: .zero,
                    size: CGSize(width: 128, height: 40),
                    cornerRadius: 20
                ),
                trailing: .init(
                    showContent: false,
                    offset: .zero,
                    size: CGSize(width: 128, height: 40)
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
            focusedField = nil
            blurRadius = 4
            symmetryState = SymmetryState(
                leading: .init(
                    showContent: true,
                    offset: CGPoint(x: -centerWidth + 20 + 32, y: 0),
                    size: CGSize(width: 40, height: 40)
                ),
                center: .init(
                    showContent: true,
                    offset: .zero,
                    size: CGSize(width: 128, height: 40),
                    cornerRadius: 20
                ),
                trailing: .init(
                    showContent: true,
                    offset: CGPoint(x: centerWidth - 20 - 32, y: 0),
                    size: CGSize(width: 40, height: 40)
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
            blurRadius = 4
            focusedField = .reply
            symmetryState = SymmetryState(
                leading: .init(
                    showContent: true,
                    offset: CGPoint(x: -(centerWidth - gap) + 24, y: 0),
                    size: CGSize(width: 40, height: 40)
                ),
                center: .init(
                    showContent: true,
                    offset: CGPoint(x: 24, y: -self.replyHeight - 4),
                    size: CGSize(width: width - 48 - 40 - 18, height: width - 48 - 40 - 18),
                    cornerRadius: 40
                ),
                trailing: .init(
                    showContent: true,
                    offset: CGPoint(x: 24, y: 0),
                    size: CGSize(width: width - 48 - 40 - 18, height: 40)
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
                    size: CGSize(width: 128, height: 40)
                ),
                center: .init(
                    showContent: true,
                    offset: .zero,
                    size: CGSize(width: width - horizontalPadding, height: 48),
                    cornerRadius: 20
                ),
                trailing: .init(
                    showContent: false,
                    offset: .zero,
                    size: CGSize(width: 128, height: 40)
                )
            )
        }
    }
}

struct ControlButtons: View {
    // MARK: Buttons

    // ControlButtons(
    //     resetState: resetState,
    //     expandLeftBlob: expandLeftBlob,
    //     expandSearchBar: expandSearchBar,
    //     expandReply: expandReply
    // )
    
    let resetState: () -> Void
    let expandLeftBlob: () -> Void
    let expandSearchBar: () -> Void
    let expandReply: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    expandLeftBlob()
                }) {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    resetState()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    expandSearchBar()
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    expandReply()
                
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
