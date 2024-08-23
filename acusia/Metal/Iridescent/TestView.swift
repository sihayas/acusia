import SwiftUI

struct IridescenceView: View {
    @State private var start = Date()

    var body: some View {
        TimelineView(.animation) { tl in
            let time = start.distance(to: tl.date)
            
            RoundedRectangle(cornerRadius: 32)
                .frame(width: 400, height: 200)
                .shadow(radius: 10)
                .colorEffect(
                    ShaderLibrary.iridescent(
                        .float(time)
                    )
                )
                .overlay(
                    Text("Iridescence")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
                .clipShape(RoundedRectangle(cornerRadius: 32))
        }
        .padding()
    }
}

struct IridescenceView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            IridescenceView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
