import SwiftUI

struct WorkoutView: View {
    var body: some View {
        VStack {
            Text("Workout")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Active workout session will go here.")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    WorkoutView()
}
