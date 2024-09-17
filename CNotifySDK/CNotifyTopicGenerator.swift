//
//  topic_generator.swift
//  CNotifySDK
//
//  Created by Gaspi Habif on 16/09/2024.
//

import Foundation

public class CNotifyTopicGenerator {
    let baseTopic = "eruka_"
    let allUsersTopic = "all_users"
    let audienceSeparator = "_aud"

    public func getTopics(language: String, country: String, appVersion: String) -> [String] {
        var topics = [String]()
        topics.append(buildTopic(language: language, audience: allUsersTopic))
        topics.append(buildTopic(language: language, audience: countryTopic(for: country)))
        topics.append(buildTopic(language: language, audience: versionTopic(for: appVersion)))
        return topics
    }

    private func countryTopic(for country: String) -> String {
        return "-country-\(country)"
    }

    private func versionTopic(for version: String) -> String {
        return "-version-\(version)"
    }

    private func langTopic(for lang: String) -> String {
        return "lang-\(lang)"
    }


    private func buildTopic(language: String, audience: String) -> String {
        let aud = "\(audienceSeparator)\(audience)"
        return "\(baseTopic)\(langTopic(for: language))\(aud)"
    }

}
