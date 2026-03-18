import ballerina/http;
import ballerina/log;

configurable string centralApiUrl = "https://api.central.ballerina.io/2.0/registry";
configurable string graphqlApiUrl = "https://api.central.ballerina.io/2.0";
configurable decimal clientTimeout = 300;

final http:Client pkgApiClient = check intializePkgApiClient();
final http:Client pkgGraphqlApiClient = check intializePkgGraphqlApiClient();

function intializePkgApiClient() returns http:Client|error {
    return check new (centralApiUrl, {timeout: clientTimeout});
}

function intializePkgGraphqlApiClient() returns http:Client|error {
    return check new (graphqlApiUrl, {timeout: clientTimeout});
}

isolated service /repository on new http:Listener(9090) {
    resource function get [string ballerinaVersion]/__packagesearch__/[string pkgQuery]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Searching the package metadata for query:${pkgQuery}`);
            string userAgent = transformBallerinaVersion(ballerinaVersion);
            PackageSearchResult searchResult = check pkgApiClient->get("/packages?" + pkgQuery, {"User-Agent": userAgent});

            xml[] packageEntries = [];
            PackageJsonSchema[]? packages = searchResult.packages;
            if packages is PackageJsonSchema[] {

                foreach PackageJsonSchema package in packages {
                    xml packageEntry = xml `<package>
                    <org>${package.organization}</org>
                    <name>${package.name}</name>
                    <version>${package.version}</version>
                    <summary>${package.summary}</summary>
                    <createdDate>${package.createdDate}</createdDate>
                    <authors>${buildAuthorsXml(package.authors)}</authors>
                </package>`;
                    packageEntries.push(packageEntry);
                }
            }
            xml packagesXml = xml:concat(...packageEntries);

            xml metadata = xml `<metadata>
                        <groupId>${ballerinaVersion}.__packagesearch__</groupId>
                        <artifactId>${pkgQuery}</artifactId>
                        <packages>${packagesXml}</packages>
                        <count>${searchResult.count ?: 0}</count>
                        <limit>${searchResult.'limit ?: 0}</limit>
                        <offset>${searchResult.offset ?: 0}</offset>
                    </metadata>`;
            return createXmlResponse(metadata);
        } on fail error err {
            return handleError("searching packages", string `query: ${pkgQuery}`, err);
        }
    }

    resource function get [string ballerinaVersion]/__packagesearchsolr__/[string pkgQuery]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Searching the package metadata for query:${pkgQuery}`);
            string userAgent = transformBallerinaVersion(ballerinaVersion);
            PackageSearchSolrResult pkgSolrResult = check pkgApiClient->get("/search-packages?" + pkgQuery, {"User-Agent": userAgent});
            xml[] packageEntries = [];
            Package[]? packages = pkgSolrResult.packages;
            if packages is Package[] {
                foreach Package package in packages {
                    xml packageEntry = xml `<package>
                        <id>${package.id}</id>
                        <org>${package.organization}</org>
                        <name>${package.name}</name>
                        <version>${package.version}</version>
                        <summary>${package.summary}</summary>
                        <createdDate>${package.createdDate}</createdDate>
                        <authors>${buildAuthorsXml(package.authors)}</authors>
                        <balToolId>${package.balToolId ?: ""}</balToolId>
                        <keywords>${buildKeywordsXml(package.keywords)}</keywords>
                        <pullCount>${package.pullCount}</pullCount>
                    </package>`;
                    packageEntries.push(packageEntry);
                }
            }
            xml packagesXml = xml:concat(...packageEntries);

            xml metadata = xml `<metadata>
                <groupId>${ballerinaVersion}.__packagesearchsolr__</groupId>
                <artifactId>${pkgQuery}</artifactId>
                    <packages>${packagesXml}</packages>
                    <count>${pkgSolrResult.count}</count>
                    <limit>${pkgSolrResult.'limit}</limit>
                    <offset>${pkgSolrResult.offset}</offset>
            </metadata>`;
            return createXmlResponse(metadata);
        } on fail error err {
            return handleError("searching packages (solr)", string `query: ${pkgQuery}`, err);
        }
    }

    resource function get [string ballerinaVersion]/__symbolsearch__/[string pkgQuery]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Searching the symbols for query:${pkgQuery}`);
            string userAgent = transformBallerinaVersion(ballerinaVersion);
            SymbolResponse symbolResponse = check pkgApiClient->get("/search-symbols?" + pkgQuery, {"User-Agent": userAgent});
            xml[] symbolEntries = [];
            Symbol[]? symbols = symbolResponse.symbols;
            if symbols is Symbol[] {
                foreach Symbol symbol in symbols {
                    xml symbolEntry = xml `<symbol>
                        <id>${symbol.id}</id>
                        <packageID>${symbol.packageID}</packageID>
                        <name>${symbol.name}</name>
                        <org>${symbol.organization}</org>
                        <version>${symbol.version}</version>
                        <createdDate>${symbol.createdDate}</createdDate>
                        <icon>${symbol.icon}</icon>
                        <symbolType>${symbol.symbolType}</symbolType>
                        <symbolParent>${symbol.symbolParent}</symbolParent>
                        <symbolName>${symbol.symbolName}</symbolName>
                        <description>${symbol.description}</description>
                        <symbolSignature>${symbol.symbolSignature}</symbolSignature>
                        <isIsolated>${symbol.isIsolated}</isIsolated>
                        <isRemote>${symbol.isRemote}</isRemote>
                        <isResource>${symbol.isResource}</isResource>
                        <isClosed>${symbol.isClosed}</isClosed>
                        <isDistinct>${symbol.isDistinct}</isDistinct>
                        <isReadOnly>${symbol.isReadOnly}</isReadOnly>
                    </symbol>`;
                    symbolEntries.push(symbolEntry);
                }
            }
            xml symbolsXml = xml:concat(...symbolEntries);

            xml metadata = xml `<metadata>
                <groupId>${ballerinaVersion}.__symbolsearch__</groupId>
                <artifactId>${pkgQuery}</artifactId>
                <symbols>${symbolsXml}</symbols>
                <count>${symbolResponse.count}</count>
                <limit>${symbolResponse.'limit}</limit>
                <offset>${symbolResponse.offset}</offset>
            </metadata>`;
            return createXmlResponse(metadata);
        } on fail error err {
            return handleError("searching symbols", string `query: ${pkgQuery}`, err);
        }
    }

    resource function get [string ballerinaVersion]/__connectorsearch__/[string pkgQuery]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Searching the connectors for query:${pkgQuery}`);
            string userAgent = transformBallerinaVersion(ballerinaVersion);
            ConnectorSearchResult connectorResult = check pkgApiClient->get("/connectors?" + pkgQuery, {"User-Agent": userAgent});
            xml[] connectorEntries = [];
            ConnectorsResultSchema[]? connectors = connectorResult.connectors;
            if connectors is ConnectorsResultSchema[] {
                foreach ConnectorsResultSchema connector in connectors {
                    xml[] functionEntries = [];
                    FunctionJsonSchema[]? functions = connector.functions;
                    if functions is FunctionJsonSchema[] {
                        foreach FunctionJsonSchema func in functions {
                            xml functionEntry = xml `<function>
                                <isRemote>${func.isRemote}</isRemote>
                                <documentation>${func.documentation ?: ""}</documentation>
                                <returnType>${func.returnType ?: ""}</returnType>
                            </function>`;
                            functionEntries.push(functionEntry);
                        }
                    }
                    xml functionsXml = xml:concat(...functionEntries);

                    ConnectorPackageSchema connectorPackage = connector.package;
                    xml keywordsXml = buildKeywordsXml(connectorPackage.keywords);
                    xml authorsXml = buildAuthorsXml(connectorPackage.authors);
                    xml licensesXml = buildLicensesXml(connectorPackage.licenses);

                    xml connectorEntry = xml `<connector>
                        <id>${connector.id}</id>
                        <name>${connector.name}</name>
                        <displayName>${connector.displayName ?: ""}</displayName>
                        <moduleName>${connector.moduleName ?: ""}</moduleName>
                        <icon>${connector.icon ?: ""}</icon>
                        <documentation>${connector.documentation ?: ""}</documentation>
                        <functions>${functionsXml}</functions>
                        <package>
                            <id>${connectorPackage.id}</id>
                            <organization>${connectorPackage.organization}</organization>
                            <name>${connectorPackage.name}</name>
                            <version>${connectorPackage.version}</version>
                            <platform>${connectorPackage.platform}</platform>
                            <languageSpecificationVersion>${connectorPackage.languageSpecificationVersion}</languageSpecificationVersion>
                            <isDeprecated>${connectorPackage.isDeprecated}</isDeprecated>
                            <deprecateMessage>${connectorPackage.deprecateMessage}</deprecateMessage>
                            <URL>${connectorPackage.URL}</URL>
                            <balaVersion>${connectorPackage.balaVersion}</balaVersion>
                            <balaURL>${connectorPackage.balaURL}</balaURL>
                            <digest>${connectorPackage.digest}</digest>
                            <summary>${connectorPackage.summary}</summary>
                            <template>${connectorPackage.template}</template>
                            <licenses>${licensesXml}</licenses>
                            <authors>${authorsXml}</authors>
                            <sourceCodeLocation>${connectorPackage.sourceCodeLocation}</sourceCodeLocation>
                            <keywords>${keywordsXml}</keywords>
                            <ballerinaVersion>${connectorPackage.ballerinaVersion}</ballerinaVersion>
                            <icon>${connectorPackage.icon}</icon>
                            <ownerUUID>${connectorPackage.ownerUUID}</ownerUUID>
                            <createdDate>${connectorPackage.createdDate}</createdDate>
                            <pullCount>${connectorPackage.pullCount}</pullCount>
                            <visibility>${connectorPackage.visibility}</visibility>
                            <balToolId>${connectorPackage.balToolId}</balToolId>
                            <graalvmCompatible>${connectorPackage.graalvmCompatible}</graalvmCompatible>
                        </package>
                    </connector>`;
                    connectorEntries.push(connectorEntry);
                }
            }
            xml connectorsXml = xml:concat(...connectorEntries);

            xml metadata = xml `<metadata>
                <groupId>${ballerinaVersion}.__connectorsearch__</groupId>
                <artifactId>${pkgQuery}</artifactId>
                <connectors>${connectorsXml}</connectors>
                <count>${connectorResult.count}</count>
                <limit>${connectorResult.'limit}</limit>
                <offset>${connectorResult.offset}</offset>
            </metadata>`;
            return createXmlResponse(metadata);
        } on fail error err {
            return handleError("searching connectors", string `query: ${pkgQuery}`, err);
        }
    }

    resource function get [string ballerinaVersion]/__tools__/[string toolId]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Requesting tool metadata for toolId:${toolId}`);
            string userAgent = transformBallerinaVersion(ballerinaVersion);
            ToolMetadata toolMetadata = check pkgApiClient->/tools/[toolId].get({"User-Agent": userAgent});
            string org = toolMetadata.organization;
            string packageName = toolMetadata.name;

            log:printInfo(string `Requesting versions for tool org:${org} package:${packageName}`);
            http:Response centralResponse = check pkgApiClient->/packages/[getEncodedUri(org)]/[getEncodedUri(packageName)].get({"User-Agent": userAgent});
            xml[] versionEntries = [];

            if centralResponse.statusCode == 200 {
                json responseJson = check centralResponse.getJsonPayload();
                string[] versions = check responseJson.cloneWithType();
                foreach string version in versions {
                    PackageMetadata versionMetadata = check pkgApiClient->/packages/[org]/[packageName]/[version].get({"User-Agent": userAgent});

                    xml versionEntry = xml `<version>
                        <number>${version}</number>
                        <platform>${versionMetadata.platform}</platform>
                        <ballerinaVersion>${versionMetadata.ballerinaVersion}</ballerinaVersion>
                    </version>`;
                    versionEntries.push(versionEntry);
                }
            }

            xml versionsXml = xml:concat(...versionEntries);
            xml metadata = xml `<metadata>
                <groupId>${ballerinaVersion}.__tools__</groupId>
                <artifactId>${toolId}</artifactId>
                <versions>${versionsXml}</versions>
                <org>${org}</org>
                <package>${packageName}</package>
            </metadata>`;

            return createXmlResponse(metadata);
        } on fail error err {
            return handleError("getting tool metadata", string `toolId: ${toolId}`, err);
        }
    }

    resource function get [string ballerinaVersion]/__toolsearch__/[string toolQuery]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Searching the package metadata for query:${toolQuery}`);
            string userAgent = transformBallerinaVersion(ballerinaVersion);
            ToolSearchResult searchResult = check pkgApiClient->get("/tools?" + toolQuery, {"User-Agent": userAgent});

            xml[] toolEntries = [];
            PackageJsonSchema[]? tools = searchResult.tools;
            if tools is PackageJsonSchema[] {

                foreach PackageJsonSchema tool in tools {
                    xml toolEntry = xml `<tool>
                    <org>${tool.organization}</org>
                    <name>${tool.name}</name>
                    <version>${tool.version}</version>
                    <summary>${tool.summary}</summary>
                    <createdDate>${tool.createdDate}</createdDate>
                    <balToolId>${tool.balToolId ?: ""}</balToolId>
                </tool>`;
                    toolEntries.push(toolEntry);
                }
            }
            xml toolsXml = xml:concat(...toolEntries);

            xml metadata = xml `<metadata>
                        <groupId>${ballerinaVersion}.__toolsearch__</groupId>
                        <artifactId>${toolQuery}</artifactId>
                        <tools>${toolsXml}</tools>
                        <count>${searchResult.count ?: 0}</count>
                        <limit>${searchResult.'limit ?: 0}</limit>
                        <offset>${searchResult.offset ?: 0}</offset>
                    </metadata>`;
            return createXmlResponse(metadata);
        } on fail error err {
            return handleError("searching tools", string `query: ${toolQuery}`, err);
        }
    }

    resource function get [string ballerinaVersion]/[string org]/[string package]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            string userAgent = transformBallerinaVersion(ballerinaVersion);
            return check getPackageMetadataXml(org, package, userAgent, ballerinaVersion);
        } on fail error err {
            return handleError("getting package metadata", string `org: ${org}, package: ${package}`, err);
        }
    }

    resource function get __tools__/[string toolId]/[string version]/[string balafile]() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Requesting the tool toolId:${toolId} version:${version}`);
            http:Response centralResponse = check pkgApiClient->/tools/[toolId]/[version];
            if centralResponse.statusCode != 200 {
                check error(string `Unexpected response encountered. Statuscode : ${centralResponse.statusCode}`);
            }
            json jsonPayload = check centralResponse.getJsonPayload();
            string filePath = check jsonPayload.balaURL;
            http:Client fileServer = check new (filePath);
            http:Response downloadResponse = check fileServer->get("");
            return downloadResponse;
        } on fail error err {
            return handleError("getting tool file", string `toolId: ${toolId}, version: ${version}`, err);
        }
    }

    isolated resource function get __function__/[string org]/[string package]/[string ver]/[string functionname]() returns http:Response|http:InternalServerError {
        do {
            //TODO: Generate actual function metadata content based on org, package and version
            return check getDependencyGraph(org, package, ver);
        } on fail error err {
            return handleError("getting function metadata", string `org: ${org}, package: ${package}, version: ${ver}`, err);
        }
    }

    isolated resource function get [string org]/[string package]/[string ver]/[string file]() returns http:Response|http:InternalServerError {
        do {
            if file.endsWith(".bala") {
                return check getBalaFile(org, package, ver);
            } else if (file.endsWith("-depgraph.json")) {
                return check getDependencyGraph(org, package, ver);
            } else if (file.endsWith("-listeners.json")) {
                return check getListenersJson(org, package, ver);
            }
            return {body: string `Requested file ${file} is not supported. Only .bala, -depgraph.json and -listeners.json files are supported.`};
        } on fail error err {
            return handleError("pulling artifact", string `org: ${org}, package: ${package}, version: ${ver}, file: ${file}`, err);
        }
    }

    resource function head [string... path]() returns json {
        return {};
    }

    resource function 'default [string... path](http:Request request) returns http:Ok {
        string requestPath = string:'join("/", ...path);
        string method = request.method;
        log:printInfo(string `Unmatched request: ${method} /repository/ballerina-central/${requestPath}`);
        return http:OK;
    }

}

isolated function getBalaFile(string org, string package, string ver) returns http:Response|error {
    log:printInfo(string `Requesting the package org:${org} package:${package} version:${ver}`);
    http:Response centralResponse = check pkgApiClient->/packages/[org]/[package]/[ver]({
        "Accept-Encoding": "identity",
        "Accept": "application/octet-stream"
    });
    if centralResponse.statusCode != 302 {
        check error(string `Unexpected response encountered. Statuscode : ${centralResponse.statusCode}`);
    }
    string filePath = check centralResponse.getHeader("Location");
    http:Client fileServer = check new (filePath);
    http:Response downloadResponse = check fileServer->get("");
    return downloadResponse;
}

isolated function getDependencyGraph(string org, string package, string ver) returns http:Response|error {
    log:printInfo(string `Requesting the dependency graph for org:${org} package:${package} version:${ver}`);
    http:Response centralResponse = check pkgApiClient->/packages/resolve\-dependencies.post({
        packages: [
            {
                org: org,
                name: package,
                version: ver,
                mode: "hard"
            }
        ]
    });
    return centralResponse;
}

isolated function getPackageMetadataXml(string org, string package, string userAgent, string ballerinaVersion) returns http:Response|error {
    log:printInfo(string `Requesting the package metadata for org:${org} package:${package}`);
    http:Response centralResponse = check pkgApiClient->/packages/[getEncodedUri(org)]/[getEncodedUri(package)].get({"User-Agent": userAgent});
    xml[] versionEntries = [];
    if centralResponse.statusCode == 200 {
        json responseJson = check centralResponse.getJsonPayload();
        string[] versions = check responseJson.cloneWithType();
        foreach string version in versions {
            PackageMetadata versionMetadata = check pkgApiClient->/packages/[org]/[package]/[version].get({"User-Agent": userAgent});
            xml versionEntry = xml `<version>
                <number>${version}</number>
                <platform>${versionMetadata.platform}</platform>
                <isDeprecated>${versionMetadata.isDeprecated.toString()}</isDeprecated>
                <ballerinaVersion>${versionMetadata.ballerinaVersion}</ballerinaVersion>
            </version>`;
            versionEntries.push(versionEntry);
        }
    }
    xml versionsXml = xml:concat(...versionEntries);
    xml metadata = xml `<metadata>
                            <groupId>${ballerinaVersion}.${org}</groupId>
                            <artifactId>${package}</artifactId>
                                <versions>${versionsXml}</versions>
                        </metadata>`;
    return createXmlResponse(metadata);
}

isolated function getListenersJson(string org, string package, string ver) returns http:Response|error {
    log:printInfo(string `Requesting listeners metadata for org:${org} package:${package} version:${ver}`);

    string graphqlQuery = string `query ApiDocs { apiDocs(inputFilter: { moduleInfo: { orgName: "${org}", moduleName: "${package}", version: "${ver}" } }) { docsData { modules { listeners } } } }`;

    json graphqlPayload = {
        query: graphqlQuery
    };

    http:Response graphqlResponse = check pkgGraphqlApiClient->/graphql.post(graphqlPayload);

    if graphqlResponse.statusCode != 200 {
        check error(string `GraphQL request failed with status code: ${graphqlResponse.statusCode}`);
    }
    json responseJson = check graphqlResponse.getJsonPayload();
    return createJsonResponse(responseJson);
}

