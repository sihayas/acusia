//
//  Wave.swift
//  acusia
//
//  Created by decoherence on 9/4/24.
//
import SwiftUI
import Wave
import BigUIPaging

#Preview {
    SwiftUIView()
}

struct SwiftUIView: View {

    // Card Deck
    @State private var selection: Int = 1
    @State private var showPopover = false
    @State private var showPopoverAnimate = false

    // Wave
    let offsetAnimator = SpringAnimator<CGPoint>(spring: Spring(dampingRatio: 0.72, response: 0.7))
    @State var boxOffset: CGPoint = .zero
    @State var redRectanglePosition: CGPoint = .zero // Store the position of the red rectangle
    @State var blueRectanglePosition: CGPoint = .zero // Store the position of the blue rectangl
    
    var body: some View {
        let size = 28.0
        
        let imageUrl = "https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/26/24/07/2624075e-51b9-60a4-bc11-93bbdde0f36c/103097.jpg/600x600bb.jpg"
        let name = "Why Bonnie?"
        let artistName = "Wish on the Bone"
        let text = "‘Wish On The Bone’ is out now ⛓️‍💥🌱 I’m truly at a loss for words — so much love, change, & passion went into this album. My hope is that you can feel some of that love when listening to these songs & that it gives you strength to take on the day. Or at least, bop along🦋"
        
        VStack {
            // Card stack
            PageView(selection: $selection) {
                ForEach([1, 2], id: \.self) { index in
                    if index == 1 {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .foregroundStyle(.ultraThickMaterial)
                            .background(
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                } placeholder: {
                                    Rectangle()
                                }
                            )
                            .overlay {
                                ZStack(alignment: .bottomTrailing) {
                                    if !showPopover {
                                        VStack {
                                            Text(text)
                                                .foregroundColor(.white)
                                                .font(.system(size: 15, weight: .semibold))
                                                .multilineTextAlignment(.leading)
                                        }
                                        .padding([.horizontal, .top], 20)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .mask(
                                            LinearGradient(
                                                gradient: Gradient(stops: [
                                                    .init(color: .black, location: 0),
                                                    .init(color: .black, location: 0.75),
                                                    .init(color: .clear, location: 0.825)
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                            .frame(height: .infinity)
                                        )
                                    }

                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(artistName)
                                                .foregroundColor(.secondary)
                                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                                .lineLimit(1)
                                            Text(name)
                                                .foregroundColor(.secondary)
                                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                .lineLimit(1)
                                        }

                                        Spacer()

                                        // Capture the position of the red rectangle
                                        GeometryReader { geo in
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(.red)
                                                .frame(width: 28, height: 28)
                                                .onAppear {
                                                    // Capture the position of the red rectangle
                                                    redRectanglePosition = CGPoint(x: geo.frame(in: .global).minX, y: geo.frame(in: .global).minY)
                                                }
                                        }
                                        .frame(width: 28, height: 28) // Limit GeometryReader size
                                    }
                                    .padding(20)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                }
                            }
                            .popover(isPresented: $showPopover, attachmentAnchor: .point(.topLeading), arrowEdge: .bottom) {
                                ScrollView {
                                    Text(text)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .font(.system(size: 15, weight: .regular))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .foregroundColor(.primary)
                                }
                                .frame(width: 272)
                                .presentationCompactAdaptation(.popover)
                                .presentationBackground(.ultraThinMaterial)
                            }
                            // Popover states
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    showPopoverAnimate.toggle()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    showPopover = showPopoverAnimate
                                }
                            }
                            .onChange(of: showPopover) { _, value in
                                if !value {
                                    withAnimation(.spring()) {
                                        showPopoverAnimate = false
                                    }
                                }
                            }
                            .frame(height: showPopoverAnimate ? 68 : 280)
                    } else {
                        Rectangle()
                            .foregroundStyle(.clear)
                            .background(.clear)
                            .overlay(alignment: .bottom) {
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                } placeholder: {
                                    Rectangle()
                                }
                            }
                    }
                }
            }
            .pageViewStyle(.customCardDeck)
            .pageViewCardShadow(.visible)
            .frame(width: 204, height: 280)

            Spacer()
                .frame(height: 164)

            ZStack {
                // Capture the position of the blue rectangle being dragged
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                        .fill(.blue)
                        .frame(width: size, height: size)
                        .onAppear {
                            // Capture the initial position of the blue rectangle
                            blueRectanglePosition = CGPoint(x: geo.frame(in: .global).minX, y: geo.frame(in: .global).minY)
                        }
                }
                .frame(width: size, height: size)
            }
            .onAppear {
                offsetAnimator.value = .zero

                // The offset animator's callback will update the `offset` state variable.
                offsetAnimator.valueChanged = { newValue in
                    boxOffset = newValue
                }
            }
            .offset(x: boxOffset.x, y: boxOffset.y)
            // on tap reset
            .onTapGesture {
                offsetAnimator.target = .zero
                offsetAnimator.mode = .animated
                offsetAnimator.start()
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Update the animator's target to the new drag translation.
                        offsetAnimator.target = CGPoint(x: value.translation.width, y: value.translation.height)

                        // Don't animate the box's position when we're dragging it.
                        offsetAnimator.mode = .nonAnimated
                        offsetAnimator.start()
                    }
                    .onEnded { value in
                        // Calculate the difference between the blue and red rectangle positions
                        let targetOffset = CGPoint(
                            x: redRectanglePosition.x - blueRectanglePosition.x,
                            y: redRectanglePosition.y - blueRectanglePosition.y
                        )
                        
                        // Assign this offset as the new target for the animator
                        offsetAnimator.target = targetOffset
                        
                        // Use animated mode to animate the transition.
                        offsetAnimator.mode = .animated

                        // Assign the gesture velocity to the animator to ensure a natural throw feel.
                        offsetAnimator.velocity = CGPoint(x: value.velocity.width, y: value.velocity.height)
                        offsetAnimator.start()
                    }
            )
        }
    }
    
    var indicatorSelection: Binding<Int> {
        .init {
            selection - 1
        } set: { newValue in
            selection = newValue + 1
        }
    }
}

class SwiftUIViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        title = "SwiftUI"
        tabBarItem.image = UIImage(systemName: "swift")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        let hostingController = UIHostingController(rootView: SwiftUIView())
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.frame = view.bounds
    }
}
