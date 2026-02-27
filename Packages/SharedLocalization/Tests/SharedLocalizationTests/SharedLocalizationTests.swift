import Testing

@testable import SharedLocalization

@Suite("SharedLocalization Tests")
struct SharedLocalizationTests {

    @Test("Common action strings are not empty")
    func testCommonActions() {
        #expect(!SharedLocalizedString.cancel.isEmpty)
        #expect(!SharedLocalizedString.save.isEmpty)
        #expect(!SharedLocalizedString.done.isEmpty)
        #expect(!SharedLocalizedString.continue.isEmpty)
    }

    @Test("Error message strings are not empty")
    func testErrorMessages() {
        #expect(!SharedLocalizedString.Error.somethingWentWrong.isEmpty)
        #expect(!SharedLocalizedString.Error.networkError.isEmpty)
        #expect(!SharedLocalizedString.Error.tryAgain.isEmpty)
    }

    @Test("Validation strings are not empty")
    func testValidationMessages() {
        #expect(!SharedLocalizedString.Validation.requiredField.isEmpty)
        #expect(!SharedLocalizedString.Validation.invalidEmail.isEmpty)
    }

    @Test("Auth strings are not empty")
    func testAuthStrings() {
        #expect(!SharedLocalizedString.Auth.signIn.isEmpty)
        #expect(!SharedLocalizedString.Auth.signOut.isEmpty)
        #expect(!SharedLocalizedString.Auth.account.isEmpty)
    }
}
