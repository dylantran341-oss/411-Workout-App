//
//  WorkoutScreenView.swift
//  Workout App
//
//  Created by Maryann Kwiat on 5/6/26.
//

import SwiftUI
struct WorkoutScreenView: View {
    @State var text: String = ""
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Header Row
                    HStack {
                        Text("Exercise")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Spacer()
                        // Delete Exercise Button
                        Button(action: {}) {
                            Label("Add set",systemImage: "plus.circle")
                                .foregroundColor(.green)
                                .padding(4)
                        }
                        
                    }
                    
                    // Exercise Name Input
                    Text("Set 1: ")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    HStack{
                        Text("Weight:")
                        TextField("lbs", text: $text)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 50, height: 40)
                            .cornerRadius(8)
                    }
                    HStack{
                        Text("Reps:")
                        TextField("Reps", text: $text)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 50, height: 40)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            .shadow(radius: 3)
            
        }
        .navigationTitle("Workout Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
#Preview {
    WorkoutScreenView()
}
