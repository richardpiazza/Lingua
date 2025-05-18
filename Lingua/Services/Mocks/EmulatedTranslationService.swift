import AsyncPlus
import Foundation
import TranslationCatalog

class EmulatedTranslationService: TranslationService {
    
    var translations: [TranslationCatalog.Translation]
    
    private var streams: [TranslationCatalog.Expression.ID: CurrentValueAsyncSubject<[TranslationCatalog.Translation]>] = [:]
    
    init(
        translations: [TranslationCatalog.Translation] = [
            .en,
            .es
        ]
    ) {
        self.translations = translations
    }
    
    func translations(for expressionId: TranslationCatalog.Expression.ID) async -> AsyncStream<[TranslationCatalog.Translation]> {
        if let stream = streams[expressionId] {
            return await stream.sink()
        }
        
        let stream = CurrentValueAsyncSubject<[TranslationCatalog.Translation]>([])
        streams[expressionId] = stream
        
        await stream.yield(translations)
        
        return await stream.sink()
    }
    
    func createTranslation(_ translation: TranslationCatalog.Translation) throws -> TranslationCatalog.Translation.ID {
        throw CocoaError(.featureUnsupported)
    }
    
    func updateTranslation(_ translation: TranslationCatalog.Translation) throws {
        throw CocoaError(.featureUnsupported)
    }
    
    func deleteTranslation(_ id: TranslationCatalog.Translation.ID) throws {
        throw CocoaError(.featureUnsupported)
    }
}

extension TranslationCatalog.Translation {
    static let en = TranslationCatalog.Translation(
        id: UUID(uuidString: "44D91ADB-DAB3-4311-AD4C-A28E9F6684FD")!,
        languageCode: .en,
        regionCode: .US,
        value: "This is an english string."
    )
    static let es = TranslationCatalog.Translation(
        id: UUID(uuidString: "6B29D6D2-D601-4EDF-9A46-9E828A68866A")!,
        languageCode: .es,
        regionCode: .ES,
        value: "Esta es una cadena inglesa."
    )
}
