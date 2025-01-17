public extension ASTNode {
    enum ContentType: String {
        case `enum` = "Enum"
        case `private` = "private"
        case `public` = "public"
        case accessSpecDecl = "AccessSpecDecl"
        case alignedAttr = "AlignedAttr"
        case alwaysInlineAttr = "AlwaysInlineAttr"
        case arrayInitLoopExpr = "ArrayInitLoopExpr"
        case arraySubscriptExpr = "ArraySubscriptExpr"
        case asTypeExpr = "AsTypeExpr"
        case asmLabelAttr = "AsmLabelAttr"
        case binaryOperator = "BinaryOperator"
        case breakStmt = "BreakStmt" 
        case builtinTemplateDecl = "BuiltinTemplateDecl"
        case builtinType = "BuiltinType"
        case cStyleCastExpr = "CStyleCastExpr"
        case cXXBoolLiteralExpr = "CXXBoolLiteralExpr"
        case cXXConstCastExpr = "CXXConstCastExpr"
        case cXXConstructExpr = "CXXConstructExpr"
        case cXXConstructorDecl = "CXXConstructorDecl"
        case cXXConversionDecl = "CXXConversionDecl"
        case cXXCtorInitializer = "CXXCtorInitializer"
        case cXXDefaultArgExpr = "CXXDefaultArgExpr"
        case cXXDependentScopeMemberExpr = "CXXDependentScopeMemberExpr"
        case cXXDestructorDecl = "CXXDestructorDecl"
        case cXXFunctionalCastExpr = "CXXFunctionalCastExpr"
        case cXXMemberCallExpr = "CXXMemberCallExpr"
        case cXXMethodDecl = "CXXMethodDecl"
        case cXXNullPtrLiteralExpr = "CXXNullPtrLiteralExpr"
        case cXXOperatorCallExpr = "CXXOperatorCallExpr"
        case cXXRecord = "CXXRecord"
        case cXXRecordDecl = "CXXRecordDecl"
        case cXXReinterpretCastExpr = "CXXReinterpretCastExpr"
        case cXXScalarValueInitExpr = "CXXScalarValueInitExpr"
        case cXXStaticCastExpr = "CXXStaticCastExpr"
        case cXXStdInitializerListExpr = "CXXStdInitializerListExpr"
        case cXXTemporaryObjectExpr = "CXXTemporaryObjectExpr"
        case cXXThisExpr = "CXXThisExpr"
        case cXXUnresolvedConstructExpr = "CXXUnresolvedConstructExpr"
        case callExpr = "CallExpr"
        case classTemplateDecl = "ClassTemplateDecl"
        case classTemplatePartialSpecializationDecl = "ClassTemplatePartialSpecializationDecl"
        case classTemplateSpecialization = "ClassTemplateSpecialization"
        case classTemplateSpecializationDecl = "ClassTemplateSpecializationDecl"
        case compoundAssignOperator = "CompoundAssignOperator"
        case compoundStmt = "CompoundStmt"
        case conditionalOperator = "ConditionalOperator"
        case constAttr = "ConstAttr"
        case continueStmt = "ContinueStmt"
        case copyAssignment = "CopyAssignment"
        case copyConstructor = "CopyConstructor"
        case declRefExpr = "DeclRefExpr"
        case declStmt = "DeclStmt"
        case decltypeType = "DecltypeType"
        case definitionData = "DefinitionData"
        case defaultConstructor = "DefaultConstructor"
        case dependentNameType = "DependentNameType"
        case dependentScopeDeclRefExpr = "DependentScopeDeclRefExpr"
        case dependentSizedExtVectorType = "DependentSizedExtVectorType"
        case deprecatedAttr = "DeprecatedAttr"
        case destructor = "Destructor"
        case elaboratedType = "ElaboratedType"
        case enableIfAttr = "EnableIfAttr"
        case enumConstantDecl = "EnumConstantDecl"
        case enumDecl = "EnumDecl"
        case enumType = "EnumType"
        case exprWithCleanups = "ExprWithCleanups"
        case extVectorElementExpr = "ExtVectorElementExpr"
        case extVectorType = "ExtVectorType"
        case fieldDecl = "FieldDecl"
        case floatingLiteral = "FloatingLiteral"
        case forStmt = "ForStmt"
        case friendDecl = "FriendDecl"
        case fullComment = "FullComment"
        case function = "Function"
        case functionDecl = "FunctionDecl"
        case functionTemplateDecl = "FunctionTemplateDecl"
        case ifStmt = "IfStmt"
        case implicitCastExpr = "ImplicitCastExpr"
        case initListExpr = "InitListExpr"
        case injectedClassNameType = "InjectedClassNameType"
        case integerLiteral = "IntegerLiteral"
        case lValueReferenceType = "LValueReferenceType"
        case linkageSpecDecl = "LinkageSpecDecl"
        case materializeTemporaryExpr = "MaterializeTemporaryExpr"
        case memberExpr = "MemberExpr"
        case metalAttributeIndexAttr = "MetalAttributeIndexAttr"
        case metalAsTypeCastExpr = "MetalAsTypeCastExpr"
        case metalBufferIndexAttr = "MetalBufferIndexAttr"
        case metalFlatAttr = "MetalFlatAttr"
        case metalFragmentAttr = "MetalFragmentAttr"
        case metalFunctionConstantAttr = "MetalFunctionConstantAttr"
        case metalStageInGridSizeAttr = "MetalStageInGridSizeAttr"
        case metalIdAttr = "MetalIdAttr"
        case metalInstanceIdAttr = "MetalInstanceIdAttr"
        case metalKernelAttr = "MetalKernelAttr"
        case metalLocalIndexAttr = "MetalLocalIndexAttr"
        case metalPositionAttr = "MetalPositionAttr"
        case metalSamplerIndexAttr = "MetalSamplerIndexAttr"
        case metalStageInAttr = "MetalStageInAttr"
        case metalTextureIndexAttr = "MetalTextureIndexAttr"
        case metalThreadIndexGroupAttr = "MetalThreadIndexGroupAttr"
        case metalThreadPosGridAttr = "MetalThreadPosGridAttr"
        case metalThreadPosGroupAttr = "MetalThreadPosGroupAttr"
        case metalThreadsPerGroupAttr = "MetalThreadsPerGroupAttr"
        case metalThreadsPerGridAttr = "MetalThreadsPerGridAttr"
        case metalVectorInitExpr = "MetalVectorInitExpr"
        case metalVertexAttr = "MetalVertexAttr"
        case metalVertexIdAttr = "MetalVertexIdAttr"
        case moveAssignment = "MoveAssignment"
        case moveConstructor = "MoveConstructor"
        case namespace = "Namespace"
        case namespaceAliasDecl = "NamespaceAliasDecl"
        case namespaceDecl = "NamespaceDecl"
        case noThrowAttr = "NoThrowAttr"
        case nonTypeTemplateParmDecl = "NonTypeTemplateParmDecl"
        case nullStmnt = "NullStmt"
        case opaqueValueExpr = "OpaqueValueExpr"
        case original = "original"
        case packExpansionExpr = "PackExpansionExpr"
        case paragraphComment = "ParagraphComment"
        case parenExpr = "ParenExpr"
        case parenListExpr = "ParenListExpr"
        case parmVarDecl = "ParmVarDecl"
        case pointerType = "PointerType"
        case pureAttr = "PureAttr"
        case qualType = "QualType"
        case recordType = "RecordType"
        case returnStmt = "ReturnStmt"
        case sizeOfPackExpr = "SizeOfPackExpr"
        case staticAssertDecl = "StaticAssertDecl"
        case stringLiteral = "StringLiteral"
        case substNonTypeTemplateParmExpr = "SubstNonTypeTemplateParmExpr"
        case substTemplateTypeParmType = "SubstTemplateTypeParmType"
        case templateArgument = "TemplateArgument"
        case templateSpecializationType = "TemplateSpecializationType"
        case templateTemplateParmDecl = "TemplateTemplateParmDecl"
        case templateTypeParm = "TemplateTypeParm"
        case templateTypeParmDecl = "TemplateTypeParmDecl"
        case templateTypeParmType = "TemplateTypeParmType"
        case textComment = "TextComment"
        case translationUnitDecl = "TranslationUnitDecl"
        case typeAliasDecl = "TypeAliasDecl"
        case typeAliasTemplateDecl = "TypeAliasTemplateDecl"
        case typedef = "Typedef"
        case typedefDecl = "TypedefDecl"
        case typedefType = "TypedefType"
        case unaryExprOrTypeTraitExpr = "UnaryExprOrTypeTraitExpr"
        case unaryOperator = "UnaryOperator"
        case unaryTransformType = "UnaryTransformType"
        case unresolvedLookupExpr = "UnresolvedLookupExpr"
        case unresolvedMemberExpr = "UnresolvedMemberExpr"
        case unresolvedUsingValueDecl = "UnresolvedUsingValueDecl"
        case usingDirectiveDecl = "UsingDirectiveDecl"
        case varDecl = "VarDecl"
        case varTemplateDecl = "VarTemplateDecl"
        case varTemplateSpecializationDecl = "VarTemplateSpecializationDecl"
        case whileStmt = "WhileStmt"
        case stmtExpr = "StmtExpr"
        case array = "array"
    }
}
