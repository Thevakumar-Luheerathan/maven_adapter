import ballerina/http;
import ballerina/io;
import ballerina/log;

service /repository on new http:Listener(9090) {
    final string serviceUrl = "https://api.central.ballerina.io/2.0/registry";
    final http:ClientConfiguration httpClientConfig = {timeout: 300};
    http:Client centralApiClient;

    public isolated function init() returns error? {
        self.centralApiClient = check new (self.serviceUrl, self.httpClientConfig);
    }

    resource function get [string org]/[string package]/[string version]/dependency\-graph\.json() returns http:Response|http:InternalServerError {
        do {
            log:printInfo(string `Requesting the dependency graph for org:${org} package:${package} version:${version}`);
            http:Response centralResponse = check self.centralApiClient->/packages/resolve\-dependencies.post( {
                packages: [
                    {
                        org: org,
                        name: package,
                        version: version,
                        mode: "hard"
                    }
                ]
            });
            return centralResponse;
        } on fail error err {
            log:printError(string `Error occured while getting dependency graph for org:${org} package:${package} version:${version} reason:${err.message()}`);
            return {body: string `Error occured while getting dependency graph for org:${org} package:${package} version:${version}`};
        }
    }
    
    resource function get [string org]/[string package]/[string version]/package\.json() returns http:Response|error {
        xml metadata = check io:fileReadXml("resources/mvn-meta-tool-search.xml");
        http:Response response = new;
        response.setXmlPayload(metadata);
        response.setHeader("Content-Type", "application/xml");
        return response;
    }

    isolated resource function get [string org]/[string package]/[string ver]/[string balafile]() returns http:Response|http:InternalServerError {
        do {
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
        } on fail error err {
            log:printError(string `Error occured while pulling the package org:${org} package:${package} version:${ver} reason:${err.message()}`);
            return {body: string `Error occured while pulling the package org:${org} package:${package} version:${ver}`};
        }
    }

    resource function get [string org]/[string package]/maven\-metadata\.xml() returns http:Response|error {
        // TODO: Generate actual maven-metadata.xml content based on org and package
        xml metadata = check io:fileReadXml("resources/mvn-meta-tool-search.xml");
        http:Response response = new;
        response.setXmlPayload(metadata);
        response.setHeader("Content-Type", "application/xml");
        return response;
    }

    resource function get __packagesearch__/[string pkgQuery]/maven\-metadata\.xml() returns http:Response|error {
        // TODO: Generate actual maven-metadata.xml content based on org and package
        xml metadata = check io:fileReadXml("resources/mvn-meta-tool-search.xml");
        http:Response response = new;
        response.setXmlPayload(metadata);
        response.setHeader("Content-Type", "application/xml");
        return response;
    }

    resource function get __toolesearch__/[string pkgQuery]/maven\-metadata\.xml() returns http:Response|error {
        // TODO: Generate actual maven-metadata.xml content based on org and package
        xml metadata = check io:fileReadXml("resources/mvn-meta-tool-search.xml");
        http:Response response = new;
        response.setXmlPayload(metadata);
        response.setHeader("Content-Type", "application/xml");
        return response;
    }

    resource function get __tools__/[string toolId]/maven\-metadata\.xml() returns http:Response|error {
        // TODO: Generate actual maven-metadata.xml content based on org and package
        xml metadata = check io:fileReadXml("resources/mvn-meta-tool-search.xml");
        http:Response response = new;
        response.setXmlPayload(metadata);
        response.setHeader("Content-Type", "application/xml");
        return response;
    }

    resource function get __tools__/[string toolId]/[string version]/[string balafile]() returns http:Response|error {
        xml metadata = check io:fileReadXml("resources/mvn-meta-tool-search.xml");
        http:Response response = new;
        response.setXmlPayload(metadata);
        response.setHeader("Content-Type", "application/xml");
        return response;
    }

    resource function 'default [string... path](http:Request request) returns http:Ok {
        string requestPath = string:'join("/", ...path);
        string method = request.method;
        log:printInfo(string `Unmatched request: ${method} /repository/ballerina-central/${requestPath}`);
        return http:OK;
    }

}
