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
        Circle()
            .fill(Color(UIColor.systemGray6))
            .frame(width: 36, height: 36)
            .overlay(
                Image(systemName: "heart.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(UIColor.white))
            )
            .overlay(
                Circle()
                    .stroke(Color.black, lineWidth: 1)
            )
            .overlay(
                ZStack {
                    Circle()
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 8, height: 8)
                        .offset(x: 0, y: 0)
                    Circle()
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 4, height: 4)
                        .offset(x: 6, y: 6)
                },
                alignment: .bottomTrailing
            )
    }
}

struct HeartTapSmall: View {
    let isTapped: Bool
    let count: Int

    var body: some View {
        Circle()
            .fill(Color(UIColor.systemGray6))
            .frame(width: 28, height: 28)
            .overlay(
                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.pink)
            )
            .overlay(
                ZStack {
                    Circle()
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 6, height: 6)
                        .offset(x: 0, y: 0)
                    Circle()
                        .fill(Color(UIColor.systemGray6))
                        .frame(width: 3, height: 3)
                        .offset(x: 4, y: 4)
                },
                alignment: .bottomTrailing
            )
            .shadow(color: Color.black.opacity(0.7), radius: 1, x: 0, y: 0)
    }
}

struct FlameTap: View {
    let isTapped: Bool
    let count: Int

    var body: some View {
        Circle()
            .fill(Color(UIColor.systemGray6))
            .frame(width: 36, height: 36)
            .overlay(
                Image(systemName: "flame.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(UIColor(red: 255/255, green: 82/255, blue: 0/255, alpha: 1)))
            )
            .overlay(
                Circle()
                    .stroke(Color.black, lineWidth: 1)
            )
            .overlay(
                Text("999")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .offset(x: 0, y: -26)
            )
    }
}

struct EyesTap: View {
    let isTapped: Bool
    let count: Int

    var body: some View {
        Circle()
            .fill(Color(UIColor.systemGray6))
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: "eyes")
                    .font(.system(size: 16))
                    .foregroundColor(Color(UIColor.blue))
            )
            .overlay(
                Circle()
                    .stroke(Color.black, lineWidth: 1)
            )
            .overlay(
                Text("999")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .offset(x: 0, y: -24)
            )
    }
}
