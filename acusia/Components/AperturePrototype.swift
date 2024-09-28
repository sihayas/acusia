import SwiftUI

struct ApertureView: View {
    @State var blurRadius: CGFloat = 4
    @State var isExpanded: Bool = false
    
    @State var leadingOffset = CGPoint(x: 0, y: 0)
    @State var leadingMinimal: Bool = false
    
    @State var centerOffset = CGPoint(x: 0, y: 0)
    @State var centerExpanded: Bool = false
    @State var searchText: String = ""

    @State var trailingOffset = CGPoint(x: 0, y: 0)
    @State var trailingExpanded: Bool = false
    @State var replyText: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let centerWidth = width / 2
            let centerPoint = CGPoint(x: width / 2, y: height / 2)
            let blobSize: CGFloat = 36
            let gap: CGFloat = 18
            let horizontalPadding: CGFloat = 48
            
            let leadingSize: CGSize = leadingMinimal
                ? CGSize(width: 36, height: 36)
                : trailingExpanded ? CGSize(width: 40, height: 40) :
                CGSize(width: 128, height: 36)
            
            let centerSize: CGSize = centerExpanded
                ? CGSize(width: width - horizontalPadding, height: 48)
                : CGSize(width: 128, height: 36)
            
            let trailingSize: CGSize = trailingExpanded
                ? CGSize(width: width - horizontalPadding - blobSize - gap, height: 40)
                : CGSize(width: 128, height: 36)
            let trailingRadius: CGFloat = trailingExpanded ? 20 : 18
            
            ZStack {
                Canvas { context, _ in
                    let leading = context.resolveSymbol(id: 0)!
                    let trailing = context.resolveSymbol(id: 1)!
                    let center = context.resolveSymbol(id: 2)!
                    
                    context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                    context.addFilter(.blur(radius: blurRadius))
                    
                    context.drawLayer { context2 in
                        context2.draw(leading, at: centerPoint)
                        context2.draw(trailing, at: centerPoint)
                        context2.draw(center, at: centerPoint)
                    }
                } symbols: {
                    Capsule()
                        .frame(width: leadingSize.width, height: leadingSize.height)
                        .offset(x: leadingOffset.x, y: leadingOffset.y)
                        .frame(width: width, height: height, alignment: .bottom)
                        .tag(0)

                    TextEditor(text: $replyText)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white)
                        .background(.black)
                        .frame(width: trailingSize.width)
                        .frame(minHeight: trailingSize.height, alignment: .leading)
                        .frame(maxHeight: 124)
                        .cornerRadius(trailingRadius, antialiased: true)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .offset(x: trailingOffset.x, y: trailingOffset.y)
                        .frame(width: width, height: height, alignment: .bottom)
                        .tag(1)
                    
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .frame(width: centerSize.width, height: centerSize.height)
                        .offset(x: centerOffset.x, y: centerOffset.y)
                        .frame(width: width, height: height, alignment: .bottom)
                        .tag(2)
                }
                
                
                // MARK: Content Overlay
                
                // Left Capsule Overlay
                Capsule()
                    .frame(width: leadingSize.width, height: leadingSize.height)
                    .overlay(alignment: .trailing) {
                        AsyncImage(url: URL(string: "https://i.pinimg.com/474x/7a/18/20/7a1820d818d3601fb92c59a84d458428.jpg")) { image in
                            image
                                .resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                        .frame(width: leadingSize.width, height: leadingSize.height)
                        .opacity(leadingMinimal || trailingExpanded ? 1 : 0)
                    }
                    .clipShape(Capsule())
                    .offset(x: leadingOffset.x, y: leadingOffset.y)
                    .frame(width: width, height: height, alignment: .bottom)
                    .foregroundColor(.clear)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .frame(width: centerSize.width, height: centerSize.height)
                    .overlay {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 15))
                                .transition(.blurReplace)

                            TextField("Index", text: $searchText, axis: .horizontal)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(.white)
                                .font(.system(size: 15))
                                .transition(.blurReplace)
                        }
                        .padding(.horizontal, 16)
                        .opacity(centerExpanded ? 1 : 0)
                    }
                    .offset(x: centerOffset.x, y: centerOffset.y)
                    .frame(width: width, height: height, alignment: .bottom)
                    .foregroundColor(.clear)
                
                TextEditor(text: $replyText)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white)
                    .background(.clear)
                    .frame(width: trailingSize.width)
                    .frame(minHeight: trailingSize.height, alignment: .leading)
                    .frame(maxHeight: 124)
                    .cornerRadius(trailingRadius, antialiased: true)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .offset(x: trailingOffset.x, y: trailingOffset.y)
                    .frame(width: width, height: height, alignment: .bottom)
                    .opacity(trailingExpanded ? 1 : 0)
                
                // Control Buttons
                ControlButtons(
                    isExpanded: $isExpanded,
                    resetState: resetState,
                    expandLeftBlob: { expandLeftBlob(centerWidth: centerWidth) },
                    expandSearchBar: expandSearchBar,
                    expandReply: { expandReply(centerWidth: centerWidth, gap: gap) }
                )
            }
        }
        .background(Color(UIColor.systemGray6))
    }
    
    func resetState(completion: @escaping () -> Void = {}) {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2),
            damping: 4 * .pi * 0.7 / 0.5,
            initialVelocity: 0.0
        )) {
            blurRadius = 4
            leadingOffset = .zero
            trailingOffset = .zero
            centerOffset = .zero
            leadingMinimal = false
            centerExpanded = false
            trailingExpanded = false
            isExpanded = false
        } completion: {
            blurRadius = 0
            completion()
        }
    }
    
    func expandReply(centerWidth: CGFloat, gap: CGFloat) {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2),
            damping: 4 * .pi * 0.7 / 0.5,
            initialVelocity: 0.0
        )) {
            blurRadius = 4
            leadingOffset = CGPoint(x: -(centerWidth - gap) + 24, y: 0)
            trailingOffset = CGPoint(x: 24, y: 0)
            trailingExpanded = true
            isExpanded = true
        } completion: {
            blurRadius = 0
        }
    }
    
    func expandSearchBar() {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2),
            damping: 4 * .pi * 0.7 / 0.5,
            initialVelocity: 0.0
        )) {
            centerExpanded = true
            isExpanded = true
        }
    }
    
    func expandLeftBlob(centerWidth: CGFloat) {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2),
            damping: 4 * .pi * 0.7 / 0.5,
            initialVelocity: 0.0
        )) {
            blurRadius = 4
            leadingOffset = CGPoint(x: -(centerWidth - 126) - 16, y: 0)
            trailingOffset = CGPoint(x: 46, y: 0)
            leadingMinimal = true
            isExpanded = true
        } completion: {
            blurRadius = 0
        }
    }
}

struct ControlButtons: View {
    @Binding var isExpanded: Bool
    let resetState: (@escaping () -> Void) -> Void
    let expandLeftBlob: () -> Void
    let expandSearchBar: () -> Void
    let expandReply: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if isExpanded {
                        resetState {
                            expandLeftBlob()
                        }
                    } else {
                        expandLeftBlob()
                    }
                }) {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    resetState { }
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    if isExpanded {
                        resetState {
                            expandSearchBar()
                        }
                    } else {
                        expandSearchBar()
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    if isExpanded {
                        resetState {
                            expandReply()
                        }
                    } else {
                        expandReply()
                    }
                }) {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.yellow)
                        .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    ApertureView()
}
