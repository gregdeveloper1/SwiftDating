import SwiftUI

struct PromptsStepView: View {
    @Binding var prompts: [PromptAnswer]

    @State private var showPromptPicker = false
    @State private var editingPrompt: PromptAnswer?
    @State private var answerText = ""

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingL) {
                // Info
                infoSection

                // Added prompts
                addedPromptsSection

                // Add prompt button
                if prompts.count < 3 {
                    addPromptButton
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, Theme.spacingL)
            .padding(.top, Theme.spacingL)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showPromptPicker) {
            PromptPickerSheet(
                selectedPrompts: Set(prompts.map(\.promptId)),
                onSelect: { template in
                    editingPrompt = PromptAnswer(
                        promptId: template.rawValue,
                        promptText: template.text,
                        answer: ""
                    )
                    answerText = ""
                    showPromptPicker = false
                }
            )
        }
        .sheet(item: $editingPrompt) { prompt in
            PromptAnswerSheet(
                prompt: prompt,
                answerText: $answerText,
                onSave: { answer in
                    if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
                        prompts[index] = answer
                    } else {
                        prompts.append(answer)
                    }
                    editingPrompt = nil
                }
            )
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        HStack(spacing: Theme.spacingM) {
            Image(systemName: "text.quote")
                .font(.system(size: 24))
                .foregroundStyle(Theme.textSecondary)

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text("Answer prompts")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)

                Text("Help others get to know you better")
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()
        }
        .padding(Theme.spacingM)
        .glassBackground(cornerRadius: Theme.radiusL)
    }

    // MARK: - Added Prompts

    @ViewBuilder
    private var addedPromptsSection: some View {
        if prompts.isEmpty {
            emptyStateView
        } else {
            VStack(spacing: Theme.spacingM) {
                ForEach(prompts) { prompt in
                    promptCard(prompt)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: Theme.spacingM) {
            Image(systemName: "bubble.left.and.text.bubble.right")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Theme.textTertiary)

            VStack(spacing: Theme.spacingXS) {
                Text("No prompts added yet")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textSecondary)

                Text("Add at least 1 prompt to continue")
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingXL)
    }

    @ViewBuilder
    private func promptCard(_ prompt: PromptAnswer) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            HStack {
                Text(prompt.promptText)
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textSecondary)

                Spacer()

                Menu {
                    Button {
                        answerText = prompt.answer
                        editingPrompt = prompt
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        withAnimation {
                            prompts.removeAll { $0.id == prompt.id }
                        }
                        Haptics.lightImpact()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: Theme.iconM))
                        .foregroundStyle(Theme.textTertiary)
                        .padding(Theme.spacingXS)
                }
            }

            Text(prompt.answer)
                .font(Theme.body)
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(Theme.spacingM)
        .glassBackground(cornerRadius: Theme.radiusL)
    }

    // MARK: - Add Prompt Button

    private var addPromptButton: some View {
        Button {
            showPromptPicker = true
            Haptics.buttonTap()
        } label: {
            HStack(spacing: Theme.spacingS) {
                Image(systemName: "plus.circle.fill")
                Text("Add Prompt")
            }
            .font(Theme.headline)
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.spacingL)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.radiusL))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.radiusL)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1, dash: [8, 4])
                    )
                    .foregroundStyle(Theme.borderLight)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Prompt Picker Sheet

struct PromptPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let selectedPrompts: Set<String>
    let onSelect: (PromptTemplate) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.spacingM) {
                    ForEach(PromptTemplate.allCases) { template in
                        let isSelected = selectedPrompts.contains(template.rawValue)

                        Button {
                            if !isSelected {
                                onSelect(template)
                                Haptics.selection()
                            }
                        } label: {
                            HStack {
                                Text(template.text)
                                    .font(Theme.body)
                                    .foregroundStyle(isSelected ? Theme.textTertiary : Theme.textPrimary)

                                Spacer()

                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Theme.textTertiary)
                                }
                            }
                            .padding(Theme.spacingM)
                            .background(
                                isSelected ? Theme.surface.opacity(0.5) : Theme.surface,
                                in: RoundedRectangle(cornerRadius: Theme.radiusM)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isSelected)
                    }
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Choose a Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }
}

// MARK: - Prompt Answer Sheet

struct PromptAnswerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let prompt: PromptAnswer
    @Binding var answerText: String
    let onSave: (PromptAnswer) -> Void

    private var isValid: Bool {
        answerText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Theme.spacingL) {
                // Prompt text
                Text(prompt.promptText)
                    .font(Theme.title3)
                    .foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Text editor
                GlassTextEditor(
                    "Write your answer... (min 10 characters)",
                    text: $answerText,
                    minHeight: 150,
                    maxHeight: 250
                )

                // Character count
                HStack {
                    Text("\(answerText.count)/\(Constants.maxPromptAnswerLength)")
                        .font(Theme.caption)
                        .foregroundStyle(
                            answerText.count > Constants.maxPromptAnswerLength
                            ? Theme.textPrimary
                            : Theme.textTertiary
                        )

                    Spacer()

                    if !isValid && !answerText.isEmpty {
                        Text("At least 10 characters")
                            .font(Theme.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                Spacer()

                // Save button
                Button {
                    var updatedPrompt = prompt
                    updatedPrompt.answer = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
                    onSave(updatedPrompt)
                    Haptics.success()
                } label: {
                    Text("Save")
                }
                .buttonStyle(.solidGlassFullWidth)
                .disabled(!isValid)
                .opacity(isValid ? 1 : 0.6)
            }
            .padding()
            .background(Theme.background)
            .navigationTitle("Answer Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()
        PromptsStepView(prompts: .constant([]))
    }
}
