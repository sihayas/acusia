import SwiftUI

struct SymmetryState {
    var leading: Properties
    var center: Properties
    var trailing: Properties
    
    struct Properties {
        var showContent: Bool
        var offset: CGPoint
        var size: CGSize
    }
}

struct SymmetryView: View {
    @EnvironmentObject private var windowState: WindowState
    @EnvironmentObject private var musicKitManager: MusicKit
    
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
    @FocusState var searchFocusState: Bool
    @State var searchText: String = ""
    
    // Trailing
    @State var replyText: String = ""
    
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

                            RoundedRectangle(cornerRadius: 20, style: .continuous)
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
                            
                            TextEditor(text: $replyText)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.white)
                                .background(.black)
                                .frame(width: symmetryState.trailing.size.width)
                                .frame(
                                    minHeight: symmetryState.trailing.size.height,
                                    alignment: .leading
                                )
                                .frame(maxHeight: 124)
                                .cornerRadius(20, antialiased: true)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .offset(
                                    x: symmetryState.trailing.offset.x,
                                    y: symmetryState.trailing.offset.y
                                )
                                .frame(width: width, height: height, alignment: .bottom)
                                .tag(1)
                        }
                    }
                    .allowsHitTesting(false)
                
                // MARK: Content

                Group {
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
                        }
                        .offset(
                            x: symmetryState.leading.offset.x,
                            y: symmetryState.leading.offset.y
                        )
                        .frame(width: width, height: height, alignment: .bottom)
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.clear)
                        .frame(
                            width: symmetryState.center.size.width,
                            height: symmetryState.center.size.height
                        )
                        .overlay {
                            HStack {
                                if windowState.symmetryState == .search {
                                    TextField("Index", text: $searchText, axis: .horizontal)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(.white)
                                        .font(.system(size: 17))
                                        .focused($searchFocusState)
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(maxWidth: symmetryState.center.size.width)
                            .opacity(symmetryState.center.showContent ? 1 : 0)
                        }
                        .offset(
                            x: symmetryState.center.offset.x,
                            y: symmetryState.center.offset.y
                        )
                        .frame(width: width, height: height, alignment: .bottom)
                    
                    TextEditor(text: $replyText)
                        .textEditorStyle(PlainTextEditorStyle()) // ???
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.white)
                        .background(.clear)
                        .frame(width: symmetryState.trailing.size.width)
                        .frame(
                            minHeight: symmetryState.trailing.size.height,
                            alignment: .leading
                        )
                        .frame(maxHeight: 124)
                        .cornerRadius(20, antialiased: true)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .disabled(windowState.symmetryState != .reply)
                        .overlay(
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 15))
                                .opacity(symmetryState.trailing.showContent ? 1 : 0)
                        )
                        .onTapGesture {
                            windowState.symmetryState = .search
                        }
                        .offset(
                            x: symmetryState.trailing.offset.x,
                            y: symmetryState.trailing.offset.y
                        )
                        .frame(width: width, height: height, alignment: .bottom)
                }

                // MARK: Buttons

                // ControlButtons(
                //     resetState: resetState,
                //     expandLeftBlob: expandLeftBlob,
                //     expandSearchBar: expandSearchBar,
                //     expandReply: expandReply
                // )
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
                    resetState {}
                default:
                    resetState {}
                }
            }
            .onChange(of: searchText) {oV, newValue in
                Task {
                    await MusicKit.shared.loadCatalogSearchTopResults(searchTerm: newValue)
                }
            }
        }
    }
}

// MARK: Control Buttons

extension SymmetryView {
    func resetState(completion: @escaping () -> Void = {}) {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2),
            damping: 4 * .pi * 0.7 / 0.5,
            initialVelocity: 0.0
        )) {
            blurRadius = 4
            searchFocusState = false
            symmetryState = SymmetryState(
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
        } completion: {
            blurRadius = 0
            completion()
        }
    }
    
    /// Move the leading capsule to the left, shrink
    /// Move the trailing capsule to the right a bit for symmetry
    func feedState() {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2),
            damping: 4 * .pi * 0.7 / 0.5,
            initialVelocity: 0.0
        )) {
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
                    size: CGSize(width: 128, height: 40)
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
    
    /// Move the trailing capsule to the right, expand
    /// Move the leading capsule to the left, shrink
    func replyState() {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2),
            damping: 4 * .pi * 0.7 / 0.5,
            initialVelocity: 0.0
        )) {
            blurRadius = 4
            symmetryState = SymmetryState(
                leading: .init(
                    showContent: true,
                    offset: CGPoint(x: -(centerWidth - gap) + 24, y: 0),
                    size: CGSize(width: 40, height: 40)
                ),
                center: .init(
                    showContent: false,
                    offset: .zero,
                    size: CGSize(width: 128, height: 40)
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
            searchFocusState = true
            symmetryState = SymmetryState(
                leading: .init(
                    showContent: false,
                    offset: .zero,
                    size: CGSize(width: 128, height: 40)
                ),
                center: .init(
                    showContent: true,
                    offset: .zero,
                    size: CGSize(width: width - horizontalPadding, height: 48)
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
    let resetState: (@escaping () -> Void) -> Void
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
                    resetState {}
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
