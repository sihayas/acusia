//
//  Reply.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//
import SwiftUI

struct RoundedCornerPath: Shape {
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

struct RoundedCornerPathWithTopCurve: Shape {
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

class Comment: Identifiable {
    let id = UUID()
    let username: String
    let text: String?
    let avatarURL: String
    var parent: Comment?

    init(username:String, text: String? = nil, avatarURL: String, parent: Comment? = nil) {
        self.username = username
        self.text = text
        self.avatarURL = avatarURL
        self.parent = parent
    }
}

struct CommentView: View {
    let comment: Comment
    @State private var showReplies: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .trailing, spacing: 8) {
                if let parent = comment.parent {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                            .frame(width: 8, height: 8)
                            .offset(x: 2, y: 2)
                        
                        Circle()
                            .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                            .frame(width: 4, height: 4)
                            .offset(x: 8, y: 4)
                        HStack {
                            AvatarView(size: 16, imageURL: parent.avatarURL)
                            Text(parent.username)
                                .foregroundColor(.white)
                                .font(.system(size: 13, weight: .regular))
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 5)
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color(UIColor.systemGray5), lineWidth: 1))
                        .frame(alignment: .trailing)
                        .background(Color.black)
                    }
                }
                
                HStack(alignment: .bottom, spacing: 0) {
                    AvatarView(size: 32, imageURL: comment.avatarURL)
                    
                    ZStack(alignment: .bottomLeading) {
                        Circle()
                            .fill(Color(UIColor.systemGray6))
                            .frame(width: 12, height: 12)
                            .offset(x: 0, y: 0)
                        
                        Circle()
                            .fill(Color(UIColor.systemGray6))
                            .frame(width: 6, height: 6)
                            .offset(x: -6, y: 4)
                        
                        Text(comment.text ?? "")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .regular))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(UIColor.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .padding([.leading, .bottom], 12)
                }
            }
            
//            if comment.parent != nil {
//                RoundedCornerPathWithTopCurve()
//                    .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
//                    .frame(width: 40)
//            }
        }
        
    }
}

let sampleComments: [Comment] = [
    Comment(
        username: "user_one",
        text: "This is a reply.",
        avatarURL: "https://picsum.photos/200/200"
    ),
    Comment(
        username: "user_two",
        text: "This is a reply.",
        avatarURL: "https://picsum.photos/200/200",
        parent: Comment(
            username: "user_one",
            avatarURL: "https://picsum.photos/200/200"
        )
    ),
]
