// Copyright (c) 2022, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/jballerina.java;

public isolated function newFile(handle path) returns handle = @java:Constructor {
    'class: "java.io.File",
    paramTypes: ["java.lang.String"]
} external;

public isolated function newZipFile(handle path) returns handle = @java:Constructor {
    'class: "net.lingala.zip4j.ZipFile",
    paramTypes: ["java.lang.String"]
} external;

public isolated function newZipFile_(handle receiver) returns handle|error = @java:Constructor {
    'class: "java.util.zip.ZipFile",
    paramTypes: ["java.io.File"]
} external;

public isolated function addZip(handle receiver) returns handle = @java:Method {
    name: "entries",
    'class: "java.util.zip.ZipFile"

} external;

public isolated function hasMoreElements(handle receiver) returns boolean = @java:Method {
    name: "hasMoreElements",
    'class: "java.util.Enumeration"

} external;

public isolated function nextElement(handle receiver) returns handle = @java:Method {
    name: "nextElement",
    'class: "java.util.Enumeration"

} external;

public isolated function isDirectory(handle receiver) returns boolean = @java:Method {
    name: "isDirectory",
    'class: "java.util.zip.ZipEntry"

} external;

public isolated function getCompressedSize(handle receiver) returns int = @java:Method {
    name: "getCompressedSize",
    'class: "java.util.zip.ZipEntry"

} external;

public isolated function getUncompressedSize(handle receiver) returns int = @java:Method {
    name: "getSize",
    'class: "java.util.zip.ZipEntry"

} external;

public isolated function addFileToZip(handle receiver, handle filePath) returns error? = @java:Method {
    name: "addFile",
    'class: "net.lingala.zip4j.ZipFile",
    paramTypes: ["java.lang.String"]
} external;

public isolated function addFolderToZip(handle receiver, handle folderPath) returns error? = @java:Method {
    name: "addFolder",
    'class: "net.lingala.zip4j.ZipFile",
    paramTypes: ["java.io.File"]
} external;

public isolated function extractZip(handle receiver, handle outputPath) returns error? = @java:Method {
    name: "extractAll",
    'class: "net.lingala.zip4j.ZipFile",
    paramTypes: ["java.lang.String"]
} external;
