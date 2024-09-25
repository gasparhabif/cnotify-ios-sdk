public class CNotifyTopicStorage {
    let topicsKey = "cnotify_subscribed_topics"
    
    public func getSubscribedTopics() -> [String] {
        // Get topics from UserDefaults
        let defaults = UserDefaults.standard
        return defaults.stringArray(forKey: topicsKey) ?? []
    }

    public func persistSubscribedTopics(topics: [String]) {
        // Persist topics
        // Use UserDefaults to store the topics
        let defaults = UserDefaults.standard
        defaults.set(topics, forKey: topicsKey)
        defaults.synchronize()
    }
}