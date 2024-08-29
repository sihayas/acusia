import SwiftUI

struct ArtifactView: View {
    let entry: APIEntry
    let animateReplySheet: Bool
    
    var body: some View {
        let imageUrl = entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "720").replacingOccurrences(of: "{h}", with: "720") ?? "https://picsum.photos/300/300"
        
        let width: CGFloat = animateReplySheet ? 56 : 164
        let height: CGFloat = animateReplySheet ? 56 : 164
        
        HStack(alignment: .bottom, spacing: 0) {
            AvatarView(size: 32, imageURL: entry.author.image)
            
            VStack(alignment: .leading, spacing: 8) {
                // Sound attachment
                VStack(alignment: .leading) {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .mask(
                                Image("mask")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            )
                            .overlay(
                                MyIcon()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    .frame(width: width, height: height)
                            )
                            .overlay(
                                Image("heartbreak")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(-6))
                                    .padding(8)
                                    .scaleEffect(animateReplySheet ? 0.3 : 1, anchor: .bottomLeading)
                                ,
                                alignment: .bottomLeading
                            )
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.gray)
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .frame(width: width, height: height, alignment: .topLeading)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                
                // Text bubble
                ZStack(alignment: .bottomLeading) {
                    Circle()
                        .stroke(animateReplySheet ? .white.opacity(0.1): .clear , lineWidth: 1)
                        .fill(animateReplySheet ? .clear : Color(UIColor.systemGray6))
                        .frame(width: 12, height: 12)
                        .offset(x: 0, y: 0)
                    
                    Circle()
                        .stroke(animateReplySheet ? .white.opacity(0.1): .clear , lineWidth: 1)
                        .fill(animateReplySheet ? .clear : Color(UIColor.systemGray6))
                        .frame(width: 6, height: 6)
                        .offset(x: -8, y: 2)
                    
                    VStack {
                        Text(entry.text)
                            .foregroundColor(.white)
                            .font(.system(size: animateReplySheet ? 11 : 15, weight: .regular))
                            .multilineTextAlignment(.leading)
                            .transition(.blurReplace)
                            .lineLimit(animateReplySheet ? 3 : nil)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(animateReplySheet ? .black : Color(UIColor.systemGray6),
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color(UIColor.systemGray6).opacity(animateReplySheet ? 1 : 0), lineWidth: 1)
                    )
                    .overlay(
                        ZStack {
                            HeartTap(isTapped: entry.isHeartTapped, count: entry.heartCount)
                                .offset(x: 12, y: -26)
                                .scaleEffect(animateReplySheet ? 0.75 : 1)
                        },
                        alignment: .topTrailing
                    )
                }
                
            }
            .padding([.leading], 12)
            .padding([.bottom], 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}
