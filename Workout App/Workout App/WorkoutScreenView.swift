//
//  WorkoutScreenView.swift
//  Workout App
//
//  Created by Maryann Kwiat on 5/6/26.
//

import SwiftUI
import CoreData
import Charts


struct WorkoutScreenView: View {
    @Environment(\.managedObjectContext) var context
    @State var weights: [String] = []
    @State var reps: [String] = []
    @State private var joins: [Join] = []
    var plan: Plans? = nil
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(joins) { join in
                    VStack(alignment: .leading, spacing: 16) {
                        // Header Row
                        HStack {
                            Text(join.exercise?.name ?? "something is wrong")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            // Delete Exercise Button
                            Button(action: {
                                
                            })
                            {
                                Label("Add set",systemImage: "plus.circle")
                                    .foregroundColor(.green)
                                    .padding(4)
                            }
                            
                        }
                        
                        ForEach(1..<Int(join.sets)+1, id: \.self) { i in
                            // Exercise Name Input
                            Text("Set \(i): ")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            HStack{
                                Text("Weight:")
                                TextField("lbs", text: $weights[i])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 50, height: 40)
                                    .cornerRadius(8)
                            }
                            HStack{
                                Text("Reps:")
                                TextField("Reps", text: $reps[i])
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 50, height: 40)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .shadow(radius: 3)
                Spacer()
            }                .onAppear(perform: loadJoins)
//            HStack{
//                Spacer()
//                Chart(data, id: \.name) { item in
//                    BarMark(
//                        x: .value("time", item.name),
//                        y: .value("mass", item.value),
//                        width: .ratio(0.5))
//                }
//                .aspectRatio(1, contentMode: .fit)
//                Spacer()
//            }
        }
        .navigationTitle("Workout Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    private func loadJoins() {
        guard let plan = plan else { return }
        let request: NSFetchRequest<Join> = Join.fetchRequest()
        request.predicate = NSPredicate(format: "workout.name == %@", plan.name ?? "")
        do {
            joins = try context.fetch(request)
            for join in joins {
                textViews(num: Int(join.sets))
            }
        } catch {print("Joins wasn't got")}
    }
    
    private func textViews(num: Int) {
        for _ in 1...num {
            weights.append("")
            reps.append("")
        }
    }
}
#Preview {
    WorkoutScreenView()
}
