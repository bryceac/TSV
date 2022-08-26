import XCTest
@testable import TSV

final class TSVTests: XCTestCase {
    func testTSVParsing() {
        let text = """
        Date\tCheck No.\tReconciled\tCategory\tVendor\tMemo\tDeposit\tWithdrawal
        08/25/2022\t1260\tY\tOpening Balance\tSam Hill Credit Union\tOpen Account\t500
        08/25/2022\t\tN\tGifts\tFake Street Electronics\tHead set\t\t200
        08/25/2022\t\tN\t\tVelociraptor Entertainment\tPay Day\t50000
        """
        
        XCTAssertNoThrow(try TSV(text, withHeaders: true))
    }
}
