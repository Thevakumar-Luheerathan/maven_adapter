import ballerina/http;
import ballerina/test;

@test:Mock {functionName: "intializePkgApiClient"}
function getMockPkgApiClient() returns http:Client|error {
    return test:mock(http:Client);
}

@test:Mock {functionName: "intializePkgGraphqlApiClient"}
function getMockPkgGraphqlApiClient() returns http:Client|error {
    return test:mock(http:Client);
}

http:Client testClient = check new ("http://localhost:9090/repository");

@test:Config {}
function testPackageSearch() returns error? {
    PackageSearchResult mockResult = {
        packages: [
            {
                organization: "ballerina",
                name: "http",
                version: "2.0.0",
                summary: "HTTP module",
                createdDate: 1234567890,
                authors: ["WSO2"]
            }
        ],
        count: 1,
        'limit: 10,
        offset: 0
    };
    test:prepare(pkgApiClient).when("get").withArguments("/packages?q=http").thenReturn(mockResult);
    http:Response response = check testClient->/__packagesearch__/q\=http/maven\-metadata\.xml;
    xml xmlPayload = check response.getXmlPayload();
    xml expectedXml = xml `<metadata>
                        <groupId>__packagesearch__</groupId>
                        <artifactId>q=http</artifactId>
                        <packages><package>
                    <org>ballerina</org>
                    <name>http</name>
                    <version>2.0.0</version>
                    <summary>HTTP module</summary>
                    <createdDate>1234567890</createdDate>
                    <authors><author>WSO2</author></authors>
                </package></packages>
                        <count>1</count>
                        <limit>10</limit>
                        <offset>0</offset>
                    </metadata>`;
    test:assertEquals(xmlPayload, expectedXml, msg = "Expected XML payload does not match the actual payload");
}

@test:Config {}
function testPackageSearchSolr() returns error? {
    PackageSearchSolrResult mockResult = {
        packages: [
            {
                id: 123,
                organization: "ballerina",
                name: "sql",
                version: "1.5.0",
                summary: "SQL module",
                createdDate: 1234567890,
                authors: ["WSO2"],
                balToolId: "ballerina-2201.0.0",
                keywords: ["database", "sql"],
                pullCount: 5000
            }
        ],
        count: 1,
        'limit: 10,
        offset: 0
    };
    test:prepare(pkgApiClient).when("get").withArguments("/search-packages?q=sql").thenReturn(mockResult);
    http:Response response = check testClient->/__packagesearchsolr__/q\=sql/maven\-metadata\.xml;
    xml xmlPayload = check response.getXmlPayload();
    xml expectedXml = xml `<metadata>
                <groupId>__packagesearchsolr__</groupId>
                <artifactId>q=sql</artifactId>
                    <packages><package>
                        <id>123</id>
                        <org>ballerina</org>
                        <name>sql</name>
                        <version>1.5.0</version>
                        <summary>SQL module</summary>
                        <createdDate>1234567890</createdDate>
                        <authors><author>WSO2</author></authors>
                        <balToolId>ballerina-2201.0.0</balToolId>
                        <keywords><keyword>database</keyword><keyword>sql</keyword></keywords>
                        <pullCount>5000</pullCount>
                    </package></packages>
                    <count>1</count>
                    <limit>10</limit>
                    <offset>0</offset>
            </metadata>`;
    test:assertEquals(xmlPayload, expectedXml, msg = "Expected XML payload does not match the actual payload");
}

