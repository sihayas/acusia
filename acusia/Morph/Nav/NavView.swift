import SwiftUI
import CoreHaptics

enum UIState {
    case collapsed
    case expanded
    case search
    case searching
    case form
    case profile
    case notifications
    case replying
}

struct NavView: View {
    var user: APIUser
    @Binding var path: NavigationPath
    @StateObject private var navManager = NavManager.shared
    @State private var uiState: UIState = .collapsed
    
    // blur/morphing effect
    @State private var radius: CGFloat = 10
    @State private var animatedRadius: CGFloat = 10
    @State private var scale: CGFloat = 1
    @State private var replyScale: CGFloat = 0
    @State private var baseOffset: [Bool] = Array(repeating: false, count: 4)
    @State private var keyboardHeight: CGFloat = 0
    
    // dragging/gestures
    @State private var isDragging: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var dragScale: [CGFloat] = Array(repeating: 1, count: 4)
    let dragThreshold: CGFloat = 1.2
    @State private var engine: CHHapticEngine?
    
    // forms/inputs
    @State private var textColor: Color = .white
    @State private var searchText = ""
    @State private var formText = ""
    @State private var replyText = ""
    @Binding var selectedTab: Int
    @State private var rating: Int = 1 // 2 default for wisp
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    let entryAPI = EntryAPI()
    
    @Namespace private var namespace

    var body: some View {
        ZStack {
            let circleSize = 72.0
            
            if uiState == .notifications {
                NotificationList(uiState: $uiState)
            }
            
            if uiState == .searching {
                SearchResultsList(path: $path, uiState: $uiState, searchText: $searchText, keyboardHeight: $keyboardHeight)
            }
            
            // morphing shape
            ShapeMorphing(color: .black)
                .background {
                    Rectangle()
                        .fill(Color(UIColor.systemGray6))
                        .mask {
                            Canvas { ctx, size in
                                ctx.addFilter(.alphaThreshold(min: 0.5))
                                ctx.addFilter(.blur(radius: animatedRadius))
                                
                                ctx.drawLayer { ctx1 in
                                    for index in 0 ..< 3 {
                                        if let resolvedShareButton = ctx.resolveSymbol(id: index) {
                                            ctx1.draw(resolvedShareButton, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                        }
                                    }
                                }
                            } symbols: {
                                GroupedBlobs(size: circleSize, fillColor: true)
                                    .offset(y: -keyboardHeight)
                                    .animation(.spring(), value: keyboardHeight)
                            }
                        }
                }
                .allowsHitTesting(false)
            
            GroupedBlobs(size: circleSize, fillColor: false)
                .offset(y: -keyboardHeight)
                .animation(.spring(), value: keyboardHeight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: searchText) { _, newValue in
            if !newValue.isEmpty {
                updateUIForState(.searching)
            }
        }
        .onChange(of: navManager.selectedSound) { _, newValue in
            if newValue != nil {
                updateUIForState(.form)
            }
        }
        .onChange(of: navManager.isViewingEntry) { _, newValue in
            updateUIForState(.collapsed)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.spring()) {
                    self.keyboardHeight = keyboardFrame.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.spring()) {
                self.keyboardHeight = 0
            }
        }
    }
    
    
    func updateUIForState(_ state: UIState) {
        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.9, blendDuration: 0.4)) {
            switch state {
            case .collapsed: // hide blobs
                uiState = .collapsed
                navManager.isExpanded = false
                scale = navManager.isViewingEntry ? 0.5 : 1
                replyScale = navManager.isViewingEntry ? 0.5 : 0.01
                baseOffset = navManager.isViewingEntry ? [false, false, false, true] : Array(repeating: false, count: 4)
            case .expanded: // show blobs
                uiState = .expanded
                navManager.isExpanded = true
                scale = 0.75
                replyScale = 0.01
                baseOffset = Array(repeating: true, count: 4)
            case .search: // show search bar
                uiState = .search
                navManager.isExpanded = false
                scale = 0.5
                replyScale = 0.01
                baseOffset = [true, false, false, false]
            case .searching: // show search bar and results
                uiState = .searching
                navManager.isExpanded = false
                scale = 0.5
                replyScale = 0.01
                baseOffset = [true, false, false, false]
            case .form: // show form (search bar + art)
                uiState = .form
                navManager.isExpanded = false
                scale = 0.5
                replyScale = 0.01
                baseOffset = [true, false, false, false]
            case .profile:
                uiState = .profile
                navManager.isExpanded = false
                scale = 0.5
                baseOffset = [false, false, false, false]
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectedTab = 2
                }
            case .notifications:
                uiState = .notifications
                navManager.isExpanded = false
                scale = 0.5
                replyScale = 0.01
                baseOffset = [false, false, false, false]
            case .replying:
                uiState = .replying
                navManager.isExpanded = false
                scale = 0.5
                replyScale = 1
                baseOffset = [false, false, false, true]
            }
        }
    }
}


