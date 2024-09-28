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
            // Screen dimensions
            let width = geometry.size.width
            let height = geometry.size.height
            let centerWidth = width / 2
            let centerPoint = CGPoint(x: width / 2, y: height / 2)
            
            // Constants
            let blobSize: CGFloat = 36
            let gap: CGFloat = 18
            let horizontalPadding: CGFloat = 48
            
            // Dynamic dimensions based on state
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
                // MARK: Canvas
                
                Canvas { context, _ in
                    // Resolve symbols
                    let leading = context.resolveSymbol(id: 0)!
                    let trailing = context.resolveSymbol(id: 1)!
                    let center = context.resolveSymbol(id: 2)!
                    
                    // Apply filters
                    context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                    context.addFilter(.blur(radius: blurRadius))
                    
                    // Draw symbols at center
                    context.drawLayer { context2 in
                        context2.draw(leading, at: centerPoint)
                        context2.draw(trailing, at: centerPoint)
                        context2.draw(center, at: centerPoint)
                    }
                } symbols: {
                    // Leading
                    Capsule()
                        .frame(width: leadingSize.width, height: leadingSize.height)
                        .offset(x: leadingOffset.x, y: leadingOffset.y)
                        .frame(width: width, height: height, alignment: .bottom)
                        .tag(0)

                    // Trailing
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
                    
                    // Center
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
                
                // MARK: Controls
                
                VStack {
                    HStack {
                        // Animate left circle to the left
                        Button(action: {
                            if isExpanded {
                                resetState {
                                    expandLeftBlob(centerWidth: centerWidth)
                                }
                            } else {
                                expandLeftBlob(centerWidth: centerWidth)
                            }
                        }) {
                            Image(systemName: "arrowshape.turn.up.left.fill")
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                        
                        // Reset button
                        Button(action: {
                            resetState()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        
                        // Expand search bar
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
                        
                        // Expand reply button
                        
                        Button(action: {
                            if isExpanded {
                                resetState {
                                    expandReply(centerWidth: centerWidth, gap: gap)
                                }
                            } else {
                                expandReply(centerWidth: centerWidth, gap: gap)
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
        .background(Color(UIColor.systemGray6))
    }
    
    func resetState(completion: @escaping () -> Void = {}) {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2), // Response 0.5
            damping: 4 * .pi * 0.7 / 0.5, // Damping 0.7
            initialVelocity: 0.0
        )) {
            self.blurRadius = 4
            self.leadingOffset = .zero
            self.trailingOffset = .zero
            self.centerOffset = .zero
            self.leadingMinimal = false
            self.centerExpanded = false
            self.trailingExpanded = false
            self.trailingExpanded = false
            self.isExpanded = false
        } completion: {
            blurRadius = 0
            completion()
        }
    }
    
    func expandReply(centerWidth: CGFloat, gap: CGFloat) {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2), // Response 0.5
            damping: 4 * .pi * 0.7 / 0.5, // Damping 0.7
            initialVelocity: 0.0
        )) {
            self.blurRadius = 4
            self.leadingOffset = CGPoint(x: -(centerWidth - gap) + 24, y: 0)
            self.trailingOffset = CGPoint(x: 24, y: 0)
            self.trailingExpanded = true
            self.isExpanded = true
        } completion: {
            blurRadius = 0
        }
    }
    
    // expand search bar func
    func expandSearchBar() {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2), // Response 0.5
            damping: 4 * .pi * 0.7 / 0.5, // Damping 0.7
            initialVelocity: 0.0
        )) {
            self.centerExpanded = true
            self.isExpanded = true
        }
    }
    
    func expandLeftBlob(centerWidth: CGFloat) {
        withAnimation(.interpolatingSpring(
            mass: 1.0,
            stiffness: pow(2 * .pi / 0.5, 2), // Response 0.5
            damping: 4 * .pi * 0.7 / 0.5, // Damping 0.7
            initialVelocity: 0.0
        )) {
            self.blurRadius = 4
            self.leadingOffset = CGPoint(x: -(centerWidth - 126) - 16, y: 0)
            self.trailingOffset = CGPoint(x: 46, y: 0)
            self.leadingMinimal = true
            self.isExpanded = true
        } completion: {
            blurRadius = 0
        }
    }
}

#Preview {
    ApertureView()
}
