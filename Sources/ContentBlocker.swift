import WebKit

enum ContentBlocker {
    private static let identifier = "OrchardPlayer.AdBlockRules.v2"

    private static let rules = #"""
    [
      {
        "trigger": {
          "url-filter": "^https?://([^/]+\\.)?doubleclick\\.net/",
          "resource-type": ["image", "style-sheet", "script", "raw"]
        },
        "action": { "type": "block" }
      },
      {
        "trigger": {
          "url-filter": "^https?://([^/]+\\.)?googleadservices\\.com/",
          "resource-type": ["image", "style-sheet", "script", "raw"]
        },
        "action": { "type": "block" }
      },
      {
        "trigger": {
          "url-filter": "^https?://([^/]+\\.)?googlesyndication\\.com/",
          "resource-type": ["image", "style-sheet", "script", "raw"]
        },
        "action": { "type": "block" }
      },
      {
        "trigger": {
          "url-filter": "^https?://([^/]+\\.)?youtube\\.com/pagead",
          "resource-type": ["image", "style-sheet", "script", "raw"]
        },
        "action": { "type": "block" }
      },
      {
        "trigger": {
          "url-filter": "^https?://([^/]+\\.)?youtube\\.com/ptracking",
          "resource-type": ["image", "style-sheet", "script", "raw"]
        },
        "action": { "type": "block" }
      },
      {
        "trigger": {
          "url-filter": "^https?://([^/]+\\.)?youtube\\.com/api/stats/ads",
          "resource-type": ["image", "style-sheet", "script", "raw"]
        },
        "action": { "type": "block" }
      }
    ]
    """#

    static func install(
        into controller: WKUserContentController,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: identifier,
            encodedContentRuleList: rules
        ) { ruleList, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let ruleList else {
                completion(.failure(BlockerError.missingRuleList))
                return
            }

            DispatchQueue.main.async {
                controller.add(ruleList)
                controller.addUserScript(cosmeticFilterScript)
                completion(.success(()))
            }
        }
    }

    static func remove(
        from controller: WKUserContentController,
        completion: @escaping () -> Void
    ) {
        controller.removeAllUserScripts()
        controller.removeAllContentRuleLists()
        completion()
    }

    private static let cosmeticFilterScript = WKUserScript(
        source: #"""
        (() => {
          const selectors = [
            'ytd-ad-slot-renderer',
            'ytmusic-mealbar-promo-renderer',
            'ytmusic-statement-banner-renderer',
            '#masthead-ad',
            '.video-ads',
            '.ytp-ad-module',
            '.ytp-ad-overlay-container'
          ];

          const clean = () => {
            for (const selector of selectors) {
              document.querySelectorAll(selector).forEach((element) => element.remove());
            }
          };

          clean();
          new MutationObserver(clean).observe(document.documentElement, {
            childList: true,
            subtree: true
          });
        })();
        """#,
        injectionTime: .atDocumentEnd,
        forMainFrameOnly: false
    )

    private enum BlockerError: Error {
        case missingRuleList
    }
}
