import SwiftUI
import Combine
import TranslationCatalog
import Logging
import CodeQuickKit

struct ExpressionView: View {

    let id: Expression.ID
    let expressionService: ExpressionService
    let logger: Logger
    private var publisher: AnyPublisher<Expression?, Never>!
    
    @State private var expression: Expression? {
        didSet {
            name = expression?.name ?? ""
            key = expression?.key ?? ""
            feature = expression?.feature ?? ""
            context = expression?.context ?? ""
        }
    }
    @State private var name: String = ""
    @State private var key: String = ""
    @State private var feature: String = ""
    @State private var context: String = ""
    
    init(_ id: Expression.ID, expressionService: ExpressionService? = nil, logger: Logger? = nil) {
        self.id = id
        if let service = expressionService {
            self.expressionService = service
        } else {
            @Dependency var dependency: ExpressionService
            self.expressionService = dependency
        }
        if let logger = logger {
            self.logger = logger
        } else {
            @Dependency var dependency: Logger
            self.logger = dependency
        }
        
        publisher = self.expressionService.monitorExpression(id)
            .replaceError(with: Expression())
            .flatMap { expression in
                let output: Expression? = (expression == Expression()) ? nil : expression
                return Just<Expression?>(output).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ExpressionFieldView(
                value: $name,
                name: "Name",
                hint: "Your reference to this Expression",
                disabled: expression == nil
            )
            .onChange(of: name, perform: { value in
                do {
                    try expressionService.updateExpression(id, update: .name(value))
                } catch {
                    logger.error("Failed to Update Expression.", error: error)
                }
            })
            
            ExpressionFieldView(
                value: $key,
                name: "Localization Key",
                hint: "Unique value that globally identifies this Expression",
                disabled: expression == nil
            )
            .onChange(of: key, perform: { value in
                do {
                    try expressionService.updateExpression(id, update: .key(value))
                } catch {
                    logger.error("Failed to Update Expression.", error: error)
                }
            })
            
            ExpressionFieldView(
                value: $context,
                name: "Context",
                hint: "Hints to translators as to how this Expression is used",
                disabled: expression == nil
            )
            .onChange(of: context, perform: { value in
                do {
                    try expressionService.updateExpression(id, update: .context(value))
                } catch {
                    logger.error("Failed to Update Expression.", error: error)
                }
            })
            
            ExpressionFieldView(
                value: $feature,
                name: "Feature",
                hint: "Classification that groups this Expression with others in your App",
                disabled: expression == nil
            )
            .onChange(of: feature, perform: { value in
                do {
                    try expressionService.updateExpression(id, update: .feature(value))
                } catch {
                    logger.error("Failed to Update Expression.", error: error)
                }
            })
        }
        .onReceive(publisher, perform: { value in
            expression = value
        })
    }
}

struct ExpressionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExpressionView(Expression.preview.id, expressionService: EmulatedExpressionService())
            ExpressionView(Expression.preview_new.id, expressionService: EmulatedExpressionService())
        }
    }
}
