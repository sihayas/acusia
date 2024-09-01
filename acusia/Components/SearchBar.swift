//
//  SearchBar.swift
//  acusia
//
//  Created by decoherence on 8/30/24.
//
import SwiftUI

struct SearchBar: View {
   @Binding var searchText: String

   var body: some View {
       HStack {
           Image(systemName: "magnifyingglass")
               .foregroundColor(.secondary)

           ZStack {
               TextField("Index", text: $searchText, axis: .horizontal)
                   .textFieldStyle(PlainTextFieldStyle())
                   .foregroundColor(.white)
                   .font(.system(size: 15))
                   .transition(.opacity)
                   .frame(minHeight: 48)
           }
       }
       .padding(.horizontal, 16)
       .background(.thinMaterial)
       .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
       .overlay(
           RoundedRectangle(cornerRadius: 20, style: .continuous)
               .stroke(Color(UIColor.systemGray5), lineWidth: 1)
       )
       .frame(height: 48)
   }
}
