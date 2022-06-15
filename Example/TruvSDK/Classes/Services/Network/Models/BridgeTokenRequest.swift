import Foundation

struct BridgeTokenRequest: Encodable {

    let product_type: String
    let provider_id: String?
    let company_mapping_id: String?
    let account: AccountRequest?

    init(product: Product) {
        self.product_type = product.type.requestValue
        self.provider_id = product.settings.first(where: { $0.type == .providerId })?.value
        self.company_mapping_id = product.settings.first(where: { $0.type == .companyMappingId })?.value
        self.account = AccountRequest(product: product)
    }

}

extension BridgeTokenRequest {

    struct AccountRequest: Encodable {
        let account_number: String
        let account_type: String
        let bank_name: String
        let routing_number: String
        let deposit_value: String
        let deposit_type: String

        init?(product: Product) {
            guard product.type.hasAdditionalSettings else { return nil }

            self.account_number = product.settings.first(where: { $0.type == .accountNumber })?.value ?? ""
            self.account_type = product.settings.first(where: { $0.type == .accountType })?.value ?? ""
            self.bank_name = product.settings.first(where: { $0.type == .bankName })?.value ?? ""
            self.routing_number = product.settings.first(where: { $0.type == .routingNumber })?.value ?? ""
            self.deposit_value = product.settings.first(where: { $0.type == .depositValue })?.value ?? ""
            self.deposit_type = product.settings.first(where: { $0.type == .depositType })?.value ?? ""
        }
    }

}
