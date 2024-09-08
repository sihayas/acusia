//
//  EntryDetailedSheet.swift
//  acusia
//
//  Created by decoherence on 9/8/24.
//

import SwiftUI

struct DetailedEntrySheet: View {
    let entry: APIEntry
    let imageUrl: String

    var body: some View {
        VStack(spacing: 32) {
            VStack {
                AsyncImage(url: URL(string: entry.author.image)) { image in
                    image
                        .resizable()
                } placeholder: {
                    Rectangle()
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                .shadow(radius: 4)

                Text(entry.author.username)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Text(entry.text)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 15, weight: .semibold))
                .multilineTextAlignment(.center)

            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
            } placeholder: {
                Rectangle()
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 204, height: 204)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .shadow(color: Color.black.opacity(0.5), radius: 32, x: 0, y: 16)
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .overlay(alignment: .bottomTrailing) {
                HeartPath()
                    .stroke(.white.opacity(0.1), lineWidth: 1)
                    .fill(.black)
                    .frame(width: 32, height: 30)
                    .frame(width: 32, height: 32)
                    .padding(24)
                    .rotationEffect(.degrees(8))
            }

            VStack {
                Text(entry.sound.appleData?.artistName ?? "Unknown")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.secondary)

                Text(entry.sound.appleData?.name ?? "Unknown")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding([.horizontal], 24)
        .padding([.top], 32)
        .frame(alignment: .top)
    }
}
