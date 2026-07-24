import SwiftUI

struct NCDCameraShutterView: View {
    let isClosed: Bool

    var body: some View {
        GeometryReader { proxy in
            let radius = hypot(proxy.size.width, proxy.size.height)

            Circle()
                .fill(.black)
                .frame(width: radius * 2, height: radius * 2)
                .scaleEffect(isClosed ? 1 : 0.001)
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
    }
}