// MARK: Blob Builders
extension NavView {
    @ViewBuilder
    func GroupedBlobs(size: CGFloat, fillColor: Bool = true) -> some View {
        Group {
            let searchXOffset = uiState == .searching || uiState == .search || uiState == .form ? (-size * 1.5) + 36 : -size * 1.5
            let searchYOffset = uiState == .searching || uiState == .search || uiState == .form ? -14 : 0.0
            let searchWidth = uiState == .searching || uiState == .search || uiState == .form ? 312 : size
            let searchHeight = uiState == .form ? 372: uiState == .searching || uiState == .search ? 48 : size
            let searchRadius = uiState == .form ? 32 : uiState == .searching || uiState == .search ? 18 : size / 2
            
            let replySize = size / 2
            let replyWidth = uiState == .replying ? 326 : replySize
            let replyHeight = uiState == .replying ?  40 : replySize
            let replyRadius = uiState == .replying ?  20 : replySize
            
            ReplyBlob(size: replySize,
                      tag: 3,
                      cornerRadius: replyRadius,
                      width: replyWidth, 
                      height: replyHeight
            )
            .shadow(radius: 8)
            .offset(x: baseOffset[3] ? -size * 0.9 : 0,
                    y: baseOffset[3] ? -size * 0.7 : 0)
            .scaleEffect(dragScale[3], anchor: .bottomTrailing)
            
            SearchBlob(size: size,
                       tag: 0,
                       cornerRadius: searchRadius,
                       width: searchWidth,
                       height: searchHeight
            )
            .shadow(radius: 2)
            .scaleEffect(dragScale[0], anchor: .center)
            .offset(x: baseOffset[0] ? searchXOffset : 0, y: searchYOffset)
            
            ProfileBlob(size: size,
                        tag: 1
            )
            .scaleEffect(dragScale[1], anchor: .center)
            .offset(x: baseOffset[1] ? -size : 0, y: baseOffset[1] ? -size : 0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        withAnimation {
                            isDragging = true
                            
                            dragOffset = value.translation

                            let dragDistanceX = value.translation.width
                            let dragDistanceY = value.translation.height
                            let scaleFactorX = 1 + min(abs(dragDistanceX) / size, 0.2)
                            let scaleFactorY = 1 + min(abs(dragDistanceY) / size, 0.2)
                            
                            if dragDistanceX < 0 && dragDistanceY < 0 {
                                // Dragging in the top-left corner
                                dragScale[1] = max(scaleFactorX, scaleFactorY)
                                dragScale[0] = 1
                                dragScale[2] = 1
                            } else if dragDistanceX < 0 {
                                // Dragging to the left blob
                                dragScale[0] = scaleFactorX
                                dragScale[1] = 1
                                dragScale[2] = 1
                            } else if dragDistanceY < 0 {
                                // Dragging to the top blob
                                dragScale[2] = scaleFactorY
                                dragScale[0] = 1
                                dragScale[1] = 1
                            } else {
                                dragScale[0] = 1
                                dragScale[1] = 1
                                dragScale[2] = 1
                            }
                        }
                    }
                    .onEnded { value in
                        withAnimation {
                            isDragging = false
                            dragOffset = .zero
                            
                            if dragScale[1] >= dragThreshold {
                                // Dragged to the top-left corner
                                playHapticFeedback(intensity: 0.7, sharpness: 0.5)
                                updateUIForState(.profile)
                            } else if dragScale[0] >= dragThreshold {
                                playHapticFeedback(intensity: 0.7, sharpness: 0.5)
                                updateUIForState(.searching)
                            } else if dragScale[2] >= dragThreshold {
                                playHapticFeedback(intensity: 0.7, sharpness: 0.5)
                                updateUIForState(.notifications)
                            } else {
                                // Neither blob is scaled/selected, collapse the blobs
                                updateUIForState(.collapsed)
                                if (selectedTab != 0){
                                    selectedTab = 0
                                }
                            }
                            
                            dragScale = Array(repeating: 1, count: 4)
                        }
                    }
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.01)
                    .onEnded { _ in
                        playHapticFeedback(intensity: 0.3, sharpness: 0.9)
                        updateUIForState(.expanded)
                    }
            )
            
