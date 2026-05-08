import SwiftUI
import CoreData
import Charts

// Data Models

/// A custom data structure representing a single point on our line graph.
/// It holds the date (X-Axis), the total score (Y-Axis), and the specific sets lifted that day.
struct ChartDataPoint: Identifiable {
    // FIX: We use the Date as the unique ID instead of a random UUID().
    // If we used UUID(), the ID would scramble every time you tapped the screen, causing the pop-up to instantly close.
    var id: Date { date }
    
    let date: Date          // The day the workout occurred
    let value: Double       // The calculated score (Sum of Weight * Reps)
    let sets: [Set_log]     // The raw Core Data sets from the main branch, stored so we can display them when tapped
}

struct StrengthTrackerView: View {
    // MARK: - Core Data Connection
    
    /// Connects to the app's live database so we can read and delete data
    @Environment(\.managedObjectContext) private var viewContext
    
    /// Automatically fetches all 'Exercise_log' folders from the live database.
    /// We sort them chronologically (oldest to newest) based on the Date they were performed.
    @FetchRequest(
        entity: Exercise_log.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise_log.date, ascending: true)],
        animation: .default)
    private var allExerciseLogs: FetchedResults<Exercise_log>
    
    // MARK: - User Interface State
    
    /// Tracks which exercise the user currently has selected in the top dropdown tab
    @State private var selectedExercise: String = ""
    
    /// Tracks the exact Date of the data point the user tapped on.
    /// If this is nil, no pop-up card is shown. If it has a Date, the card for that point stays open.
    @State private var activeDate: Date?
    
    // MARK: - Dynamic Data Processing
    
    /// Scans your entire database to find which exercises you have *actually* performed.
    /// This creates the tabs at the top automatically based on your real workout history, instead of hardcoding them.
    var availableExercises: [String] {
        // 1. Get just the names of the exercises from every log
        let names = allExerciseLogs.compactMap { $0.exercise?.name }
        
        // 2. Put them in a 'Set' to remove duplicates, then sort them alphabetically
        let uniqueNames = Array(Set(names)).sorted()
        
        // 3. Return the names, or a placeholder if the database is totally empty
        return uniqueNames.isEmpty ? ["No Data Yet"] : uniqueNames
    }
    
    /// The engine of the graph. It takes the raw Core Data, filters it, does the math,
    /// and packages it into the `ChartDataPoint` array that Swift Charts requires.
    var chartData: [ChartDataPoint] {
        
        // 1. Throw away any logs that don't match the currently selected exercise tab (e.g., ignore Squats if Bench Press is selected)
        let filteredLogs = allExerciseLogs.filter { ($0.exercise?.name ?? "") == selectedExercise }
        
        // 2. Group the remaining logs into buckets by Calendar Day.
        // We use 'startOfDay' so a morning set and evening set on the same calendar day group together.
        var groupedByDate: [Date: [Exercise_log]] = [:]
        for log in filteredLogs {
            if let date = log.date {
                let startOfDay = Calendar.current.startOfDay(for: date)
                groupedByDate[startOfDay, default: []].append(log)
            }
        }
        
        // 3. Loop through those daily buckets and calculate the total score for each day
        var dataPoints: [ChartDataPoint] = []
        for (date, logs) in groupedByDate {
            var dailySum: Double = 0
            var allSetsForDay: [Set_log] = []
            
            // Because a user might do Bench Press twice in one day, we loop through all logs for that day
            for log in logs {
                let sets = log.setArray // Grab the properly sorted array of sets from this log
                allSetsForDay.append(contentsOf: sets) // Add them to our master list for the pop-up card
                
                // MATH FORMULA: sum(weight * reps in set 1, weight * reps in set 2, etc)
                let logSum = sets.reduce(0) { total, currentSet in
                    total + (Double(currentSet.weight) * Double(currentSet.reps))
                }
                dailySum += logSum // Add this log's score to the total daily score
            }
            
            // Create the final point and add it to our array
            dataPoints.append(ChartDataPoint(date: date, value: dailySum, sets: allSetsForDay))
        }
        
        // 4. Return the final array sorted from oldest date to newest date so the graph draws left-to-right
        return dataPoints.sorted { $0.date < $1.date }
    }
    
    /// A helper variable that quickly grabs the actual data point the user currently has toggled ON
    var activePoint: ChartDataPoint? {
        chartData.first { $0.date == activeDate }
    }

    // MARK: - User Interface Definition
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // --- DYNAMIC EXERCISE SELECTOR ---
                // A segmented toggle at the top of the screen to switch between your real exercises
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
                // If there is no data for this exercise, show a friendly empty state
                if chartData.isEmpty {
                    VStack {
                        Spacer()
                        Text("No data available yet.")
                            .foregroundColor(.secondary)
                        Text("Finish a workout to see your progress!")
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
                        .interpolationMethod(.catmullRom) // Smooths the line into a beautiful curve
                        
                        // The Interactive Cursor: Draws a vertical dashed line IF this point's date is toggled ON
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
                                                    activeDate = nil // Turn off
                                                } else {
                                                    activeDate = closest.date // Turn on
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
                                // Because Set_log in the main branch doesn't explicitly save a "Set 1, Set 2" number,
                                // we use Swift's `zip(1..., array)` to automatically pair the sets with a number counting up from 1!
                                ForEach(Array(zip(1..., details.sets)), id: \.0) { index, set in
                                    HStack {
                                        Text("Set \(index)")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        // Because weight is an Int16 in main, we don't need decimal specifiers
                                        Text("\(set.weight) lbs  ×  \(set.reps) reps")
                                            .fontWeight(.medium)
                                    }
                                    .padding(.bottom, 2)
                                }
                            }
                            .frame(minHeight: 50, maxHeight: 180) // Keeps the card height contained but readable
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
                            .frame(minHeight: 150)
                    }
                    
                    Spacer()
                }
                
                // --- TESTING UTILITIES ---
                HStack(spacing: 15) {
                    // Button to wipe the database clean if you want to start fresh
                    Button(action: clearAllData) {
                        Text("Wipe All Data")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Strength Tracker")
            
            // When the view opens, if an exercise isn't selected yet, automatically select the first tab!
            .onAppear {
                if let first = availableExercises.first, selectedExercise.isEmpty || !availableExercises.contains(selectedExercise) {
                    selectedExercise = first
                }
            }
        }
    }
    
    // MARK: - Database Utilities
    
    /// Deletes all Exercise Logs from the live database. (A useful reset button while testing)
    private func clearAllData() {
        for log in allExerciseLogs {
            viewContext.delete(log)
        }
        try? viewContext.save()
        activeDate = nil // Close the card if it was open
        selectedExercise = "" // Reset the tab
    }
}
