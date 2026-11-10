import SwiftUI

/// Override only the values needed at a call site; defaults follow the app tokens.
struct AppSegmentedControlStyle {
    var backgroundColor: Color = AppColor.Primitive.Neutral.shade100
    var selectedBackgroundColor: Color = AppColor.Primitive.Primary.shade400
    var foregroundColor: Color = AppColor.Primitive.Primary.shade500
    var selectedForegroundColor: Color = .white
    var borderColor: Color = AppColor.Border.subtle
    var selectedBorderColor: Color = .clear
    var borderWidth: CGFloat = 1
    var selectedBorderWidth: CGFloat = 0
    /// Gap between segments.
    var spacing: CGFloat = 0
    /// Padding inside the container, around all segments.
    var containerPadding: CGFloat = 0
    /// Padding inside each segment, around its label.
    var segmentPadding = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    var cornerRadius: CGFloat = AppRadius.full
    var segmentCornerRadius: CGFloat = AppRadius.full
    var minimumHeight: CGFloat = 44
    var font: Font = AppFont.mediumSubheadline
    var fillsWidth: Bool = true
    var disabledOpacity: Double = 0.45
    var pressedOpacity: Double = 0.7
    var selectionAnimation: Animation? = .snappy(duration: 0.45)
}
