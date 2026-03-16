import ballerina/http;
import ballerina/log;
import ballerina/url;

# Get Encoded URI for a given value.
#
# + value - Value to be encoded
# + return - Encoded string
public isolated function getEncodedUri(anydata value) returns string {
    string|error encoded = url:encode(value.toString(), "UTF8");
    if encoded is string {
        return encoded;
    } else {
        return value.toString();
    }
}

# Handle errors and return appropriate HTTP error response.
#
# + operation - Operation being performed
# + message - Context message
# + err - Error that occurred
# + return - HTTP Internal Server Error response
public isolated function handleError(string operation, string message, error err) returns http:InternalServerError {
    string errorMessage = string `Error occurred while ${operation}: ${message}`;
    log:printError(errorMessage, reason = err.message());
    return {body: errorMessage};
}

# Create XML HTTP response with proper headers.
#
# + payload - XML payload
# + return - HTTP Response with XML content
public isolated function createXmlResponse(xml payload) returns http:Response {
    http:Response response = new;
    response.setXmlPayload(payload);
    response.setHeader("Content-Type", "application/xml");
    return response;
}

# Create JSON HTTP response with proper headers.
#
# + payload - JSON payload
# + return - HTTP Response with JSON content
public isolated function createJsonResponse(json payload) returns http:Response {
    http:Response response = new;
    response.setJsonPayload(payload);
    response.setHeader("Content-Type", "application/json");
    return response;
}

# Build XML for authors array.
#
# + authors - Array of author names
# + return - XML representation of authors
public isolated function buildAuthorsXml(string[] authors) returns xml {
    return xml:concat(...authors.map(author => xml `<author>${author}</author>`));
}

# Build XML for keywords array.
#
# + keywords - Array of keywords
# + return - XML representation of keywords
public isolated function buildKeywordsXml(string[] keywords) returns xml {
    return xml:concat(...keywords.map(keyword => xml `<keyword>${keyword}</keyword>`));
}

# Build XML for licenses array.
#
# + licenses - Array of licenses
# + return - XML representation of licenses
public isolated function buildLicensesXml(string[] licenses) returns xml {
    return xml:concat(...licenses.map(license => xml `<license>${license}</license>`));
}
