import ballerina/http;
import ballerina/log;

type BalaFile string;

service /repository on new http:Listener(9090) {
    final string serviceUrl = "https://api.central.ballerina.io/2.0/registry";
    final http:ClientConfiguration httpClientConfig = {timeout: 300};
    http:Client centralApiClient;

    public isolated function init() returns error? {
        self.centralApiClient = check new (self.serviceUrl, self.httpClientConfig);
    }

    resource function get __packagesearch__/[string pkgQuery]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Searching the package metadata for query:${pkgQuery}`);
            PackageSearchResult searchResult = check self.centralApiClient->get("/packages?" + pkgQuery);

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
                    <authors>${xml:concat(...package.authors.map(a => xml `<author>${a}</author>`))}</authors>
                </package>`;
                    packageEntries.push(packageEntry);
                }
            }
            xml packagesXml = xml:concat(...packageEntries);

            xml metadata = xml `<metadata>
                        <groupId>__packagesearch__</groupId>
                        <artifactId>${pkgQuery}</artifactId>
                        <packages>${packagesXml}</packages>
                        <count>${searchResult.count ?: 0}</count>
                        <limit>${searchResult.'limit ?: 0}</limit>
                        <offset>${searchResult.offset ?: 0}</offset>
                    </metadata>`;
            http:Response response = new;
            response.setXmlPayload(metadata);
            response.setHeader("Content-Type", "application/xml");
            return response;
        } on fail error err {
            log:printError(string `Error occured while searching the package for the query:${pkgQuery} reason:${err.message()}`);
            return {body: string `Error occured while searching the package for the query:${pkgQuery}`};
        }
    }

    resource function get __packagesearchsolr__/[string pkgQuery]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Searching the package metadata for query:${pkgQuery}`);
            PackageSearchSolrResult pkgSolrResult = check self.centralApiClient->get("/search-packages?" + pkgQuery);
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
                        <authors>${xml:concat(...package.authors.map(a => xml `<author>${a}</author>`))}</authors>
                        <balToolId>${package.balToolId ?: ""}</balToolId>
                        <keywords>${xml:concat(...package.keywords.map(k => xml `<keyword>${k}</keyword>`))}</keywords>
                        <pullCount>${package.pullCount}</pullCount>
                    </package>`;
                    packageEntries.push(packageEntry);
                }
            }
            xml packagesXml = xml:concat(...packageEntries);

            xml metadata = xml `<metadata>
                <groupId>__packagesearchsolr__</groupId>
                <artifactId>${pkgQuery}</artifactId>
                    <packages>${packagesXml}</packages>
                    <count>${pkgSolrResult.count}</count>
                    <limit>${pkgSolrResult.'limit}</limit>
                    <offset>${pkgSolrResult.offset}</offset>
            </metadata>`;
            http:Response response = new;
            response.setXmlPayload(metadata);
            response.setHeader("Content-Type", "application/xml");
            return response;
        } on fail error err {
            log:printError(string `Error occured while searching the package for the query:${pkgQuery} reason:${err.message()}`);
            return {body: string `Error occured while searching the package for the query:${pkgQuery}`};
        }
    }

    resource function get __symbolsearch__/[string pkgQuery]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Searching the symbols for query:${pkgQuery}`);
            SymbolResponse symbolResponse = check self.centralApiClient->get("/search-symbols?" + pkgQuery);
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
                <groupId>__symbolsearch__</groupId>
                <artifactId>${pkgQuery}</artifactId>
                <symbols>${symbolsXml}</symbols>
                <count>${symbolResponse.count}</count>
                <limit>${symbolResponse.'limit}</limit>
                <offset>${symbolResponse.offset}</offset>
            </metadata>`;
            http:Response response = new;
            response.setXmlPayload(metadata);
            response.setHeader("Content-Type", "application/xml");
            return response;
        } on fail error err {
            log:printError(string `Error occured while searching symbols for the query:${pkgQuery} reason:${err.message()}`);
            return {body: string `Error occured while searching symbols for the query:${pkgQuery}`};
        }
    }

    resource function get __connectorsearch__/[string pkgQuery]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Searching the connectors for query:${pkgQuery}`);
            ConnectorSearchResult connectorResult = check self.centralApiClient->get("/connectors?" + pkgQuery);
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
                    xml[] keywordEntries = [];
                    foreach string keyword in connectorPackage.keywords {
                        keywordEntries.push(xml `<keyword>${keyword}</keyword>`);
                    }
                    xml keywordsXml = xml:concat(...keywordEntries);

                    xml[] authorEntries = [];
                    foreach string author in connectorPackage.authors {
                        authorEntries.push(xml `<author>${author}</author>`);
                    }
                    xml authorsXml = xml:concat(...authorEntries);

                    xml[] licenseEntries = [];
                    foreach string license in connectorPackage.licenses {
                        licenseEntries.push(xml `<license>${license}</license>`);
                    }
                    xml licensesXml = xml:concat(...licenseEntries);

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
                            <readme>${connectorPackage.readme}</readme>
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
                <groupId>__connectorsearch__</groupId>
                <artifactId>${pkgQuery}</artifactId>
                <connectors>${connectorsXml}</connectors>
                <count>${connectorResult.count}</count>
                <limit>${connectorResult.'limit}</limit>
                <offset>${connectorResult.offset}</offset>
            </metadata>`;
            http:Response response = new;
            response.setXmlPayload(metadata);
            response.setHeader("Content-Type", "application/xml");
            return response;
        } on fail error err {
            log:printError(string `Error occured while searching connectors for the query:${pkgQuery} reason:${err.message()}`);
            return {body: string `Error occured while searching connectors for the query:${pkgQuery}`};
        }
    }

    resource function get __tools__/[string toolId]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Requesting tool metadata for toolId:${toolId}`);
            ToolMetadata toolMetadata = check self.centralApiClient->/tools/[toolId];
            string org = toolMetadata.organization;
            string packageName = toolMetadata.name;
            
            log:printInfo(string `Requesting versions for tool org:${org} package:${packageName}`);
            http:Response centralResponse = check self.centralApiClient->/packages/[getEncodedUri(org)]/[getEncodedUri(packageName)].get();
            xml[] versionEntries = [];
            
            if centralResponse.statusCode == 200 {
                json responseJson = check centralResponse.getJsonPayload();
                string[] versions = check responseJson.cloneWithType();
                foreach string version in versions {
                    PackageMetadata versionMetadata = check self.centralApiClient->/packages/[org]/[packageName]/[version];
                    
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
                <groupId>__tools__</groupId>
                <artifactId>${toolId}</artifactId>
                <versions>${versionsXml}</versions>
                <org>${org}</org>
                <package>${packageName}</package>
            </metadata>`;
            
            http:Response response = new;
            response.setXmlPayload(metadata);
            response.setHeader("Content-Type", "application/xml");
            return response;
        } on fail error err {
            log:printError(string `Error occured while getting tool metadata for toolId:${toolId} reason:${err.message()}`);
            return {body: string `Error occured while getting tool metadata for toolId:${toolId}`};
        }
    }

    resource function get __tools__/[string toolId]/[string version]/[string balafile]() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Requesting the tool toolId:${toolId} version:${version}`);
            http:Response centralResponse = check self.centralApiClient->/tools/[toolId]/[version];
            if centralResponse.statusCode != 200 {
                check error(string `Unexpected response encountered. Statuscode : ${centralResponse.statusCode}`);
            }
            json jsonPayload = check centralResponse.getJsonPayload();
            string filePath = check jsonPayload.balaURL;
            http:Client fileServer = check new (filePath);
            http:Response downloadResponse = check fileServer->get("");
            return downloadResponse;
        } on fail error err {
            log:printError(string `Error occured while getting tool file for toolId:${toolId} version:${version} reason:${err.message()}`);
            return {body: string `Error occured while getting tool file for toolId:${toolId} version:${version}`};
        }
    }

    resource function get __toolsearch__/[string toolQuery]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Searching the package metadata for query:${toolQuery}`);
            ToolSearchResult searchResult = check self.centralApiClient->get("/tools?" + toolQuery);

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
                        <groupId>__toolsearch__</groupId>
                        <artifactId>${toolQuery}</artifactId>
                        <tools>${toolsXml}</tools>
                        <count>${searchResult.count ?: 0}</count>
                        <limit>${searchResult.'limit ?: 0}</limit>
                        <offset>${searchResult.offset ?: 0}</offset>
                    </metadata>`;
            http:Response response = new;
            response.setXmlPayload(metadata);
            response.setHeader("Content-Type", "application/xml");
            return response;
        } on fail error err {
            log:printError(string `Error occured while searching the package for the query:${toolQuery} reason:${err.message()}`);
            return {body: string `Error occured while searching the package for the query:${toolQuery}`};
        }
    }

    isolated resource function get __function__/[string org]/[string package]/[string ver]/[string functionname]() returns http:Response|http:InternalServerError {
        do {
            //TODO: Generate actual function metadata content based on org, package and version
            return check self.getDependencyGraph(org, package, ver);
        } on fail error err {
            log:printError(string `Error occured while pulling the artifact org:${org} package:${package} version:${ver} reason:${err.message()}`);
            return {body: string `Error occured while pulling the artifact org:${org} package:${package} version:${ver}`};
        }
    }

    isolated resource function get [string org]/[string package]/[string ver]/[string file]() returns http:Response|http:InternalServerError {
        do {
            if file.endsWith(".bala") {
                return check self.getBalaFile(org, package, ver);
            } else if (file.endsWith("-depgraph.json")) {
                return check self.getDependencyGraph(org, package, ver);
            }
            return {body: string `Requested file ${file} is not supported. Only .bala and -depgraph.json files are supported.`};
        } on fail error err {
            log:printError(string `Error occured while pulling the artifact org:${org} package:${package} version:${ver} reason:${err.message()}`);
            return {body: string `Error occured while pulling the artifact org:${org} package:${package} version:${ver}`};
        }
    }

    resource function get [string org]/[string package]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            return check self.getPackageMetadataXml(org, package);
        } on fail error err {
            log:printError(string `Error occured while getting package metadata for org:${org} package:${package} reason:${err.message()}`);
            return {body: string `Error occured while getting package metadata for org:${org} package:${package}`};
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

    isolated function getBalaFile(string org, string package, string ver) returns http:Response|error {
        log:printInfo(string `Requesting the package org:${org} package:${package} version:${ver}`);
        http:Response centralResponse = check self.centralApiClient->/packages/[org]/[package]/[ver]({
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
        http:Response centralResponse = check self.centralApiClient->/packages/resolve\-dependencies.post({
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

    isolated function getPackageMetadataXml(string org, string package) returns http:Response|error {
        log:printInfo(string `Requesting the package metadata for org:${org} package:${package}`);
        http:Response centralResponse = check self.centralApiClient->/packages/[getEncodedUri(org)]/[getEncodedUri(package)].get();
        xml[] versionEntries = [];
        if centralResponse.statusCode == 200 {
            json responseJson = check centralResponse.getJsonPayload();
            string[] versions = check responseJson.cloneWithType();
            foreach string version in versions {
                PackageMetadata versionMetadata = check self.centralApiClient->/packages/[org]/[package]/[version];
                xml[] moduleEntries = [];
                foreach ModuleInfo moduleInfo in versionMetadata.modules {
                    xml moduleEntry = xml `<module>
                                                <name>${moduleInfo.name}</name>
                                            </module>`;
                    moduleEntries.push(moduleEntry);
                }
                xml modulesXml = xml:concat(...moduleEntries);

                xml versionEntry = xml `<Bversion>
                <number>${version}</number>
                <platform>${versionMetadata.platform}</platform>
                <languageSpecificationVersion>${versionMetadata.languageSpecificationVersion}</languageSpecificationVersion>
                <isDeprecated>${versionMetadata.isDeprecated.toString()}</isDeprecated>
                <deprecateMessage>${versionMetadata.deprecateMessage}</deprecateMessage>
                <ballerinaVersion>${versionMetadata.ballerinaVersion}</ballerinaVersion>
                <balToolId>${versionMetadata.balToolId}</balToolId>
                <graalvmCompatible>${versionMetadata.graalvmCompatible}</graalvmCompatible>
                <modules>${modulesXml}</modules>
            </Bversion>`;
                versionEntries.push(versionEntry);
            }
        }
        xml versionsXml = xml:concat(...versionEntries);
        xml metadata = xml `<metadata>
                            <groupId>${org}</groupId>
                            <artifactId>${package}</artifactId>
                                <Bversions>${versionsXml}</Bversions>
                        </metadata>`;
        http:Response response = new;
        response.setXmlPayload(metadata);
        response.setHeader("Content-Type", "application/xml");
        return response;
    }
}

