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
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(count))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.secondary)
                )
                .offset(x: -22, y: -22)
            Circle()
                .fill(Color.black)
                .frame(width: 37, height: 37)
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 8, height: 8)
                .offset(x: 13, y: 13)
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 4, height: 4)
                .offset(x: 18, y: 18)
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 36, height: 36)
            Image(systemName: "heart.fill")
                .foregroundColor(isTapped ? .pink : .gray)
                .font(.system(size: 16))
                .shadow(radius: 1)
        }
    }
}

struct FlameTap: View {
    let isTapped: Bool
    let count: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.black)
                .frame(width: 37, height: 37)
                .offset(x: 22, y: -22)
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(count))
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
            Image(systemName: "flame.fill")
                .foregroundColor(isTapped ? .orange : .gray)
                .font(.system(size: 16))
                .shadow(radius: 1)
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 8, height: 8)
                .offset(x: 13, y: 13)
            Circle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: 4, height: 4)
                .offset(x: 20, y: 20)
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



