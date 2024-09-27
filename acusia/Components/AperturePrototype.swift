import SwiftUI

struct ContentView: View {
    let centerWidth = UIScreen.main.bounds.width / 2
    let centerHeight = UIScreen.main.bounds.height / 2
    
    @State var rightPosition = CGSize(width: 0, height: 0)
    @State var leftPosition = CGSize(width: 0, height: 0)
    @State var shrinkRight: Bool = false
    @State var blurRadius: CGFloat = 4
    
    var body: some View {
        ZStack {
            Canvas { context, _ in
                // Resolve symbols to draw
                let firstCircle = context.resolveSymbol(id: 0)!
                let secondCircle = context.resolveSymbol(id: 1)!
                let thirdCircle = context.resolveSymbol(id: 2)!
                
                // Add filters
                context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                context.addFilter(.blur(radius: blurRadius))
                
                context.drawLayer { context2 in
                    context2.draw(firstCircle, at: CGPoint(x: centerWidth, y: centerHeight))
                    context2.draw(secondCircle, at: CGPoint(x: centerWidth, y: centerHeight))
                    context2.draw(thirdCircle, at: CGPoint(x: centerWidth, y: centerHeight))
                }
            } symbols: {
                // Left
                Capsule()
                    .frame(width: 128, height: 36)
                    .offset(x: leftPosition.width, y: leftPosition.height)
                    .tag(2)

                Capsule()
                    .frame(width: 128, height: 36)
                    .tag(0)
                
                // Right
                Capsule()
                    .frame(width: shrinkRight ? 36 : 128, height: 36)
                    .offset(x: rightPosition.width, y: rightPosition.height)
                    .frame(width: 128, height: 36) // Prevent layout shift.
                    .tag(1)
            }
            
            VStack {
                Spacer()
                HStack {
                    // Button to animate the first circle to the left
                    Button(action: {
                        withAnimation(Animation.interpolatingSpring(
                            mass: 1.0,
                            stiffness: pow(2 * .pi / 0.5, 2), // Response 0.5
                            damping: 4 * .pi * 0.7 / 0.5, // Damping 0.7
                            initialVelocity: 10.0
                        )) {
                            self.blurRadius = 0
                            self.leftPosition = CGSize(width: -46, height: 0)
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
                        withAnimation(Animation.interpolatingSpring(
                            mass: 1.0,
                            stiffness: pow(2 * .pi / 0.5, 2), // Response 0.5
                            damping: 4 * .pi * 0.7 / 0.5, // Damping 0.7
                            initialVelocity: 0.0
                        )) {
                            self.blurRadius = 4
                            self.rightPosition = .zero
                            self.leftPosition = .zero
                            self.shrinkRight = false
                        } completion: {
                            blurRadius = 0
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    
                    // Button to animate the second circle to the right
                    Button(action: {
                        withAnimation(Animation.interpolatingSpring(
                            mass: 1.0,
                            stiffness: pow(2 * .pi / 0.5, 2), // Response 0.5
                            damping: 4 * .pi * 0.7 / 0.5, // Damping 0.7
                            initialVelocity: 10.0
                        )) {
                            self.blurRadius = 4
                            self.rightPosition = CGSize(width: (centerWidth - 126) + 16, height: 0)
                            self.shrinkRight = true
                        } completion: {
                            blurRadius = 0
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 19))
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

#Preview {
    ContentView()
}


//VStack(alignment: .leading, spacing: 12) {
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
//}
//.frame(maxWidth: .infinity, alignment: .bottomLeading)
//.padding(12)
//.tag(0)