            NotifBlob(size: size,
                      tag: 2
            )
            .scaleEffect(dragScale[2], anchor: .center)
            .offset(x: 0, y: baseOffset[2] ? -size * 1.5 : 0)
        }
        .foregroundColor(fillColor ? .black : .clear) // buttons visibility
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding([.leading, .trailing, .bottom], 16)
        .animationProgress(endValue: radius) { value in
            animatedRadius = value
            
            if value >= 12 {
                withAnimation(.easeInOut(duration: 0.4)) {
                    radius = 10
                }
            }
        }
    }
    
    @ViewBuilder
    func NotifBlob(
        size: CGFloat,
        tag: Int
    ) -> some View {
        Circle()
            .frame(width: size, height: size)
            .scaleEffect(scale, anchor: .center)
            .tag(tag)
    }
    
    @ViewBuilder
    func ProfileBlob(
        size: CGFloat,
        tag: Int
    ) -> some View {
        Circle()
            .frame(width: size, height: size)
            .overlay(
                ZStack {
                    if uiState == .form {
                        Button(action: submitEntry) {
                            Circle()
                                .overlay(
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(formText.isEmpty ? .gray : .white)
                                )
                                .frame(width: 40, height: 40)
                        }
                        .disabled(formText.isEmpty || isSubmitting)
                    } else {
                        AsyncImage(url: URL(string: user.image)!) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        } placeholder: {
                            Color.clear
                        }
                    }
                }
                .frame(width: 40, height: 40)
                .shadow(color: .black, radius: 24, x: 0, y: 0)
                .opacity(1)
            )
            .scaleEffect(scale)
            .tag(tag)
    }
    
    @ViewBuilder
    func SearchBlob(
        size: CGFloat,
        tag: Int,
        cornerRadius: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        let placeholder = switch rating {
            case 2:
                "360 characters"
            case 1:
                "720 characters"
            default:
                "720 characters"
        }
        
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                if let selectedSound = navManager.selectedSound {
                       FormArtworkView(soundData: selectedSound)
                           .padding(.vertical, 40)
                   }
                
                HStack() {
                   ZStack {
                       if uiState == .form {
                           Image(systemName: "pencil.circle.fill")
                               .font(.system(size: 16))
                               .foregroundColor(.gray)
                       } else {
                           Image(systemName: "magnifyingglass")
                               .foregroundColor(.gray)
                       }
                   }
                   .padding(.leading, 16)

                ZStack {
                    TextField(uiState == .form ? "Artifact" : "Search", text: uiState == .form ? $formText : $searchText, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(textColor)
                        .font(.system(size: 15))
                        .transition(.opacity)
                        .lineLimit(8)
                        .onChange(of: formText) { _ , _ in
                            updateTextColor()
                        }
                        .frame(minHeight: 48)
                    }
                }
            }
//            .padding(.horizontal, 16)
            .scaleEffect(uiState == .searching || uiState == .search || uiState == .form ? 1 : 0.2)
            .opacity(uiState == .searching || uiState == .search || uiState == .form ? 1 : 0)
            .blur(radius: uiState == .searching || uiState == .search || uiState == .form ? 0 : 8)
            .frame(alignment: .bottom)
        }
        .frame(width: width, height: uiState == .form ? nil : height, alignment: .bottom)
        .background(Color(UIColor.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .scaleEffect(uiState == .searching || uiState == .search || uiState == .form ? 1 : scale)
        .tag(tag)
    }
    
    @ViewBuilder
    func ReplyBlob(
        size: CGFloat,
        tag: Int,
        cornerRadius: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // put a reply sound here
                //
                HStack {
                    // attach a sound to the reply
                    Button {
                        updateUIForState(.search)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 12))
                            .foregroundColor(Color.secondary)
                            .frame(width: 24, height: 24)
                            .background(Color(UIColor.systemGray5))
                            .clipShape(Circle())
                    }
                    
                    TextField("Reply...", text: $replyText, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(textColor)
                        .font(.system(size: 15))
                        .transition(.opacity)
                        .lineLimit(8)
                        .onChange(of: formText) { _ , _ in
                            updateTextColor()
                        }
                        .frame(minHeight: 16)
                        .padding(.vertical, 12)
                }
                .padding(.leading, 12)
                .padding(.trailing, 16)
            }
            .scaleEffect(uiState == .replying ? 1 : 0.2)
            .opacity(uiState == .replying ? 1 : 0)
            .blur(radius: uiState == .replying ? 0 : 10)
            .frame(alignment: .bottom)
        }
        .frame(width: width, height: uiState == .replying ? nil : height, alignment: .bottom)
        .background(Color(UIColor.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 12, height: 12)
                .offset(x: 0, y: 0),
            alignment: .bottomTrailing
        )
        .overlay(
            Circle()
                .fill(Color(uiColor: .systemGray6))
                .frame(width: 6, height: 6)
                .offset(x: 8, y: 2),
            alignment: .bottomTrailing
        )
        .scaleEffect(replyScale, anchor: .bottomTrailing)
        .tag(tag)
        .onTapGesture {
            updateUIForState(uiState == .replying ? .collapsed : .replying)
        }
    }
}

