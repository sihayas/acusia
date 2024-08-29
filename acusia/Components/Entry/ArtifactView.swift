import SwiftUI

struct ArtifactView: View {
    let entry: APIEntry
    let showReplies: Bool
    
    var body: some View {
        let imageUrl = entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "720").replacingOccurrences(of: "{h}", with: "720") ?? "https://picsum.photos/300/300"
        
        let width: CGFloat = showReplies ? 24 : 164
        let height: CGFloat = showReplies ? 24 : 164
        
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
                                    .scaleEffect(showReplies ? 0.25 : 1)
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
                    .stroke(showReplies ? .white.opacity(0.1): .clear , lineWidth: 1)
                    .fill(showReplies ? .clear : Color(UIColor.systemGray6))
                    .frame(width: 12, height: 12)
                    .offset(x: 0, y: 0)
                        
                Circle()
                    .stroke(showReplies ? .white.opacity(0.1): .clear , lineWidth: 1)
                    .fill(showReplies ? .clear : Color(UIColor.systemGray6))
                    .frame(width: 6, height: 6)
                    .offset(x: -8, y: 2)
                
                VStack {
                    Text(entry.text)
                        .foregroundColor(.white)
                        .font(.system(size: showReplies ? 11 : 15, weight: .regular))
                        .multilineTextAlignment(.leading)
                        .transition(.blurReplace)
                        .lineLimit(showReplies ? 3 : nil)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(showReplies ? .black : Color(UIColor.systemGray6),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(showReplies ? 0.1 : 0), lineWidth: 1)
                )
                .overlay(
                    ZStack {
                        HeartTap(isTapped: entry.isHeartTapped, count: entry.heartCount)
                            .offset(x: 12, y: -26)
                            .scaleEffect(showReplies ? 0.75 : 1)
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
