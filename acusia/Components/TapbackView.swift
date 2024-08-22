//
//  TapbackView.swift
//  acusia
//
//  Created by decoherence on 7/6/24.
//
import SwiftUI

struct HeartTap: View {
    let isTapped: Bool
    let count: Int
    
    var body: some View {
        ZStack {
            Text("99")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.secondary)
                .padding(6)
                .background(
                    Capsule()
                        .fill(Color(UIColor.systemGray6))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.black, lineWidth: 1)
                )
                .offset(x: -20, y: -18)
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 28))
                .overlay(
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                            .offset(x: -2, y: -2)
                        Circle()
                            .fill(.white)
                            .frame(width: 4, height: 4)
                            .offset(x: 4, y: 4)
                    },
                    alignment: .bottomTrailing
                )
        }
    }
}

struct FlameTap: View {
    let isTapped: Bool
    let count: Int
    
    var body: some View {
        ZStack {
            Text("99")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.secondary)
                .padding(6)
                .background(
                    Capsule()
                        .fill(Color(UIColor.systemGray6))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.black, lineWidth: 1)
                )
                .offset(x: -20, y: -18)
            Image(systemName: "flame.circle.fill")
                .font(.system(size: 28))
                .overlay(
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                            .offset(x: -2, y: -2)
                        Circle()
                            .fill(.white)
                            .frame(width: 4, height: 4)
                            .offset(x: 4, y: 4)
                    },
                    alignment: .bottomTrailing
                )
        }
    }
}


struct ThumbsDownTap: View {
    let isTapped: Bool
    let count: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 36, height: 36)
                .overlay(
                    Text("1")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.secondary)
                )
                .offset(x: 22, y: -22)
            Circle()
                .fill(Color.black)
                .frame(width: 37, height: 37)
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 36, height: 36)
            Image(systemName: "hand.thumbsdown.fill")
                .foregroundColor(.gray)
                .font(.system(size: 16))
                .shadow(radius: 1)
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 8, height: 8)
                .offset(x: 9 + 4, y: 9 + 4)
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 4, height: 4)
                .offset(x: 16 + 4, y: 16 + 4)
        }
    }
}

struct SidewaysEyesTap: View {
    let isTapped: Bool
    let count: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 36, height: 36)
                .overlay(
                    Text("1")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.secondary)
                )
                .offset(x: 22, y: -22)
            Circle()
                .fill(Color.black)
                .frame(width: 37, height: 37)
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 36, height: 36)
            Image(systemName: "eyes.inverse")
                .foregroundColor(.gray)
                .font(.system(size: 16))
                .shadow(radius: 1)
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 8, height: 8)
                .offset(x: 9 + 4, y: 9 + 4)
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 4, height: 4)
                .offset(x: 16 + 4, y: 16 + 4)
        }
    }
}



