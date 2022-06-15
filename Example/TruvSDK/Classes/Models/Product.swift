import Foundation

public final class Product {

    var type: ProductType = .employmentHistory

    let settings = [
        ProductSetting(type: .companyMappingId),
        ProductSetting(type: .providerId),
        ProductSetting(type: .depositValue, value: "1"),
        ProductSetting(type: .routingNumber, value: "123456789"),
        ProductSetting(type: .accountNumber, value: "160025987"),
        ProductSetting(type: .bankName, value: "TD Bank"),
        ProductSetting(type: .accountType, value: "checking"),
        ProductSetting(type: .depositType, value: "amount")
    ]

}
