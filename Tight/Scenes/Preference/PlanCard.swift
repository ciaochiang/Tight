//
//  PlanCard.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/12/25.
//

import SwiftUI

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
            Label("\(Int(plan.arrangedExercises.count))", systemImage: "list.dash")
                .font(.caption)
                .foregroundColor(Color.themeStyle.theme.primaryTextColor)
        }
    }
}

#Preview {
    PlanCard(plan: .init(name: "", arrangedExercises: [], startDate: .init(), repeats: [], duration: 0, updatedDate: .init(), createdDate: .init(), tags: [], isPreset: false))
}