@test:Config {}
function testSymbolSearch() returns error? {
    SymbolResponse mockResult = {
        symbols: [
            {
                id: "sym123",
                packageID: "pkg456",
                name: "Client",
                organization: "ballerina",
                version: "2.0.0",
                createdDate: 1234567890,
                icon: "icon.png",
                symbolType: "CLASS",
                symbolParent: "http",
                symbolName: "Client",
                description: "HTTP Client",
                symbolSignature: "public client class Client",
                isIsolated: true,
                isRemote: false,
                isResource: false,
                isClosed: false,
                isDistinct: false,
                isReadOnly: false
            }
        ],
        count: 1,
        'limit: 10,
        offset: 0
    };
    test:prepare(pkgApiClient).when("get").withArguments("/search-symbols?q=Client").thenReturn(mockResult);
    http:Response response = check testClient->/__symbolsearch__/q\=Client/maven\-metadata\.xml;
    xml xmlPayload = check response.getXmlPayload();
    xml expectedXml = xml `<metadata>
                <groupId>__symbolsearch__</groupId>
                <artifactId>q=Client</artifactId>
                <symbols><symbol>
                        <id>sym123</id>
                        <packageID>pkg456</packageID>
                        <name>Client</name>
                        <org>ballerina</org>
                        <version>2.0.0</version>
                        <createdDate>1234567890</createdDate>
                        <icon>icon.png</icon>
                        <symbolType>CLASS</symbolType>
                        <symbolParent>http</symbolParent>
                        <symbolName>Client</symbolName>
                        <description>HTTP Client</description>
                        <symbolSignature>public client class Client</symbolSignature>
                        <isIsolated>true</isIsolated>
                        <isRemote>false</isRemote>
                        <isResource>false</isResource>
                        <isClosed>false</isClosed>
                        <isDistinct>false</isDistinct>
                        <isReadOnly>false</isReadOnly>
                    </symbol></symbols>
                <count>1</count>
                <limit>10</limit>
                <offset>0</offset>
            </metadata>`;
    test:assertEquals(xmlPayload, expectedXml, msg = "Expected XML payload does not match the actual payload");
}

@test:Config {}
function testConnectorSearch() returns error? {
    ConnectorSearchResult mockResult = {
        connectors: [
            {
                id: 1,
                name: "http",
                displayName: "HTTP",
                moduleName: "http",
                icon: "http.png",
                documentation: "HTTP connector",
                functions: [
                    {
                        isRemote: true,
                        documentation: "GET request",
                        returnType: "http:Response|error"
                    }
                ],
                package: {
                    id: 100,
                    organization: "ballerina",
                    name: "http",
                    version: "2.0.0",
                    platform: "java17",
                    languageSpecificationVersion: "2024R1",
                    isDeprecated: false,
                    deprecateMessage: "",
                    URL: "https://central.ballerina.io",
                    balaVersion: "2.0",
                    balaURL: "https://example.com/http.bala",
                    digest: "abc123",
                    summary: "HTTP module",
                    readme: "README",
                    template: false,
                    licenses: ["Apache-2.0"],
                    authors: ["WSO2"],
                    sourceCodeLocation: "https://github.com/ballerina-platform/module-ballerina-http",
                    keywords: ["http", "client"],
                    ballerinaVersion: "2201.0.0",
                    icon: "icon.png",
                    ownerUUID: "uuid123",
                    createdDate: 1234567890,
                    pullCount: 10000,
                    visibility: "public",
                    modules: [],
                    balToolId: "ballerina-2201.0.0",
                    graalvmCompatible: "true"
                }
            }
        ],
        count: 1,
        'limit: 10,
        offset: 0
    };
    test:prepare(pkgApiClient).when("get").withArguments("/connectors?q=http").thenReturn(mockResult);
    http:Response response = check testClient->/__connectorsearch__/q\=http/maven\-metadata\.xml;
    xml xmlPayload = check response.getXmlPayload();
    xml expectedXml = xml `<metadata>
                <groupId>__connectorsearch__</groupId>
                <artifactId>q=http</artifactId>
                <connectors><connector>
                        <id>1</id>
                        <name>http</name>
                        <displayName>HTTP</displayName>
                        <moduleName>http</moduleName>
                        <icon>http.png</icon>
                        <documentation>HTTP connector</documentation>
                        <functions><function>
                                <isRemote>true</isRemote>
                                <documentation>GET request</documentation>
                                <returnType>http:Response|error</returnType>
                            </function></functions>
                        <package>
                            <id>100</id>
                            <organization>ballerina</organization>
                            <name>http</name>
                            <version>2.0.0</version>
                            <platform>java17</platform>
                            <languageSpecificationVersion>2024R1</languageSpecificationVersion>
                            <isDeprecated>false</isDeprecated>
                            <deprecateMessage></deprecateMessage>
                            <URL>https://central.ballerina.io</URL>
                            <balaVersion>2.0</balaVersion>
                            <balaURL>https://example.com/http.bala</balaURL>
                            <digest>abc123</digest>
                            <summary>HTTP module</summary>
                            <template>false</template>
                            <licenses><license>Apache-2.0</license></licenses>
                            <authors><author>WSO2</author></authors>
                            <sourceCodeLocation>https://github.com/ballerina-platform/module-ballerina-http</sourceCodeLocation>
                            <keywords><keyword>http</keyword><keyword>client</keyword></keywords>
                            <ballerinaVersion>2201.0.0</ballerinaVersion>
                            <icon>icon.png</icon>
                            <ownerUUID>uuid123</ownerUUID>
                            <createdDate>1234567890</createdDate>
                            <pullCount>10000</pullCount>
                            <visibility>public</visibility>
                            <balToolId>ballerina-2201.0.0</balToolId>
                            <graalvmCompatible>true</graalvmCompatible>
                        </package>
                    </connector></connectors>
                <count>1</count>
                <limit>10</limit>
                <offset>0</offset>
            </metadata>`;
    test:assertEquals(xmlPayload, expectedXml, msg = "Expected XML payload does not match the actual payload");
}

