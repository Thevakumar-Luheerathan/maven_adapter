import ballerina/constraint;
import ballerina/file;
import ballerina/http;
import ballerina/io;
import ballerina/log;

@constraint:String {
    pattern: {
        value: re `.*-depgraph\.json`,
        message: "File name must end with -depgraph.json"
    }
}
type DepGraphFile string;

@constraint:String {
    pattern: {
        value: re `.*\.bala`,
        message: "File name must end with -depgraph.json"
    }
}
type BalaFile string;

service /repository on new http:Listener(9090) {
    final string serviceUrl = "https://api.central.ballerina.io/2.0/registry";
    final http:ClientConfiguration httpClientConfig = {timeout: 300};
    http:Client centralApiClient;

    public isolated function init() returns error? {
        self.centralApiClient = check new (self.serviceUrl, self.httpClientConfig);
    }

    // resource function get [string org]/[string package]/[string version]/[DepGraphFile depGraphFile]() returns http:Response|http:InternalServerError {
    //     do {

    //     } on fail error err {
    //         log:printError(string `Error occured while getting dependency graph for org:${org} package:${package} version:${version} reason:${err.message()}`);
    //         return {body: string `Error occured while getting dependency graph for org:${org} package:${package} version:${version}`};
    //     }
    // }

    resource function get [string org]/[string package]/[string version]/package\.json() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Requesting the package json for org:${org} package:${package} version:${version}`);
            http:Response centralResponse = check self.centralApiClient->/packages/[org]/[package]/[version]({
                "Accept-Encoding": "identity",
                "Accept": "application/octet-stream"
            });
            if centralResponse.statusCode != 302 {
                check error(string `Unexpected response encountered. Statuscode : ${centralResponse.statusCode}`);
            }
            string filePath = check centralResponse.getHeader("Location");
            http:Client fileServer = check new (filePath);
            http:Response downloadResponse = check fileServer->get("");

            string tempBalaDir = check file:createTempDir();
            string tempBalaFile = check file:joinPath(tempBalaDir, "temp.bala");
            stream<byte[], io:Error?> byteStream = check downloadResponse.getByteStream();
            io:Error? writeResult = io:fileWriteBlocksFromStream(tempBalaFile, byteStream);
            if writeResult is io:Error {
                check error(string `Failed to write the downloaded bala file to disk`);
            }
            check byteStream.close();
            json packageJson = check getPackageJsonFromBala(tempBalaDir, tempBalaFile);
            http:Response response = new;
            response.setJsonPayload(packageJson);
            response.setHeader("Content-Type", "application/json");
            return response;
        } on fail error err {
            log:printError(string `Error occured while getting package json for org:${org} package:${package} version:${version} reason:${err.message()}`);
            return {body: string `Error occured while getting package json for org:${org} package:${package} version:${version}`};
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
        } on fail error err {
            log:printError(string `Error occured while getting package metadata for org:${org} package:${package} reason:${err.message()}`);
            return {body: string `Error occured while getting package metadata for org:${org} package:${package}`};
        }
    }

    resource function get __packagesearch__/[string pkgQuery]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Searching the package metadata for query:${pkgQuery}`);
            inline_response_200 searchResult = check self.centralApiClient->/packages.get(q = getEncodedUri(pkgQuery));

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

    resource function get __toolesearch__/[string pkgQuery]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            // TODO: Generate actual maven-metadata.xml content based on org and package
            xml metadata = check io:fileReadXml("resources/mvn-meta-tool-search.xml");
            http:Response response = new;
            response.setXmlPayload(metadata);
            response.setHeader("Content-Type", "application/xml");
            return response;
        } on fail error err {
            log:printError(string `Error occured while getting the tool for the query:${pkgQuery} reason:${err.message()}`);
            return {body: string `Error occured while getting the tool for the query:${pkgQuery}`};
        }
    }

    resource function get __tools__/[string toolId]/maven\-metadata\.xml() returns http:Response|http:InternalServerError {
        do {
            // TODO: Generate actual maven-metadata.xml content based on org and package
            xml metadata = check io:fileReadXml("resources/mvn-meta-tool-search.xml");
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
            xml metadata = check io:fileReadXml("resources/mvn-meta-tool-search.xml");
            http:Response response = new;
            response.setXmlPayload(metadata);
            response.setHeader("Content-Type", "application/xml");
            return response;
        } on fail error err {
            log:printError(string `Error occured while getting tool file for toolId:${toolId} version:${version} reason:${err.message()}`);
            return {body: string `Error occured while getting tool file for toolId:${toolId} version:${version}`};
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
}

