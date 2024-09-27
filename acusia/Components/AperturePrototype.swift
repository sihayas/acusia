import SwiftUI

struct ContentView: View {
    @State var blurRadius: CGFloat = 4
    
    @State var leftPos = CGSize(width: 0, height: 0)
    @State var midPos = CGSize(width: 0, height: 0)
    @State var rightPos = CGSize(width: 0, height: 0)
    
    @State var collapseLeft: Bool = false
    
    // Middle bar
    @State var expandSearch: Bool = false
    @State var expandReply: Bool = false
    
    var body: some View {
        
        GeometryReader { geometry in
            let leftDimensions: CGSize = collapseLeft
            ? CGSize(width: 36, height: 36)
            : CGSize(width: 128, height: 36)
            
            let midDimensions: CGSize = expandSearch
            ? CGSize(width: geometry.size.width - 48, height: 48)
            : CGSize(width: 128, height: 36)
            
            let rightDimensions: CGSize = expandReply
            ? CGSize(width: geometry.size.width - 48 - 36 - 16, height: 36)
            : CGSize(width: 128, height: 36)
            
            ZStack {
                // MARK: Canvas
                
                Canvas { context, size in
                    let firstCircle = context.resolveSymbol(id: 0)!
                    let secondCircle = context.resolveSymbol(id: 1)!
                    let thirdCircle = context.resolveSymbol(id: 2)!
                    
                    // Add filters
                    context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                    context.addFilter(.blur(radius: blurRadius))
                    
                    // Calculate the center of the canvas
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    
                    // Draw symbols at the center
                    context.drawLayer { context2 in
                        context2.draw(firstCircle, at: center)
                        context2.draw(secondCircle, at: center)
                        context2.draw(thirdCircle, at: center)
                    }
                } symbols: {
                    Capsule()
                        .frame(width: leftDimensions.width, height: leftDimensions.height)
                        .offset(x: leftPos.width, y: leftPos.height)
                        .frame(width: geometry.size.width - 48, height: 48, alignment: .bottom)
                        .tag(1)

                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .frame(width: midDimensions.width, height: midDimensions.height)
                        .offset(x: midPos.width, y: midPos.height)
                        .frame(width: geometry.size.width - 48, height: 48, alignment: .bottom)
                        .tag(0)
                    
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .frame(width: rightDimensions.width, height: rightDimensions.height)
                        .offset(x: rightPos.width, y: rightPos.height)
                        .frame(width: geometry.size.width - 48, height: 48, alignment: .bottom)
                        .tag(2)
                }
                
                // MARK: Content Overlay

                Capsule()
                    .frame(width: 128, height: 36)
                    .offset(x: rightPos.width, y: rightPos.height)
                    .foregroundColor(.clear)
                
                Capsule()
                    .frame(width: 128, height: 36)
                    .foregroundColor(.clear)
                
                Capsule()
                    .frame(width: collapseLeft ? 36 : 128, height: 36)
                    .offset(x: leftPos.width, y: leftPos.height)
                    .foregroundColor(.clear)
                
                // MARK: Controls
                
                VStack {
                    Spacer()
                    HStack {
                        // Button to animate the first circle to the left
                        Button(action: {
                            withAnimation(.interpolatingSpring(
                                mass: 1.0,
                                stiffness: pow(2 * .pi / 0.5, 2), // Response 0.5
                                damping: 4 * .pi * 0.7 / 0.5, // Damping 0.7
                                initialVelocity: 10.0
                            )) {
                                self.blurRadius = 4
                                self.leftPos = CGSize(width: -(geometry.size.width / 2 - 126) - 16, height: 0)
                                self.collapseLeft = true
                            } completion: {
                                blurRadius = 0
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 19))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        
                        // Reset button
                        Button(action: {
                            withAnimation(.interpolatingSpring(
                                mass: 1.0,
                                stiffness: pow(2 * .pi / 0.5, 2), // Response 0.5
                                damping: 4 * .pi * 0.7 / 0.5, // Damping 0.7
                                initialVelocity: 0.0
                            )) {
                                self.blurRadius = 4
                                self.leftPos = .zero
                                self.rightPos = .zero
                                self.midPos = .zero
                                self.collapseLeft = false
                                self.expandSearch = false
                                self.expandReply = false
                            } completion: {
                                blurRadius = 0
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.yellow)
                                .clipShape(Circle())
                        }
                        
                        // Button to expand the search bar
                        Button(action: {
                            withAnimation(.interpolatingSpring(
                                mass: 1.0,
                                stiffness: pow(2 * .pi / 0.5, 2), // Response 0.5
                                damping: 4 * .pi * 0.7 / 0.5, // Damping 0.7
                                initialVelocity: 10.0
                            )) {
                                self.expandSearch = true
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        
                        // Button to expand the reply button
                        Button(action: {
                            withAnimation(.interpolatingSpring(
                                mass: 1.0,
                                stiffness: pow(2 * .pi / 0.5, 2), // Response 0.5
                                damping: 4 * .pi * 0.7 / 0.5, // Damping 0.7
                                initialVelocity: 10.0
                            )) {
                                self.blurRadius = 4
                                self.leftPos = CGSize(width: -(geometry.size.width / 2 - 18) + 24, height: 0)
                                self.rightPos = CGSize(width: 24, height: 0)
                                self.collapseLeft = true
                                self.expandReply = true
                            } completion: {
                                blurRadius = 0
                            }
                        }) {
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

// VStack(alignment: .leading, spacing: 12) {
//    RoundedRectangle(cornerRadius: 32)
//        .fill(.black)
//        .frame(width: 196, height: 196)
//    Text(text)
//        .font(.system(size: 16, weight: .regular))
//        .foregroundColor(.black)
//        .padding(.horizontal, 14)
//        .padding(.vertical, 10)
//        .background(.black, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
//        .scaleEffect(animateScale ? 1 : 0, anchor: .top)
//        .offset(y: animateOffset ? 0 : -16)
// }
// .frame(maxWidth: .infinity, alignment: .bottomLeading)
// .padding(12)
// .tag(0)
