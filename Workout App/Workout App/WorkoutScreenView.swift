import SwiftUI
import CoreData
import Charts

struct WorkoutScreenView: View {
    // Environment Variables
    
    // Connects to live Core Data database to save or fetch data
    @Environment(\.managedObjectContext) var context
    
    // Allow to close this screen and go back to the previous one
    @Environment(\.dismiss) var dismiss
    
    // Incoming Data
    
    // The specific workout plan passed in from the SelectWorkoutScreenView
    var plan: Plans? = nil
    
    // State Variables
    
    // Holds the "Blueprints" (Joins) that tell which exercises belong to this plan
    @State private var joins: [Join] = []
    
    // Holds the actual "Log Folders" for today's workout
    @State private var Elogs: [Exercise_log] = []
    
    // 2D array to add a new set to a specific exercise
    @State private var setsPerExercise: [[Set_log]] = []

    // User Interface
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // 1. Outer Loop: Go through every exercise in today's plan
                ForEach(Array(joins.enumerated()), id: \.offset) { i, join in
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // --- HEADER ROW ---
                        HStack {
                            // Display the name of the exercise
                            Text(join.exercise?.name ?? "Unknown Exercise")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer() // Pushes the text left and the button right
                            
                            // --- ADD SET BUTTON ---
                            Button(action: {
                                // Step A: Create a brand new Set in the database
                                let newSet = Set_log(context: context)
                                
                                // Step B: Link this new set to the correct Exercise Log folder
                                newSet.date = Elogs[i]
                                
                                // Step C: Put the set into the correct bucket in our 2D array.
                                setsPerExercise[i].append(newSet)
                            }) {
                                Label("Add set", systemImage: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Divider() // A visual line separating the header from the sets
                        
                        // --- THE SETS LIST ---
                        // Make sure our 2D array actually has a bucket for this exercise yet
                        if setsPerExercise.indices.contains(i) {
                            
                            // 2. Inner Loop: Go through every set inside this specific exercise's bucket
                            ForEach(setsPerExercise[i].indices, id: \.self) { setIndex in
                                HStack {
                                    // Set Number
                                    Text("Set \(setIndex + 1)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .frame(width: 55, alignment: .leading)
                                    
                                    Spacer()
                                    
                                    // Weight Input
                                    Text("lbs:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    // Binds the text field directly to that exact set in Core Data
                                    TextField("0", text: $setsPerExercise[i][setIndex].wrapped_weight)
                                        .keyboardType(.numberPad) // Only show numbers on the keyboard
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 60)
                                    
                                    // Reps Input
                                    Text("reps:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("0", text: $setsPerExercise[i][setIndex].wrapped_reps)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 60)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6)) // Light gray background for the exercise card
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2) // Slight drop shadow
                }
            }
            .padding()
            
            // --- FINISH BUTTON ---
            Button(action: {
                // Permanently save all the typing the user just did to the hard drive
                try? context.save()
                
                // Automatically close this screen and go back to the menu
                dismiss()
            }) {
                Text("FINISH WORKOUT")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("Workout Tracker")
        .navigationBarTitleDisplayMode(.inline)
        
        // When the screen first opens, run the loadJoins function to build the UI
        .onAppear(perform: loadJoins)
        
        // Hide keyboard if the user taps anywhere on the background
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // Data Loading Engine
    
    // Reads the chosen plan, creates the database logs for today, and sets up the 2D array
    private func loadJoins() {
        guard let plan = plan else { return } // If no plan was passed in, stop immediately
        
        // Prevent accidental re-loading
        guard joins.isEmpty else { return }
        
        // Setup a database search for all 'Joins' attached to this specific Plan name
        let request: NSFetchRequest<Join> = Join.fetchRequest()
        request.predicate = NSPredicate(format: "workout.name == %@", plan.name ?? "")
        
        do {
            // Execute the search
            let fetchedJoins = try context.fetch(request)
            self.joins = fetchedJoins
            
            // Loop through the blueprints
            for join in fetchedJoins {
                
                // 1. Create a master log for this exercise for today
                let elog = Exercise_log(context: context)
                elog.exercise = join.exercise
                elog.date = Date() // Stamps it with today's date
                Elogs.append(elog)
                
                // 2. Look at the blueprint to see how many sets the user planned to do
                var initialSets: [Set_log] = []
                for _ in 0..<Int(join.sets) {
                    
                    // Create those blank sets and attach them to the master log
                    let slog = Set_log(context: context)
                    slog.date = elog
                    initialSets.append(slog)
                }
                
                // 3. Put those blank sets into 2D array so the UI can draw the text fields
                setsPerExercise.append(initialSets)
            }
        } catch {
            print("Error loading Joins: \(error.localizedDescription)")
        }
    }
}
