# Orchard Player for iOS

這是一個供個人側載測試的 iOS 網頁播放器，會在 `WKWebView` 中開啟 YouTube Music。

## iOS 廣告阻擋層

- 使用 `WKContentRuleList` 阻擋已知的 DoubleClick、Google Ads 及 YouTube 廣告統計請求。
- 使用 `WKUserScript` 移除頁面上的廣告與宣傳元件。
- 工具列的盾牌圖示為綠色時，代表阻擋規則已成功載入。
- YouTube 可能把廣告與音樂放在相同網域或媒體串流中，因此無法保證完全阻擋。
- Pear 使用的 Electron／Ghostery 套件依賴桌面 Chromium API，無法在 iOS WebKit 執行；此處是 iOS 原生替代實作。

## 重要限制

- 本專案不是 Pear Desktop 的直接移植；Electron 無法在 iOS 執行。
- YouTube Music 的登入、播放與背景播放能力由 YouTube 網站及帳號方案決定。
- 設定 iOS 音訊背景模式不代表 YouTube 一定允許免費帳號背景播放。
- 免費 Apple ID 透過 AltStore 安裝的 App 通常每 7 天要刷新一次。
- 請遵守 YouTube 服務條款及內容授權規則。

## 免費產生 IPA（不需要 Mac）

1. 在 GitHub 建立一個 **Public** repository。
2. 把本資料夾內的所有檔案上傳到 repository 根目錄。
3. 打開 GitHub repository 的 **Actions** 頁面。
4. 選擇 **Build unsigned iOS IPA**，按 **Run workflow**。
5. 完成後下載 `OrchardPlayer-unsigned-ipa` artifact 並解壓縮。
6. 在 Windows 安裝 AltServer／AltStore，然後用 AltStore 安裝 IPA。

GitHub 公開 repository 的標準 Actions runner 目前可免費使用；若改成私人 repository，會消耗帳號的免費分鐘額度。

## 本機結構

- `Sources/`：SwiftUI 與 WKWebView 程式碼
- `Sources/ContentBlocker.swift`：iOS 網路規則與頁面元件過濾
- `Resources/Info.plist`：App 權限與背景音訊設定
- `project.yml`：由 XcodeGen 產生 Xcode project
- `.github/workflows/build-ipa.yml`：在 GitHub macOS runner 編譯未簽署 IPA

## 隱私

Google 帳號登入發生在 YouTube Music 網頁中。本專案不另外蒐集、上傳或保存帳號密碼。
