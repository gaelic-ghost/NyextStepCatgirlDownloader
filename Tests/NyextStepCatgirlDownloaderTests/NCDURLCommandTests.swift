import Foundation
@testable import NyextStepCatgirlDownloader
import Testing

struct NCDURLCommandTests {
    @Test(arguments: ["nyextstep://open", "nyextstep://open/?unexpected=true", "other://open", "nyextstep://reload"])
    func onlyTheExactOpenURLIsAccepted(rawValue: String) throws {
        let command = try NCDURLCommand(url: #require(URL(string: rawValue)))
        #expect(command == (rawValue == "nyextstep://open" ? .open : nil))
    }
}
