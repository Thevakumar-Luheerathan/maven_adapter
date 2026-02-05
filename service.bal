import ballerina/http;
import ballerina/io;
import ballerina/log;

service /repository on new http:Listener(9090) {

    resource function get [string org]/[string package]/[string version]/dependency\-graph\.json() returns http:Response|error {
        xml metadata = check io:fileReadXml("resources/mvn-meta-tool-search.xml");
        http:Response response = new;
        response.setXmlPayload(metadata);
        response.setHeader("Content-Type", "application/xml");
        return response;
    }

    resource function get [string org]/[string package]/[string version]/package\.json() returns http:Response|error {
        xml metadata = check io:fileReadXml("resources/mvn-meta-tool-search.xml");
        http:Response response = new;
        response.setXmlPayload(metadata);
        response.setHeader("Content-Type", "application/xml");
        return response;
    }

    resource function get [string org]/[string package]/[string version]/[string balafile]() returns http:Response|error {
        xml metadata = check io:fileReadXml("resources/mvn-meta-tool-search.xml");
        http:Response response = new;
        response.setXmlPayload(metadata);
        response.setHeader("Content-Type", "application/xml");
        return response;
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
