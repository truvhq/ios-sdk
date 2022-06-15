import Foundation

enum ProductType: CaseIterable {

    case employmentHistory
    case incomeAndEmployment
    case directDepositSwitch
    case paycheckLinkedLoan
    case employeeDirectory
    case payrollHistory

    var title: String {
        switch self {
        case .employmentHistory:
            return "Employment history"
        case .incomeAndEmployment:
            return "Income and employment"
        case .directDepositSwitch:
            return "Direct deposit switch"
        case .paycheckLinkedLoan:
            return "Paycheck Linked Loan"
        case .employeeDirectory:
            return "Employee directory"
        case .payrollHistory:
            return "Payroll history"
        }
    }

    var hasAdditionalSettings: Bool {
        switch self {
        case .directDepositSwitch, .paycheckLinkedLoan:
            return true
        default:
            return false
        }
    }

    var avaliableSettings: Set<ProductSettingType> {
        if hasAdditionalSettings {
            return [.companyMappingId, .providerId, .depositValue, .routingNumber, .accountNumber, .bankName, .accountType]
        } else {
            return [.companyMappingId, .providerId]
        }
    }

    var requestValue: String {
        switch self {
        case .employmentHistory:
            return "employment"
        case .incomeAndEmployment:
            return "income"
        case .directDepositSwitch:
            return "deposit_switch"
        case .paycheckLinkedLoan:
            return "pll"
        case .employeeDirectory, .payrollHistory:
            return "admin"
        }
    }

}