//withAnimation(.easeInOut(duration: 0.4)) {
//    radius = 20
//} might need for expand

// MARK: Function Helpers
extension NavView {
    // character limit reached
    private func updateTextColor() {
        let maxCount = rating == 2 ? 320 : 240
        let currentCount = uiState == .form ? formText.count : searchText.count
        textColor = currentCount >= maxCount ? .red : .white
    }
    
    func playHapticFeedback(intensity: Float, sharpness: Float) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self.engine = try CHHapticEngine()
            try engine?.start()

            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ], relativeTime: 0)

            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic feedback: \(error.localizedDescription)")
        }
    }
    
    private var maxCharacterCount: Int {
        rating == 2 ? 360 : 720
    }
    
    private func submitEntry() {
        guard let selectedSound = navManager.selectedSound else {
            alertMessage = "No sound selected."
            showAlert = true
            return
        }
        
        isSubmitting = true
        
        Task {
            do {
                let response = try await entryAPI.submitEntry(
                    userId: user.id,
                    text: formText,
                    appleData: selectedSound,
                    rating: rating,
                    soundId: nil
                )
                
                DispatchQueue.main.async {
                    isSubmitting = false
                    if response.success {
                        alertMessage = "Entry submitted successfully!"
                        formText = ""
                        navManager.selectedSound = nil
                    } else {
                        alertMessage = "Failed to submit entry."
                    }
                    showAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    isSubmitting = false
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

