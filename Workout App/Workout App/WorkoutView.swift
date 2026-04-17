import SwiftUI

struct WorkoutView: View {
    var body: some View {
        VStack {
            Text("Workout")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            HStack{
                VStack(alignment: .leading){
                    Text("Exercise1")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\texercise information will go here")
                }
                Spacer()
            }
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    WorkoutView()
}
