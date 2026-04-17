import SwiftUI

struct ExerciseGalleryView: View {
    var body: some View {
        VStack {
            Text("Exercise Gallery")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("List of exercises will go here.")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ExerciseGalleryView()
}