@test:Config {}
function testToolSearch() returns error? {
    ToolSearchResult mockResult = {
        tools: [
            {
                organization: "ballerina",
                name: "openapi",
                version: "1.0.0",
                summary: "OpenAPI tool",
                createdDate: 1234567890,
                authors: ["WSO2"],
                balToolId: "openapi-tool-1.0.0"
            }
        ],
        count: 1,
        'limit: 10,
        offset: 0
    };
    test:prepare(pkgApiClient).when("get").withArguments("/tools?q=openapi").thenReturn(mockResult);
    http:Response response = check testClient->/__toolsearch__/q\=openapi/maven\-metadata\.xml;
    xml xmlPayload = check response.getXmlPayload();
    xml expectedXml = xml `<metadata>
                        <groupId>__toolsearch__</groupId>
                        <artifactId>q=openapi</artifactId>
                        <tools><tool>
                    <org>ballerina</org>
                    <name>openapi</name>
                    <version>1.0.0</version>
                    <summary>OpenAPI tool</summary>
                    <createdDate>1234567890</createdDate>
                    <balToolId>openapi-tool-1.0.0</balToolId>
                </tool></tools>
                        <count>1</count>
                        <limit>10</limit>
                        <offset>0</offset>
                    </metadata>`;
    test:assertEquals(xmlPayload, expectedXml, msg = "Expected XML payload does not match the actual payload");
}

