import SwiftUI

struct HomeButtonView: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 3)
    }
}

#Preview {
    HomeButtonView(title: "Sample Button", color: .blue)
}
