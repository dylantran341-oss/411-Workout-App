import SwiftUI

struct StrengthTrackerView: View {
    var body: some View {
        VStack {
            Text("Strength Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Charts and history will go here.")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    StrengthTrackerView()
}