@test:Config {}
function testGetPackageMetadata() returns error? {
    http:Response mockVersionsResponse = new;
    mockVersionsResponse.statusCode = 200;
    json versionsJson = ["1.0.0", "2.0.0"];
    mockVersionsResponse.setJsonPayload(versionsJson);
    
    PackageMetadata mockMetadata1 = {
        platform: "java17",
        languageSpecificationVersion: "2024R1",
        isDeprecated: false,
        deprecateMessage: "",
        ballerinaVersion: "2201.0.0",
        modules: [],
        balToolId: "ballerina-2201.0.0",
        graalvmCompatible: "true"
    };
    
    PackageMetadata mockMetadata2 = {
        platform: "java17",
        languageSpecificationVersion: "2024R1",
        isDeprecated: false,
        deprecateMessage: "",
        ballerinaVersion: "2201.1.0",
        modules: [],
        balToolId: "ballerina-2201.1.0",
        graalvmCompatible: "true"
    };
    
    test:prepare(pkgApiClient).whenResource("::paths").withPathParameters({paths:["packages","ballerina","http"]}).onMethod("get").thenReturn(mockVersionsResponse);
    test:prepare(pkgApiClient).whenResource("::paths").withPathParameters({paths:["packages","ballerina","http","1.0.0"]}).onMethod("get").thenReturn(mockMetadata1);
    test:prepare(pkgApiClient).whenResource("::paths").withPathParameters({paths:["packages","ballerina","http","2.0.0"]}).onMethod("get").thenReturn(mockMetadata2);
    
    http:Response response = check testClient->/ballerina/http/maven\-metadata\.xml;
    xml xmlPayload = check response.getXmlPayload();
    xml expectedXml = xml `<metadata>
                            <groupId>ballerina</groupId>
                            <artifactId>http</artifactId>
                                <versions><version>
                <number>1.0.0</number>
                <platform>java17</platform>
                <isDeprecated>false</isDeprecated>
                <ballerinaVersion>2201.0.0</ballerinaVersion>
            </version><version>
                <number>2.0.0</number>
                <platform>java17</platform>
                <isDeprecated>false</isDeprecated>
                <ballerinaVersion>2201.1.0</ballerinaVersion>
            </version></versions>
                        </metadata>`;
    test:assertEquals(xmlPayload, expectedXml, msg = "Expected XML payload does not match the actual payload");
}

@test:Config {}
function testGetToolMetadata() returns error? {
    ToolMetadata mockToolMetadata = {
        organization: "ballerina",
        name: "openapi"
    };
    
    http:Response mockVersionsResponse = new;
    mockVersionsResponse.statusCode = 200;
    json versionsJson = ["1.0.0"];
    mockVersionsResponse.setJsonPayload(versionsJson);
    
    PackageMetadata mockMetadata = {
        platform: "java17",
        languageSpecificationVersion: "2024R1",
        isDeprecated: false,
        deprecateMessage: "",
        ballerinaVersion: "2201.0.0",
        modules: [],
        balToolId: "openapi-tool-1.0.0",
        graalvmCompatible: "true"
    };
    
    test:prepare(pkgApiClient).whenResource("::paths").onMethod("get").withPathParameters({paths:["tools","openapi"]}).thenReturn(mockToolMetadata);
    test:prepare(pkgApiClient).whenResource("::paths").onMethod("get").withPathParameters({paths:["packages","ballerina","openapi"]}).thenReturn(mockVersionsResponse);
    test:prepare(pkgApiClient).whenResource("::paths").onMethod("get").withPathParameters({paths:["packages","ballerina","openapi","1.0.0"]}).thenReturn(mockMetadata);
    
    http:Response response = check testClient->/__tools__/openapi/maven\-metadata\.xml;
    xml xmlPayload = check response.getXmlPayload();
    xml expectedXml = xml `<metadata>
                <groupId>__tools__</groupId>
                <artifactId>openapi</artifactId>
                <versions><version>
                        <number>1.0.0</number>
                        <platform>java17</platform>
                        <ballerinaVersion>2201.0.0</ballerinaVersion>
                    </version></versions>
                <org>ballerina</org>
                <package>openapi</package>
            </metadata>`;
    test:assertEquals(xmlPayload, expectedXml, msg = "Expected XML payload does not match the actual payload");
}

@test:Config {}
function testGetDependencyGraph() returns error? {
    http:Response mockDepGraphResponse = new;
    mockDepGraphResponse.statusCode = 200;
    json depGraphJson = {
        resolved: [
            {
                org: "ballerina",
                name: "http",
                version: "2.0.0"
            }
        ]
    };
    mockDepGraphResponse.setJsonPayload(depGraphJson);
    
    test:prepare(pkgApiClient)
        .whenResource("::paths").withPathParameters({paths:["packages","resolve-dependencies"]})
        .onMethod("post")
        .thenReturn(mockDepGraphResponse);
    http:Response response = check testClient->/ballerina/http/["2.0.0"]/["http-2.0.0-depgraph.json"];
    json jsonPayload = check response.getJsonPayload();
    test:assertEquals(jsonPayload, depGraphJson, msg = "Expected JSON payload does not match the actual payload");
}
