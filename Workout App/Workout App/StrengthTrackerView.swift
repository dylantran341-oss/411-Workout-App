import SwiftUI
import CoreData
import Charts

// Data Models

// Holds the date (X-Axis), the total score (Y-Axis), and the specific sets lifted that day.
struct ChartDataPoint: Identifiable {
    var id: Date { date }  // Required by Swift Charts to tell data points apart uniquely
    let date: Date          // The day the workout occurred
    let value: Double       // The calculated score (Sum of Weight * Reps)
    let sets: [Sets]        // The raw Core Data sets, stored so we can display them when tapped
}

struct StrengthTrackerView: View {
    // Core Data Connection
    
    // Connects to the app's live database
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetches all 'Sets' from the database automatically and sort them chronologically
    @FetchRequest(
        entity: Sets.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Sets.routine?.date, ascending: true)],
        animation: .default)
    private var allSets: FetchedResults<Sets>
    
    // User Interface State
    
    // Tracks which exercise the user currently has selected in the top dropdown
    @State private var selectedExercise: String = "Bench Press"
    
    // Tracks the exact ID of the data point the user tapped on.
    @State private var activeDate: Date?
    
    // Hardcoded list of exercises for the UI picker
    let availableExercises = ["Bench Press", "Squat"]
    
    // Data Processing
    
    // Takes the raw Core Data, filters it, calculates the score
    var chartData: [ChartDataPoint] {
        
        // 1. Throw away any sets that don't match the currently selected exercise
        let filteredSets = allSets.filter { ($0.exerciseName ?? "") == selectedExercise }
        
        // 2. Group the remaining sets into buckets by Day.
        var groupedByDate: [Date: [Sets]] = [:]
        for set in filteredSets {
            if let date = set.routine?.date {
                let startOfDay = Calendar.current.startOfDay(for: date)
                groupedByDate[startOfDay, default: []].append(set)
            }
        }
        
        // 3. Loop through those daily buckets and calculate the score for each day
        var dataPoints: [ChartDataPoint] = []
        for (date, sets) in groupedByDate {
            
            // FORMULA: sum(weight * reps in set 1, weight * reps in set 2, etc)
            let dailySum = sets.reduce(0) { total, currentSet in
                total + (currentSet.weight * Double(currentSet.reps))
            }
            
            // Sort the sets into (Set 1, Set 2)
            let sortedSets = sets.sorted { $0.number < $1.number }
            
            // Add point to our array
            dataPoints.append(ChartDataPoint(date: date, value: dailySum, sets: sortedSets))
        }
        
        // 4. Return the final array sorted from oldest date to newest date so the graph draws left-to-right
        return dataPoints.sorted { $0.date < $1.date }
    }
    
    // A helper variable that quickly grabs the actual data point the user currently has toggled ON
    var activePoint: ChartDataPoint? {
        chartData.first { $0.id == activeDate }
    }

    // User Interface Definition
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // --- EXERCISE SELECTOR ---
                // A segmented toggle at the top of the screen to switch between exercises
                Picker("Exercise", selection: $selectedExercise) {
                    ForEach(availableExercises, id: \.self) { exercise in
                        Text(exercise).tag(exercise)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 10)
                // If the user switches exercises, close the details card automatically
                .onChange(of: selectedExercise) { _ in activeDate = nil }
                
                // --- THE CHART AREA ---
                // If there is no data, show an empty state instead of an empty box
                if chartData.isEmpty {
                    VStack {
                        Spacer()
                        Text("No data available yet.")
                            .foregroundColor(.secondary)
                        Text("Click below to generate mock history.")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Spacer()
                    }
                } else {
                    // Draw the interactive line graph
                    Chart(chartData) { point in
                        // The primary curved line connecting all the workouts
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Score", point.value)
                        )
                        .symbol(Circle()) // Puts a dot on every workout day
                        .interpolationMethod(.catmullRom) // Smooths the line into a curve
                        
                        // The Interactive Cursor: Draws a vertical dashed line IF this point is toggled ON
                        if activeDate == point.date {
                            RuleMark(x: .value("Date", point.date))
                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                    }
                    .frame(height: 300)
                    .padding()
                    
                    // --- THE STICKY TOGGLE LOGIC ---
                    // This creates an invisible layer over the chart to perfectly track user taps
                    .chartOverlay { proxy in
                        GeometryReader { geometry in
                            Rectangle().fill(.clear).contentShape(Rectangle())
                                .onTapGesture { location in
                                    // 1. Find the exact date the user tapped near on the X-Axis
                                    if let tappedDate: Date = proxy.value(atX: location.x) {
                                        // 2. Find the closest actual workout data point to that tap
                                        if let closest = chartData.min(by: { abs($0.date.timeIntervalSince(tappedDate)) < abs($1.date.timeIntervalSince(tappedDate)) }) {
                                            
                                            // 3. Toggle Logic: If it's already open, close it. Otherwise, open it.
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                if activeDate == closest.date {
                                                    activeDate = nil
                                                } else {
                                                    activeDate = closest.date
                                                }
                                            }
                                        }
                                    }
                                }
                        }
                    }
                    
                    // --- THE DETAILS POP-UP CARD ---
                    // If a point is currently toggled ON, display its specific details
                    if let details = activePoint {
                        VStack(alignment: .leading, spacing: 10) {
                            // Header: Date and Total Score
                            HStack {
                                Text(details.date, style: .date)
                                    .font(.headline)
                                Spacer()
                                Text("Score: \(details.value, specifier: "%.0f")")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            
                            Divider()
                            
                            // Body: A ScrollView looping through every set done that day
                            ScrollView {
                                ForEach(details.sets) { set in
                                    HStack {
                                        Text("Set \(set.number)")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("\(set.weight, specifier: "%.1f") lbs  ×  \(set.reps) reps")
                                            .fontWeight(.medium)
                                    }
                                    .padding(.bottom, 2)
                                }
                            }
                            .frame(minHeight: 50, maxHeight: 180) // Keeps the card height contained
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .transition(.opacity) // Smooth fade in/out animation
                    } else {
                        // An invisible placeholder. We keep this here so the UI doesn't visually
                        // jump up and down when the pop-up card appears and disappears.
                        Text("Tap a point to see details")
                            .foregroundColor(.secondary)
                            .frame(height: 150)
                    }
                    
                    Spacer()
                }
                
                // --- TESTING UTILITY BUTTONS ---
                HStack(spacing: 15) {
                    // Button to wipe the database clean
                    Button(action: clearAllData) {
                        Text("Reset Data")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    
                    // Button to inject 5 weeks of fake workouts
                    Button(action: generateMockData) {
                        Text("Generate Mock")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Strength Tracker")
        }
    }
    
    // Database Utilities
    
    // Wipes all Sets from the database to give you a clean slate
    private func clearAllData() {
        for set in allSets {
            viewContext.delete(set)
        }
        try? viewContext.save()
        activeDate = nil // Close the card if it was open
    }
    
    // Generates 5 weeks of fake workout history directly into the live Core Data database.
    private func generateMockData() {
        let calendar = Calendar.current
        let today = Date()
        
        // Loop backwards in time (Week 0 to Week 4)
        for week in 0..<5 {
            // Calculate a date exactly X weeks ago
            guard let workoutDate = calendar.date(byAdding: .day, value: -(28 - (week * 7)), to: today) else { continue }
            
            // 1. Create the parent Routine (The "Folder" for the day)
            let routine = Routine(context: viewContext)
            routine.date = workoutDate
            
            // 2. Create 3 fake Bench Press sets and link them to the Routine
            let baseBenchWeight = 135.0 + Double(week * 5)
            for setNum in 1...3 {
                let set = Sets(context: viewContext)
                set.exerciseName = "Bench Press"
                set.weight = baseBenchWeight
                set.reps = 8
                set.number = Int16(setNum)
                set.routine = routine // The link to the parent folder
            }
            
            // 3. Create 3 fake Squat sets and link them to the Routine
            let baseSquatWeight = 185.0 + Double(week * 10)
            for setNum in 1...3 {
                let set = Sets(context: viewContext)
                set.exerciseName = "Squat"
                set.weight = baseSquatWeight
                set.reps = Int16(8 - (setNum - 1))
                set.number = Int16(setNum)
                set.routine = routine // The link to the parent folder
            }
        }
        
        // Force Core Data to permanently save the newly created mock data to the device
        try? viewContext.save()
    }
}
