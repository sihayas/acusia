//
//  OtherContents.swift
//  iOS18PhotosAppUI
//
//  Created by Xiaofu666 on 2024/7/21.
//

import SwiftUI

struct MiddleScrollView: View {
    let size: CGSize
    let safeArea: EdgeInsets
    
    var body: some View {
        VStack() {
            Spacer()
                .frame(height: size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: size.height)
    }
}
