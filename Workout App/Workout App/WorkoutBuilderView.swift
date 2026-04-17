import SwiftUI

struct WorkoutBuilderView: View {
    var body: some View {
        VStack {
            Text("Workout Builder")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Building tools will go here.")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    WorkoutBuilderView()
}
