import SwiftUI
import WebKit

struct PlayerView: View {
    @StateObject private var model = PlayerModel()

    var body: some View {
        ZStack(alignment: .top) {
            PlayerWebView(model: model)
                .ignoresSafeArea(edges: .bottom)

            if model.isLoading {
                ProgressView(value: model.progress)
                    .progressViewStyle(.linear)
                    .tint(.red)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack(spacing: 28) {
                Button {
                    model.goBack()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .disabled(!model.canGoBack)

                Button {
                    model.openHome()
                } label: {
                    Image(systemName: "music.note.house")
                }

                Button {
                    model.reload()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }

                Spacer()

                if let url = model.currentURL {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .font(.title3)
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .alert("無法開啟網頁", isPresented: $model.showError) {
            Button("重試") { model.reload() }
            Button("取消", role: .cancel) {}
        } message: {
            Text(model.errorMessage)
        }
    }
}

@MainActor
final class PlayerModel: ObservableObject {
    static let homeURL = URL(string: "https://music.youtube.com/")!

    weak var webView: WKWebView?
    @Published var canGoBack = false
    @Published var isLoading = true
    @Published var progress = 0.0
    @Published var currentURL: URL?
    @Published var showError = false
    @Published var errorMessage = "請檢查網路連線後再試一次。"

    func goBack() { webView?.goBack() }
    func reload() { webView?.reload() }
    func openHome() { webView?.load(URLRequest(url: Self.homeURL)) }
}

struct PlayerWebView: UIViewRepresentable {
    @ObservedObject var model: PlayerModel

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.websiteDataStore = .default()

        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic

        context.coordinator.observe(webView)
        model.webView = webView
        webView.load(URLRequest(url: PlayerModel.homeURL))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        coordinator.stopObserving(webView)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let model: PlayerModel
        private var observations: [NSKeyValueObservation] = []

        init(model: PlayerModel) {
            self.model = model
        }

        func observe(_ webView: WKWebView) {
            observations = [
                webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
                    Task { @MainActor in self?.model.progress = webView.estimatedProgress }
                },
                webView.observe(\.isLoading, options: [.new]) { [weak self] webView, _ in
                    Task { @MainActor in self?.model.isLoading = webView.isLoading }
                },
                webView.observe(\.canGoBack, options: [.new]) { [weak self] webView, _ in
                    Task { @MainActor in self?.model.canGoBack = webView.canGoBack }
                },
                webView.observe(\.url, options: [.new]) { [weak self] webView, _ in
                    Task { @MainActor in self?.model.currentURL = webView.url }
                }
            ]
        }

        func stopObserving(_ webView: WKWebView) {
            observations.removeAll()
            webView.navigationDelegate = nil
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url,
                  let scheme = url.scheme?.lowercased() else {
                decisionHandler(.cancel)
                return
            }

            if scheme == "http" || scheme == "https" {
                decisionHandler(.allow)
            } else {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            }
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            present(error)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            present(error)
        }

        private func present(_ error: Error) {
            let nsError = error as NSError
            guard nsError.code != NSURLErrorCancelled else { return }
            Task { @MainActor in
                model.errorMessage = error.localizedDescription
                model.showError = true
            }
        }
    }
}
