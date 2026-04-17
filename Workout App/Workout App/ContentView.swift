import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                NavigationLink(destination: WorkoutBuilderView()) {
                    HomeButtonView(title: "Workout Builder", color: .blue)
                }
                
                NavigationLink(destination: WorkoutView()) {
                    HomeButtonView(title: "Workout", color: .green)
                }
                
                NavigationLink(destination: StrengthTrackerView()) {
                    HomeButtonView(title: "Strength Tracker", color: .orange)
                }
                
                NavigationLink(destination: ExerciseGalleryView()) {
                    HomeButtonView(title: "Exercise Gallery", color: .purple)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
