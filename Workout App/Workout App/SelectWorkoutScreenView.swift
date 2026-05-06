//
//  WorkoutScreenView.swift
//  Workout App
//
//  Created by Maryann Kwiat on 5/6/26.
//

import SwiftUI
import CoreData

struct SelectWorkoutScreenView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: [])
    
    var plans: FetchedResults<Plans>
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(plans) { plan in
                    VStack(alignment: .leading, spacing: 16) {
                        NavigationLink(destination: WorkoutScreenView(plan: plan)) {
                            HomeButtonView(title: plan.name ?? "workout", color: .green)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .shadow(radius: 3)
                Spacer()
            }
        }
        .navigationTitle("Select Workout")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
#Preview {
    SelectWorkoutScreenView()
}
