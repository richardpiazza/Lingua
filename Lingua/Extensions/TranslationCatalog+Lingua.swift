import Foundation
import TranslationCatalog

extension TranslationCatalog.Catalog {
    func preload() throws {
        let projects: [TranslationCatalog.Project] = [
            .bakeshop,
            .brainfog,
            .dynumite,
            .lingua,
        ]
        
        for project in projects {
            try createProject(project)
        }
    }
}

extension UUID {
    static let expressionAdd = UUID(uuidString: "D90ECA02-559C-478E-A817-E2241BD5FDCA")!
    static let expressionUpdate = UUID(uuidString: "CDF7FC1E-D106-4064-95B0-55B720E77329")!
    static let expressionRemove = UUID(uuidString: "5AE905D6-42B1-4440-9C5B-6B25931A3354")!
    static let expressionSettings = UUID(uuidString: "A60F9849-33DF-464B-9847-4F02F3627C6C")!
    
    static let projectBakeshop = UUID(uuidString: "49D98807-9C7B-4649-A2BD-83841FB5F863")!
    static let projectBrainfog = UUID(uuidString: "E5DBC8CC-06D9-4618-AA08-4B463C1DF75D")!
    static let projectDynumite = UUID(uuidString: "58D01447-154B-4905-BBAA-B005C3FD9D55")!
    static let projectLingua = UUID(uuidString: "7F13F91A-9F4B-4C47-93FB-E00E95C15F1F")!
    
    static let translationAdd_en_US = UUID(uuidString: "D282AF6B-9644-4975-B420-2BD55AFCBBD9")!
    static let translationAdd_es_ES = UUID(uuidString: "F96E730B-A2ED-45A1-8AA9-C59DDA185FDE")!
    static let translationAdd_it_IT = UUID(uuidString: "D4BB90E4-223F-4E4F-AFB0-CB349D28FF5D")!
    static let translationUpdate_en_US = UUID(uuidString: "59352563-E920-44C2-BC79-E8F8F9232B12")!
    static let translationUpdate_es_ES = UUID(uuidString: "8DB19CC6-783B-4A22-869C-670AC677A0A3")!
    static let translationUpdate_it_IT = UUID(uuidString: "9C3AA9EB-DD81-4313-9BFE-A52352ED05DE")!
    static let translationRemove_en_US = UUID(uuidString: "97FF1D64-778F-45C7-A422-96C4F03CA3E7")!
    static let translationRemove_es_ES = UUID(uuidString: "5C61006F-48CA-4684-8298-1B4AD9799F28")!
    static let translationRemove_it_IT = UUID(uuidString: "E40CC3C0-2AAD-4E24-AA02-446644D0094F")!
    static let translationSettings_en_US = UUID(uuidString: "ABE2D66C-B7E2-43A1-8FC2-EF6D37482696")!
    static let translationSettings_es_ES = UUID(uuidString: "5D96FFE3-0279-4678-81C9-37D650795714")!
    static let translationSettings_it_IT = UUID(uuidString: "657B312A-F956-4BE4-866B-7C50A0DA5127")!
}
