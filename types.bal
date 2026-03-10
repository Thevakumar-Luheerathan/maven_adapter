public type PackageMetadata record {
    string platform;
    string languageSpecificationVersion;
    boolean isDeprecated;
    string deprecateMessage;
    string ballerinaVersion;
    ModuleInfo[] modules;
    string balToolId;
    string graalvmCompatible;
};

public type ToolMetadata record {
    string organization;
    string name;
};

public type ModuleInfo record {
    string name;
};

public type ConnectorsResultSchema record {
    int id;
    string name;
    string displayName?;
    string moduleName?;
    FunctionJsonSchema[]? functions;
    record {} displayAnnotation?;
    ConnectorPackageSchema package;
    string icon?;
    string documentation?;
};

public type ConnectorPackageSchema record {
    int id;
    string organization;
    string name;
    string version;
    string platform;
    string languageSpecificationVersion;
    boolean isDeprecated;
    string deprecateMessage;
    string URL;
    string balaVersion;
    string balaURL;
    string digest;
    string summary;
    string readme;
    boolean template;
    string[] licenses;
    string[] authors;
    string sourceCodeLocation;
    string[] keywords;
    string ballerinaVersion;
    string icon;
    string ownerUUID;
    int createdDate;
    int pullCount;
    string visibility;
    ModuleInfo[] modules;
    string balToolId;
    string graalvmCompatible;
};

public type FunctionJsonSchema record {
    boolean isRemote;
    string documentation?;
    record {}[] parameters?;
    string returnType?;
    record {} displayAnnotation?;
};

public type ConnectorSearchResult record {
    ConnectorsResultSchema[]? connectors;
    int count;
    int 'limit;
    int offset;
};

public type ToolSearchResult record {
    PackageJsonSchema[] tools?;
    int count?;
    int 'limit?;
    int offset?;
};

public type PackageSearchResult record {
    PackageJsonSchema[] packages?;
    int count?;
    int 'limit?;
    int offset?;
};

public type PackageJsonSchema record {
    string organization;
    string name;
    string version;
    string summary;
    int createdDate;
    string[] authors;
    string balToolId?;
};


public type PackageSearchSolrResult record {
    Package[] packages;
    int count;
    int 'limit;
    int offset;
};


public type Package record {
    int id;
    string organization;
    string name;
    string version;
    string summary;
    int createdDate;
    string[] authors;
    string balToolId?;
    string[] keywords = [];
    int pullCount;
};

type Symbol record {
    string id;
    string packageID;
    string name;
    string organization;
    string version;
    int createdDate;
    string icon;
    string symbolType;
    string symbolParent;
    string symbolName;
    string description;
    string symbolSignature;
    boolean isIsolated;
    boolean isRemote;
    boolean isResource;
    boolean isClosed;
    boolean isDistinct;
    boolean isReadOnly;
};

type SymbolResponse record {
    Symbol[] symbols;
    int count;
    int offset;
    int 'limit;
};
