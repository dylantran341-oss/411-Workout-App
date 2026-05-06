import SwiftUI

// Data Models
struct ExerciseSet: Identifiable, Equatable {
    let id = UUID()
    var weight: String = ""
    var reps: String = ""
}

struct WorkoutExercise: Identifiable, Equatable {
    let id = UUID()
    var name: String = ""
    var sets: [ExerciseSet] = [ExerciseSet()]
}

// Main View
struct WorkoutView: View {
    @State private var exercises: [WorkoutExercise] = [WorkoutExercise()]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                ForEach($exercises) { $exercise in
                    
                    let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }) ?? 0
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Header Row
                        HStack {
                            Text("Exercise \(exerciseIndex + 1)")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            // Delete Exercise Button
                            Button(action: {
                                exercises.removeAll { $0.id == exercise.id }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .padding(4)
                            }
                        }
                        
                        // Exercise Name Input
                        TextField("Exercise Name (e.g. Squat)", text: $exercise.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        // Column Headers for the Sets
                        HStack {
                            Text("Set")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .frame(width: 40)
                            Spacer()
                            Text("Lbs")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .frame(width: 80)
                            Spacer()
                            Text("Reps")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                                .frame(width: 80)
                            Spacer()
                            Text("")
                                .frame(width: 30)
                        }
                        .padding(.horizontal, 8)
                        
                        ForEach($exercise.sets) { $set in
                            
                            let setIndex = exercise.sets.firstIndex(where: { $0.id == set.id }) ?? 0
                            
                            HStack {
                                // Set Number Indicator
                                Text("\(setIndex + 1)")
                                    .fontWeight(.bold)
                                    .frame(width: 40, height: 36)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                
                                Spacer()
                                
                                // Weight Input
                                TextField("-", text: $set.weight)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 80, height: 36)
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                
                                Spacer()
                                
                                // Reps Input
                                TextField("-", text: $set.reps)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 80, height: 36)
                                    .background(Color(UIColor.systemBackground))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                
                                Spacer()
                                
                                // Delete Set Button
                                Button(action: {
                                    exercise.sets.removeAll { $0.id == set.id }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                        .frame(width: 30)
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                        
                        // Add Set Button
                        Button(action: {
                            exercise.sets.append(ExerciseSet())
                        }) {
                            Text("+ Add Set")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 3)
                }
                
                // Add Exercise Button
                Button(action: {
                    exercises.append(WorkoutExercise())
                }) {
                    HStack {
                        Image(systemName: "plus.app.fill")
                        Text("Add Exercise")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(radius: 3)
                }
                
                // Finish Workout Button
                Button(action: {
                }) {
                    Text("Finish Workout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
                .padding(.top, 10)
                
            }
            .padding()
        }
        .navigationTitle("Workout Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutView()
    }
}
