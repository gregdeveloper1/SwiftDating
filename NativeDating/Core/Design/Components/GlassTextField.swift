import SwiftUI

/// A glass-styled text field with frosted background
struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String?
    var isSecure: Bool
    var keyboardType: UIKeyboardType
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization
    var submitLabel: SubmitLabel
    var onSubmit: (() -> Void)?

    @FocusState private var isFocused: Bool

    init(
        _ placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        autocapitalization: TextInputAutocapitalization = .sentences,
        submitLabel: SubmitLabel = .done,
        onSubmit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.autocapitalization = autocapitalization
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
    }

    var body: some View {
        HStack(spacing: Theme.spacingS) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: Theme.iconM, weight: .medium))
                    .foregroundStyle(isFocused ? Theme.textPrimary : Theme.textSecondary)
                    .frame(width: 24)
            }

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(Theme.body)
            .foregroundStyle(Theme.textPrimary)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .textInputAutocapitalization(autocapitalization)
            .submitLabel(submitLabel)
            .focused($isFocused)
            .onSubmit {
                onSubmit?()
            }

            if !text.isEmpty && isFocused {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: Theme.iconM))
                        .foregroundStyle(Theme.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Theme.spacingM)
        .padding(.vertical, Theme.spacingM)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.radiusM))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.radiusM)
                .strokeBorder(
                    isFocused ? Theme.border : Theme.borderLight,
                    lineWidth: isFocused ? 1 : 0.5
                )
        }
        .animation(Theme.animationFast, value: isFocused)
    }
}

/// A glass-styled text editor for multiline input
struct GlassTextEditor: View {
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat
    var maxHeight: CGFloat

    @FocusState private var isFocused: Bool

    init(
        _ placeholder: String,
        text: Binding<String>,
        minHeight: CGFloat = 100,
        maxHeight: CGFloat = 200
    ) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(Theme.body)
                    .foregroundStyle(Theme.textTertiary)
                    .padding(.horizontal, Theme.spacingXS)
                    .padding(.vertical, Theme.spacingS)
            }

            TextEditor(text: $text)
                .font(Theme.body)
                .foregroundStyle(Theme.textPrimary)
                .scrollContentBackground(.hidden)
                .focused($isFocused)
                .frame(minHeight: minHeight, maxHeight: maxHeight)
        }
        .padding(Theme.spacingM)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.radiusM))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.radiusM)
                .strokeBorder(
                    isFocused ? Theme.border : Theme.borderLight,
                    lineWidth: isFocused ? 1 : 0.5
                )
        }
        .animation(Theme.animationFast, value: isFocused)
    }
}

/// A glass-styled search field
struct GlassSearchField: View {
    @Binding var text: String
    var placeholder: String
    var onSubmit: (() -> Void)?

    @FocusState private var isFocused: Bool

    init(
        text: Binding<String>,
        placeholder: String = "Search",
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }

    var body: some View {
        HStack(spacing: Theme.spacingS) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: Theme.iconM, weight: .medium))
                .foregroundStyle(Theme.textSecondary)

            TextField(placeholder, text: $text)
                .font(Theme.body)
                .foregroundStyle(Theme.textPrimary)
                .submitLabel(.search)
                .focused($isFocused)
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: Theme.iconM))
                        .foregroundStyle(Theme.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Theme.spacingM)
        .padding(.vertical, Theme.spacingS + Theme.spacingXS)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(
                    isFocused ? Theme.border : Theme.borderLight,
                    lineWidth: isFocused ? 1 : 0.5
                )
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()

        VStack(spacing: Theme.spacingL) {
            GlassTextField(
                "Email",
                text: .constant(""),
                icon: "envelope",
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )

            GlassTextField(
                "Password",
                text: .constant(""),
                icon: "lock",
                isSecure: true,
                textContentType: .password
            )

            GlassSearchField(text: .constant(""))

            GlassTextEditor(
                "Tell us about yourself...",
                text: .constant("")
            )
        }
        .padding()
    }
}
