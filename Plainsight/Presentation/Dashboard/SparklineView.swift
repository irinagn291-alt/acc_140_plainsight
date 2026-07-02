import SwiftUI

/// A quiet line, not a chart — minutes practiced per day, last 7 days.
struct SparklineView: View {
    let values: [Double]

    var body: some View {
        let maxValue = max(values.max() ?? 1, 1)
        GeometryReader { proxy in
            Path { path in
                guard values.count > 1 else { return }
                let stepX = proxy.size.width / CGFloat(values.count - 1)
                for (index, value) in values.enumerated() {
                    let x = CGFloat(index) * stepX
                    let y = proxy.size.height * (1 - CGFloat(value / maxValue))
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(AppColor.accent.opacity(0.8), lineWidth: 1)
        }
        .frame(height: 40)
    }
}
