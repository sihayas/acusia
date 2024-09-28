import SwiftUI

struct ContentView: View {
    @State var blurRadius: CGFloat = 4
    @State var isExpanded: Bool = false
    
    // Left Shape
    @State var leadingOffset = CGPoint(x: 0, y: 0)
    @State var leadingMinimal: Bool = false
    @State var isLeftVisible: Bool = false
    
    // Middle Shape
    @State var midOffset = CGPoint(x: 0, y: 0)
    @State var expandSearch: Bool = false
    @State var isMidVisible: Bool = false
    @State var searchText: String = ""

    // Right Shape
    @State var rightOffset = CGPoint(x: 0, y: 0)
    @State var expandReply: Bool = false
    @State var isRightVisible: Bool = false
    @State var replyText: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            // Screen dimensions
            let width = geometry.size.width
            let height = geometry.size.height
            let centerWidth = width / 2
            
            // Constants
            let blobSize: CGFloat = 36
            let gap: CGFloat = 18
            let horizontalPadding: CGFloat = 48
            
            // Dynamic dimensions based on state
            let leftDimensions: CGSize = leadingMinimal
                ? CGSize(width: 36, height: 36)
                : CGSize(width: 128, height: 36)
            
            let midDimensions: CGSize = expandSearch
                ? CGSize(width: width - horizontalPadding, height: 48)
                : CGSize(width: 128, height: 36)
            
            let rightDimensions: CGSize = expandReply
                ? CGSize(width: width - horizontalPadding - blobSize - gap, height: 36)
                : CGSize(width: 128, height: 36)
            
            ZStack {
                // MARK: Canvas
                
                Canvas { context, _ in
                    // Resolve symbols
                    let firstCircle = context.resolveSymbol(id: 0)!
                    let secondCircle = context.resolveSymbol(id: 1)!
                    let thirdCircle = context.resolveSymbol(id: 2)!
                    
                    // Apply filters
                    context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                    context.addFilter(.blur(radius: blurRadius))
                    
                    // Center point
                    let center = CGPoint(x: width / 2, y: height / 2)
                    
                    // Draw symbols at center
                    context.drawLayer { context2 in
                        context2.draw(firstCircle, at: center)
                        context2.draw(secondCircle, at: center)
                        context2.draw(thirdCircle, at: center)
                    }
                } symbols: {
                    // Left Capsule
                    Capsule()
                        .frame(width: leftDimensions.width, height: leftDimensions.height)
                        .offset(x: leadingOffset.x, y: leadingOffset.y)
                        .frame(width: width, height: height, alignment: .bottom)
                        .tag(1)
                    
                    // Middle RoundedRectangle
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .frame(width: midDimensions.width, height: midDimensions.height)
                        .offset(x: midOffset.x, y: midOffset.y)
                        .frame(width: width, height: height, alignment: .bottom)
                        .tag(0)
                    
                    // Right RoundedRectangle
                    TextEditor(text: $replyText)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white)
                        .background(.black)
                        .frame(width: rightDimensions.width)
                        .frame(minHeight: 36, alignment: .leading)
                        .frame(maxHeight: 124)
                        .cornerRadius(18, antialiased: true)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .offset(x: rightOffset.x, y: rightOffset.y)
                        .frame(width: width, height: height, alignment: .bottom)
                        .tag(2)
                }
                
                // MARK: Content Overlay
                
                // Left Capsule Overlay
                Capsule()
                    .frame(width: leftDimensions.width, height: leftDimensions.height)
                    .overlay {
                        VStack {
                            if isLeftVisible {
                                AsyncImage(url: URL(string: "https://i.pinimg.com/474x/ce/7e/af/ce7eafb66f1d7edf58ef4d4b284d677a.jpg")) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 24, height: 24)
                                .clipShape(Circle())
                                .transition(.blurReplace)
                            }
                        }
                        .frame(width: blobSize, height: blobSize)
                    }
                    .clipShape(Capsule())
                    .offset(x: leadingOffset.x, y: leadingOffset.y)
                    .frame(width: width, height: height, alignment: .bottom)
                    .foregroundColor(.clear)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
//                    .stroke(Color.red, lineWidth: 1)
                    .frame(width: midDimensions.width, height: midDimensions.height)
                    .overlay {
                        HStack {
                            if isMidVisible {
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
                        }
                        .padding(.horizontal, 16)
                    }
                    .offset(x: midOffset.x, y: midOffset.y)
                    .frame(width: width, height: height, alignment: .bottom)
                    .foregroundColor(.clear)
                
                
                TextEditor(text: $replyText)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white)
                    .background(.black)
                    .frame(width: rightDimensions.width)
                    .frame(minHeight: 36, alignment: .leading)
                    .frame(maxHeight: 124)
                    .cornerRadius(18, antialiased: true)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .offset(x: rightOffset.x, y: rightOffset.y)
                    .frame(width: width, height: height, alignment: .bottom)
                    .opacity(isRightVisible ? 1 : 0)
                
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
            self.rightOffset = .zero
            self.midOffset = .zero
            self.leadingMinimal = false
            self.expandSearch = false
            self.expandReply = false
            self.isLeftVisible = false
            self.isMidVisible = false
            self.isRightVisible = false
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
            self.rightOffset = CGPoint(x: 24, y: 0)
            self.leadingMinimal = true
            self.expandReply = true
            self.isRightVisible = true
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
            self.expandSearch = true
            self.isMidVisible = true
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
            self.rightOffset = CGPoint(x: 46, y: 0)
            self.leadingMinimal = true
            self.isLeftVisible = true
            self.isExpanded = true
        } completion: {
            blurRadius = 0
        }
    }
}

#Preview {
    ContentView()
}
