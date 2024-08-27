//
//  Reply.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//
import SwiftUI

struct BottomCurvePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top center
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))

        // Draw the vertical line downwards, leaving space for the curve
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - rect.width / 2))

        // Draw the rounded corner curve to the right center
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                          control: CGPoint(x: rect.midX, y: rect.maxY))

        return path
    }
}

struct TopBottomCurvePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top center
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))

        // Draw the top curve to the right
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + rect.width / 2),
                          control: CGPoint(x: rect.maxX, y: rect.minY))

        // Draw the vertical line downwards, leaving space for the bottom curve
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - rect.width / 2))

        // Draw the bottom curve to the left
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                          control: CGPoint(x: rect.maxX, y: rect.maxY))

        return path
    }
}

// Helper function to calculate avatar offsets
func tricornOffset(for index: Int, radius: CGFloat = 12) -> CGSize {
    switch index {
    case 0: // Top Center
        return CGSize(width: 0, height: -radius)
    case 1: // Bottom Left
        return CGSize(width: -radius * cos(.pi / 6), height: radius * sin(.pi / 6))
    case 2: // Bottom Right
        return CGSize(width: radius * cos(.pi / 6), height: radius * sin(.pi / 6))
    default:
        return .zero
    }
}

struct MyIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.5*width, y: 0.95*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.75*height))
        path.addCurve(to: CGPoint(x: 0.20953*width, y: 0.26027*height), control1: CGPoint(x: 0.5*width, y: 0.51429*height), control2: CGPoint(x: 0.36032*width, y: 0.26027*height))
        path.addCurve(to: CGPoint(x: 0.03333*width, y: 0.50961*height), control1: CGPoint(x: 0.05874*width, y: 0.26027*height), control2: CGPoint(x: 0.03333*width, y: 0.41697*height))
        path.addCurve(to: CGPoint(x: 0.20956*width, y: 0.74652*height), control1: CGPoint(x: 0.03333*width, y: 0.60226*height), control2: CGPoint(x: 0.06435*width, y: 0.74652*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.25*height), control1: CGPoint(x: 0.3771*width, y: 0.74652*height), control2: CGPoint(x: 0.5*width, y: 0.50267*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.05*height))
        return path
    }
}

struct CommentView: View {
    let comment: Comment
    @State private var showReplies: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let parent = comment.parent {
                Capsule()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 4, height: 12)
                    .frame(width: 40)
                // Loop + context
                HStack(spacing: -8) {
                    MyIcon()
                        .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 30, height: 20)
                        .frame(width: 40)
                    
                    HStack {
                        AvatarView(size: 12, imageURL: parent.avatarURL)
                        
                        Text(parent.username)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack(alignment: .bottom, spacing: 0) {
                // Thread
                VStack() {
                    Capsule()
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 4, height: .infinity)
                    
                    AvatarView(size: 32, imageURL: comment.avatarURL)
                        .padding(.horizontal, 4)
                }
                
                // Text bubble
                ZStack(alignment: .bottomLeading) {
                    Circle()
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 12, height: 12)
                        .offset(x: 0, y: 0)
                    
                    Circle()
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 6, height: 6)
                        .offset(x: -8, y: 2)
                    
                    Text(comment.text ?? "")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .regular))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding([.leading], 12)
                .padding([.bottom], 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


class Comment: Identifiable {
    let id = UUID()
    let username: String
    let text: String?
    let avatarURL: String
    var parent: Comment?

    init(username: String, text: String? = nil, avatarURL: String, parent: Comment? = nil) {
        self.username = username
        self.text = text
        self.avatarURL = avatarURL
        self.parent = parent
    }
}

let sampleComments: [Comment] = [
    Comment(
        username: "johnnyD",
        text: "fr this is facts",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Comment(
        username: "janey",
        text: "omg thank u johnny lol we gotta talk about this more",
        avatarURL: "https://picsum.photos/200/200",
        parent: Comment(
            username: "johnnyD",
            avatarURL: "https://picsum.photos/200/200"
        )
    ),
    Comment(
        username: "mikez",
        text: "idk janey i feel like it’s different tho can u explain more",
        avatarURL: "https://picsum.photos/200/200",
        parent: Comment(
            username: "janey",
            avatarURL: "https://picsum.photos/200/200"
        )
    ),
    Comment(
        username: "janey",
        text: "mike i get u but it’s like the bigger picture ykmike i get u but it’s like the bigger picture ykmike i get u but it’s like the bigger picture yk",
        avatarURL: "https://picsum.photos/200/200",
        parent: Comment(
            username: "mikez",
            avatarURL: "https://picsum.photos/200/200"
        )
    ),
    Comment(
        username: "sarah_123",
        text: "yeah janey got a point tho",
        avatarURL: "https://picsum.photos/200/200",
        parent: Comment(
            username: "janey",
            avatarURL: "https://picsum.photos/200/200"
        )
    ),
    Comment(
        username: "johnnyD",
        text: "lowkey agree with sarah",
        avatarURL: "https://picsum.photos/200/200",
        parent: Comment(
            username: "sarah_123",
            avatarURL: "https://picsum.photos/200/200"
        )
    ),
    Comment(
        username: "mikez",
        text: "ok i see it now",
        avatarURL: "https://picsum.photos/200/200",
        parent: Comment(
            username: "johnnyD",
            avatarURL: "https://picsum.photos/200/200"
        )
    ),
    Comment(
        username: "janey",
        text: "glad we’re all on the same page now lol",
        avatarURL: "https://picsum.photos/200/200",
        parent: Comment(
            username: "mikez",
            avatarURL: "https://picsum.photos/200/200"
        )
    )
]
