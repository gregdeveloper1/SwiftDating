import SwiftUI
import PhotosUI

struct PhotosStepView: View {
    @Binding var photos: [PhotoItem]

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showingPicker = false
    @State private var draggedItem: PhotoItem?

    private let columns = [
        GridItem(.flexible(), spacing: Theme.spacingS),
        GridItem(.flexible(), spacing: Theme.spacingS),
        GridItem(.flexible(), spacing: Theme.spacingS)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.spacingL) {
                // Info card
                infoCard

                // Photo grid
                photoGrid

                // Tips
                tipsSection

                Spacer(minLength: 100)
            }
            .padding(.horizontal, Theme.spacingL)
            .padding(.top, Theme.spacingL)
        }
        .scrollIndicators(.hidden)
        .photosPicker(
            isPresented: $showingPicker,
            selection: $selectedItems,
            maxSelectionCount: Constants.maxPhotos - photos.count,
            matching: .images
        )
        .onChange(of: selectedItems) { _, newItems in
            Task {
                await loadImages(from: newItems)
            }
        }
    }

    // MARK: - Info Card

    private var infoCard: some View {
        HStack(spacing: Theme.spacingM) {
            Image(systemName: "camera.fill")
                .font(.system(size: 24))
                .foregroundStyle(Theme.textSecondary)

            VStack(alignment: .leading, spacing: Theme.spacingXS) {
                Text("Add your best photos")
                    .font(Theme.headline)
                    .foregroundStyle(Theme.textPrimary)

                Text("Profiles with 3+ photos get more matches")
                    .font(Theme.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()
        }
        .padding(Theme.spacingM)
        .glassBackground(cornerRadius: Theme.radiusL)
    }

    // MARK: - Photo Grid

    private var photoGrid: some View {
        LazyVGrid(columns: columns, spacing: Theme.spacingS) {
            ForEach(0..<Constants.maxPhotos, id: \.self) { index in
                if index < photos.count {
                    photoCell(for: photos[index], at: index)
                } else {
                    addPhotoCell(isRequired: index < Constants.minPhotos)
                }
            }
        }
    }

    @ViewBuilder
    private func photoCell(for photo: PhotoItem, at index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            if let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusM))
            }

            // Delete button
            Button {
                withAnimation {
                    photos.remove(at: index)
                }
                Haptics.lightImpact()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
            }
            .padding(Theme.spacingXS)

            // Index badge
            if index == 0 {
                Text("Main")
                    .font(Theme.caption2)
                    .foregroundStyle(.black)
                    .padding(.horizontal, Theme.spacingS)
                    .padding(.vertical, Theme.spacingXXS)
                    .background(Color.white, in: Capsule())
                    .padding(Theme.spacingXS)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .frame(height: 150)
        .overlay {
            RoundedRectangle(cornerRadius: Theme.radiusM)
                .strokeBorder(Theme.borderLight, lineWidth: 0.5)
        }
        .draggable(photo) {
            Image(uiImage: photo.image ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusS))
        }
        .dropDestination(for: PhotoItem.self) { items, _ in
            guard let item = items.first,
                  let sourceIndex = photos.firstIndex(where: { $0.id == item.id }) else {
                return false
            }
            withAnimation {
                photos.move(fromOffsets: IndexSet(integer: sourceIndex), toOffset: index)
            }
            Haptics.mediumImpact()
            return true
        }
    }

    @ViewBuilder
    private func addPhotoCell(isRequired: Bool) -> some View {
        Button {
            showingPicker = true
            Haptics.buttonTap()
        } label: {
            VStack(spacing: Theme.spacingS) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))

                if isRequired {
                    Text("Required")
                        .font(Theme.caption2)
                }
            }
            .foregroundStyle(Theme.textTertiary)
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.radiusM))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1, dash: [8, 4])
                    )
                    .foregroundStyle(Theme.borderLight)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tips Section

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            Text("Photo tips")
                .font(Theme.headline)
                .foregroundStyle(Theme.textPrimary)

            VStack(alignment: .leading, spacing: Theme.spacingS) {
                tipRow(icon: "face.smiling", text: "Show your face clearly")
                tipRow(icon: "person.crop.rectangle", text: "Use recent photos")
                tipRow(icon: "sparkles", text: "Add variety - hobbies, travel, pets")
                tipRow(icon: "xmark.circle", text: "Avoid group photos as your main")
            }
        }
        .padding(Theme.spacingM)
        .glassBackground(cornerRadius: Theme.radiusL)
    }

    @ViewBuilder
    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: Theme.spacingS) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 20)

            Text(text)
                .font(Theme.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    // MARK: - Image Loading

    private func loadImages(from items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    photos.append(PhotoItem(image: image))
                }
            }
        }
        selectedItems.removeAll()
    }
}

// MARK: - PhotoItem Transferable

extension PhotoItem: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .data)
    }
}

extension PhotoItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id, url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Note: We can't decode UIImage, so we just decode the ID
        _ = try container.decode(UUID.self, forKey: .id)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.image = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(url, forKey: .url)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()
        PhotosStepView(photos: .constant([]))
    }
}
