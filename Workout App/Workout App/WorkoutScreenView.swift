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
    
    //@State var weights: [String] = [[]]
    //@State var reps: [String] = [[]]
    @State private var joins: [Join] = []
    @State private var Elogs: [Exercise_log] = []
    @State private var Slogs: [Set_log] = []
    @State private var iteration: Int = 0
    @State private var lengths: [Int] = [0]
    var plan: Plans? = nil
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(Array(joins.enumerated()), id: \.offset) { i, join in
                    VStack(alignment: .leading, spacing: 16) {
                        // Header Row
                        HStack {
                            Text(join.exercise?.name ?? "something is wrong")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            // Delete Exercise Button
//                            Button(action: {
//                                let temp = Set_log(context: context)
//                                temp.date = Elogs[iteration]
//                            })
//                            {
//                                Label("Add set",systemImage: "plus.circle")
//                                    .foregroundColor(.green)
//                                    .padding(4)
//                            }
                            
                        }
                        
                        ForEach($Slogs[lengths[i]..<lengths[i+1]], id:\.self) { $slog in
                            // Exercise Name Input
                            Text("Set: ")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            HStack{
                                Text("Weight:")
                                TextField("lbs", text: $slog.wrapped_weight).keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 50, height: 40)
                                    .cornerRadius(8)
                            }
                            HStack{
                                Text("Reps:")
                                TextField("Reps", text: $slog.wrapped_reps).keyboardType(.numberPad)
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
            Button(action: {try? context.save()})
            {
            Label("FINISH WORKOUT",systemImage: "plus.circle")
                .foregroundColor(.green)
                .padding(4)
            }
        }
        .navigationTitle("Workout Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    private func iterate() {
        iteration+=1
    }
    private func loadJoins() {
        guard let plan = plan else { return }
        let request: NSFetchRequest<Join> = Join.fetchRequest()
        request.predicate = NSPredicate(format: "workout.name == %@", plan.name ?? "")
        do {
            joins = try context.fetch(request)
            var i = 0
            for join in joins {
                
                Elogs.append(Exercise_log(context: context))
                Elogs[i].exercise = join.exercise
                Elogs[i].date = Date()
                textViews(num: Int(join.sets), log: Elogs[i])
                i += 1
            }
            for j in 0..<Elogs.count {
                lengths.append(Elogs[j].setArray.count + lengths[j])
            }
        } catch {print("Joins wasn't got")}
    }
    
    private func textViews(num: Int, log : Exercise_log) {
        for _ in 1...num {
            let Slog = Set_log(context: context)
            Slog.date = log
            Slogs.append(Slog)
        }
    }
}
#Preview {
    WorkoutScreenView()
}
