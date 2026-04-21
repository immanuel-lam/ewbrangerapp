import SwiftUI

struct SizePickerView: View {
    @Binding var selectedSize: InfestationSize

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Infestation Size")
                .font(DSFont.headline)
            HStack(spacing: 8) {
                ForEach(InfestationSize.allCases, id: \.self) { size in
                    SizeButton(size: size, isSelected: selectedSize == size) {
                        selectedSize = size
                    }
                }
            }
        }
    }
}

struct SizeButton: View {
    let size: InfestationSize
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(size.displayName)
                    .font(DSFont.headline)
                Text(size.areaDescription)
                    .font(DSFont.caption)
                    .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.dsInk3)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(isSelected ? Color.dsStatusCleared : Color.dsSurface)
            .foregroundStyle(isSelected ? Color.white : Color.dsInk)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
