//
//  PlanManagementView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/24.
//

import SwiftUI
import SwiftData

struct PlanManagementView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Query(sort: \Plan.createdDate) var plans: [Plan]
    @State private var isAdding: Bool = false
    @State private var planToEdit: Plan?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PlansListView()
        }
        .background(Color.themeStyle.theme.background)
        .veriticalSpacing(.top)
        .navigationTitle("Plans")
        .sheet(isPresented: $isAdding, content: {
            AddPlanView()
                .presentationDetents([.height(200)])
                .presentationCornerRadius(30)

        })
        .toolbar {
            Button(action: {
                isAdding.toggle()
            }) {
                Label("Add", systemImage: "plus")
            }
        }
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Text("Plans").foregroundStyle(Color.themeStyle.theme.accent)
            }
            .font(.title.bold())
            .frame(height: 90)
        }
        .padding(.horizontal, 16)
        .background(Color.themeStyle.theme.background)
        .horizontalSpacing(.leading)
    }
    
    @ViewBuilder
    func PlansListView() -> some View {
        List {
            ForEach(plans, id: \.self) { plan in
                PlanCard(plan: plan)
                    .veriticalSpacing(.center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            /// Delete items
                            withAnimation {
                                context.delete(plan)
                            }
                        }) {
                            Label("Delete", systemImage: "trash")
                                .symbolVariant(/*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        }
                        .tint(Color.themeStyle.theme.accent)
                    }
                    .background(
                        NavigationLink("", destination: PlanEditView(plan: plan)).opacity(0)
                    )
            }
        }
        .padding(.top, 16)
        .listStyle(PlainListStyle())
        .background(Color.themeStyle.theme.background)
    }
}

#Preview {
    let previewContainer = PreviewContainer([Plan.self])
    return PlanManagementView().modelContainer(previewContainer.container)
}

struct PlanCard: View {
    @Bindable var plan: Plan

    var body: some View {
        /// Content
        HStack(spacing: 8) {
            Rectangle()
                .foregroundStyle(Color.themeStyle.theme.accent)
                .frame(width: 2)
            
            PlanView()
                .frame(maxHeight: .infinity)
            Spacer()
            PlanDetailsView()
                .padding(.trailing, 16)
                .horizontalSpacing(.trailing)
        }
        .horizontalSpacing(.leading)
        .background(Color.themeStyle.theme.background)
    }
    
    
    @ViewBuilder
    func PlanView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            PlanNameView()
        }
        .horizontalSpacing(.leading)
        .padding()
    }
    
    @ViewBuilder
    func PlanNameView() -> some View {
        Text(plan.name)
            .fontWeight(.semibold)
            .foregroundStyle(Color.themeStyle.theme.primaryTextColor)
    }
    
    @ViewBuilder
    func PlanDetailsView() -> some View {
        HStack(alignment: .center, spacing: 16) {
            Label("\(Int(plan.exercises.count))", systemImage: "list.dash")
                .font(.caption)
                .foregroundColor(Color.themeStyle.theme.primaryTextColor)
        }
    }
}


@Model
class Plan {
    var name: String
    var tags: [String]
    var exercises: [DesignedExercise] = []
    var createdDate: Date
    
    init(name: String, tags: [String], exercises: [DesignedExercise], createdDate: Date) {
        self.name = name
        self.tags = tags
        self.exercises = exercises
        self.createdDate = createdDate
    }
}

struct DesignedExercise: Codable, Hashable {
    var exercise: Exercise
    var repetitions: Double
    var sets: Double
    var restIntevals: TimeInterval
    var order: Int
}

struct AddPlanView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.dismiss) private var dismiss
    @State var planName: String = ""
    @State var tags: [String] = []
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 28) {
                PlanNameView().horizontalSpacing(.leading)
                CreateButtonView().horizontalSpacing(.leading)
            }
            .padding()
            .veriticalSpacing(.bottom)
//            .sheet(isPresented: $isExercisePickerViewPresented, content: {
//                ExercisePickerView(selectedExercise: scheduledExercise.exericse, callback: { exercise in
//                    scheduledExercise.exericse = exercise
//                    isExercisePickerViewPresented.toggle()
//                })
//                    .presentationDetents([.large])
//            })
        }
    }
    
    @ViewBuilder
    func PlanNameView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Plan Name")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
            
            TextField("New Plan", text: $planName)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .foregroundColor(Color.themeStyle.theme.primaryTextColor)
                .background(Color.themeStyle.theme.background)
                .cornerRadius(10)
//                .background(.white.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
        }
    }
    
    @ViewBuilder
    func TagsTextFieldView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.caption)
                .foregroundStyle(Color.themeStyle.theme.secondaryTextColor)
                        
            TextField("New Plan", text: $planName)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(.white.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
        }
    }
    
    @ViewBuilder
    func CreateButtonView() -> some View {
        Button(action: {
            /// Save schedule exercise
            let plan = Plan(name: planName, tags: [], exercises: [], createdDate: .init())
            context.insert(plan)
            dismiss()
        }) {
            Text("Create")
                .font(.title3)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .horizontalSpacing(.center)
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .background(Color.themeStyle.theme.accent, in: .rect(cornerRadius: 10))
        }
        .disabled(planName.isEmpty)
        .opacity(planName.isEmpty ? 0.5 : 1)
    }
}


#Preview("Add Plan") {
    AddPlanView()
}
