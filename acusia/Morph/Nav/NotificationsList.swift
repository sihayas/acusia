//
//  NotificationsList.swift
//  acusia
//
//  Created by decoherence on 7/13/24.
//

import SwiftUI

struct NotificationList: View {
    @Binding var uiState: UIState
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 8) {
                    Spacer().frame(height: geometry.size.height * 0.76)
                    ForEach(0..<10, id: \.self) { index in
                        NotificationCell(index: index, isExpanded: uiState == .notifications)
                    }
                    Spacer()
                }
                .padding()
                .padding(.trailing, 108)
                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.clear)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

//MARK: Notification Cell
struct NotificationCell: View {
    let index: Int
    let isExpanded: Bool
    
    @State private var isVisible = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(UIColor.systemGray6))
            .frame(width: 272, height: 48)
            .overlay(
                HStack {
                    // rounded album art placehlder
                    AsyncImage(url: URL(string: "https://picsum.photos/200/300")!) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    Circle()
                        .fill(Color(UIColor.systemGray3))
                        .frame(width: 4, height: 4)
                    AsyncImage(url: URL(string: "https://picsum.photos/200/300")!) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                    }
                    Text("aritizia")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Image(systemName: "plus")
                        .font(.system(size: 8, weight: .regular))
                        .foregroundColor(.white)
                    Text("400")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                       .font(.system(size: 16))
                }
                .padding(.horizontal, 16)
            )
            .background(Color(UIColor.systemGray6)
                                 .opacity(0.5)
                                 .shadow(color: .black, radius: 6, x: 0, y: 4)
                                 .blur(radius: 8, opaque: false)
                 )
            .scaleEffect(isVisible ? 1 : 0, anchor: .bottomTrailing)
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.05), value: isVisible)
            .onAppear {
                if isExpanded {
                    withAnimation(.easeOut(duration: 0.1).delay(Double(index) * 0.05)) {
                        isVisible = true
                    }
                }
            }
            .onChange(of: isExpanded) {_, newValue in
                withAnimation(.easeOut(duration: 0.1).delay(Double(index) * 0.05)) {
                    isVisible = newValue
                }
            }
    }
}
