//
//  CollageLayout.swift
//  acusia
//
//  Created by OpenAI on 10/12/24.
//

import SwiftUI

struct CollageLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // Accept the full proposed space, replacing any nil values with a sensible default
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let count = subviews.count

        switch count {
        case 1:
            let subview = subviews[0]
            let size = CGSize(width: bounds.width, height: bounds.height)
            let proposal = ProposedViewSize(size)
            subview.place(at: CGPoint(x: bounds.midX, y: bounds.midY), anchor: .center, proposal: proposal)
        case 2:
            let subview1 = subviews[0]
            let subview2 = subviews[1]

            let size1 = CGSize(width: bounds.width * 0.60, height: bounds.height * 0.6)
            let size2 = CGSize(width: bounds.width * 0.52, height: bounds.height * 0.52)

            let point1 = CGPoint(x: bounds.minX + size1.width / 2, y: bounds.minY + size1.height / 2)
            let point2 = CGPoint(x: bounds.maxX - size2.width / 2, y: bounds.maxY - size2.height / 2)

            subview1.place(at: point1, anchor: .center, proposal: ProposedViewSize(size1))
            subview2.place(at: point2, anchor: .center, proposal: ProposedViewSize(size2))
        case 3:
            let subview1 = subviews[0]
            let subview2 = subviews[1]
            let subview3 = subviews[2]

            let size1 = CGSize(width: bounds.width * 0.56, height: bounds.height * 0.56)
            let size2 = CGSize(width: bounds.width * 0.48, height: bounds.height * 0.48)
            let size3 = CGSize(width: bounds.width * 0.4, height: bounds.height * 0.4)
            
            let offset2 = size2.height * 0.4
            let offset3 = size3.width * 1.2

            let point1 = CGPoint(x: bounds.minX + size1.width / 2, y: bounds.minY + size1.height / 2)
            let point2 = CGPoint(x: bounds.maxX - size2.width / 2, y: bounds.maxY - size2.height / 2 - offset2)
            let point3 = CGPoint(x: bounds.maxX - size3.width / 2 - offset3, y: bounds.maxY - size3.height / 2)

            subview1.place(at: point1, anchor: .center, proposal: ProposedViewSize(size1))
            subview2.place(at: point2, anchor: .center, proposal: ProposedViewSize(size2))
            subview3.place(at: point3, anchor: .center, proposal: ProposedViewSize(size3))
        case 4:
            let subview1 = subviews[0]
            let subview2 = subviews[1]
            let subview3 = subviews[2]
            let subview4 = subviews[3]

            let size1 = CGSize(width: bounds.width * 0.56, height: bounds.height * 0.56)
            let size2 = CGSize(width: bounds.width * 0.48, height: bounds.height * 0.48)
            let size3 = CGSize(width: bounds.width * 0.4, height: bounds.height * 0.4)
            let size4 = CGSize(width: bounds.width * 0.28, height: bounds.height * 0.28)
            
            let offset2 = size2.height * 0.4
            let offset3 = size3.width * 1.2
            let offset4 = size4.height * 0.4

            let point1 = CGPoint(x: bounds.minX + size1.width / 2, y: bounds.minY + size1.height / 2)
            let point2 = CGPoint(x: bounds.maxX - size2.width / 2, y: bounds.maxY - size2.height / 2 - offset2)
            let point3 = CGPoint(x: bounds.maxX - size3.width / 2 - offset3, y: bounds.maxY - size3.height / 2)
            let point4 = CGPoint(x: bounds.maxX - size4.width / 2 - offset4, y: bounds.minY + size4.height / 2)

            subview1.place(at: point1, anchor: .center, proposal: ProposedViewSize(size1))
            subview2.place(at: point2, anchor: .center, proposal: ProposedViewSize(size2))
            subview3.place(at: point3, anchor: .center, proposal: ProposedViewSize(size3))
            subview4.place(at: point4, anchor: .center, proposal: ProposedViewSize(size4))
            
        case 5:
            let subview1 = subviews[0]
            let subview2 = subviews[1]
            let subview3 = subviews[2]
            let subview4 = subviews[3]
            let subview5 = subviews[4]

            let size1 = CGSize(width: bounds.width * 0.52, height: bounds.height * 0.52)
            let size2 = CGSize(width: bounds.width * 0.44, height: bounds.height * 0.44)
            let size3 = CGSize(width: bounds.width * 0.36, height: bounds.height * 0.36)
            let size4 = CGSize(width: bounds.width * 0.32, height: bounds.height * 0.32)
            let size5 = CGSize(width: bounds.width * 0.2, height: bounds.height * 0.2)
            
            let offset2 = size2.height * 0.4
            let offset3 = size3.width * 1.2
            let offset4 = size4.height * 0.4
            let offset5 = size5.width * 1.2

            let point1 = CGPoint(x: bounds.minX + size1.width / 2, y: bounds.minY + size1.height / 2)
            let point2 = CGPoint(x: bounds.maxX - size2.width / 2, y: bounds.maxY - size2.height / 2 - offset2)
            let point3 = CGPoint(x: bounds.maxX - size3.width / 2 - offset3, y: bounds.maxY - size3.height / 2)
            let point4 = CGPoint(x: bounds.maxX - size4.width / 2 - offset4, y: bounds.minY + size4.height / 2)
            let point5 = CGPoint(x: bounds.minX + size5.width / 2, y: bounds.maxY - size5.height / 2 - offset5)

            subview1.place(at: point1, anchor: .center, proposal: ProposedViewSize(size1))
            subview2.place(at: point2, anchor: .center, proposal: ProposedViewSize(size2))
            subview3.place(at: point3, anchor: .center, proposal: ProposedViewSize(size3))
            subview4.place(at: point4, anchor: .center, proposal: ProposedViewSize(size4))
            subview5.place(at: point5, anchor: .center, proposal: ProposedViewSize(size5))
        default:
            let columns = Int(ceil(sqrt(Double(count))))
            let rows = Int(ceil(Double(count) / Double(columns)))
            let cellWidth = bounds.width / CGFloat(columns)
            let cellHeight = bounds.height / CGFloat(rows)

            for (index, subview) in subviews.enumerated() {
                let row = index / columns
                let column = index % columns
                let x = bounds.minX + CGFloat(column) * cellWidth + cellWidth / 2
                let y = bounds.minY + CGFloat(row) * cellHeight + cellHeight / 2
                let size = CGSize(width: cellWidth * 0.9, height: cellHeight * 0.9)
                subview.place(at: CGPoint(x: x, y: y), anchor: .center, proposal: ProposedViewSize(size))
            }
        }
    }
}

struct ContentView: View {
    @State private var count = 3

    var body: some View {
        CollageLayout {
            ForEach(0..<count, id: \.self) { _ in
                Circle()
                    .fill(Color.white)
            }
        }
        .frame(width: 80, height: 80)
        .safeAreaInset(edge: .bottom) {
            Stepper("Count: \(count)", value: $count.animation(), in: 1...10)
                .padding()
        }
    }
}

#Preview {
    ContentView()
}
