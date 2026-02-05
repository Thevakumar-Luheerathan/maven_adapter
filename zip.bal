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

import ballerina/file;
import ballerina/jballerina.java;


configurable int ZIP_FILE_SIZE_MAX_LIMIT = 0x3B9ACA00; //1GB
configurable float COMPRESSION_RATIO = 0.001;

# Extract a zip file to a specific location.
#
# + zipPath - Path of the zip file.
# + outputPath - Output directory.
# + return - Error if occurred.
public isolated function extract(string zipPath, string outputPath) returns error? {
    boolean fileExists = check file:test(zipPath, file:EXISTS);
    if !fileExists {
        check file:createDir(zipPath);
    }
    handle zipfile = newZipFile(java:fromString(zipPath));

    //Before Extracting thr zip file - do a zip Bomb test

    check detectZipBomb(zipPath);

    check extractZip(zipfile, java:fromString(outputPath));
}

# Detect a zip bomb.
#
# + filePath - Path of the zip file.
# + return - Error if zip bomb detected otherwise return null.
isolated function detectZipBomb(string filePath) returns error? {

    handle file = newFile(java:fromString(filePath));
    handle|error zip = newZipFile_(file);
    handle entries = addZip(check zip);

    int compressedSize = 0;
    int uncompressedSize = 0;

    while (hasMoreElements(entries)) {

        handle zipEntry = nextElement(entries);
        if (isDirectory(zipEntry)) {
            continue;
        }
        else {
            do {
                compressedSize += getCompressedSize(zipEntry);
                uncompressedSize += getUncompressedSize(zipEntry);
            }
            on fail {
                return error("Process Failed");
            }

        }

    }

    //check the file size first, in case we are working on uncompressed streams
    //Default Max limit is set to 500MB = 0x1DCD6500

    if (compressedSize > ZIP_FILE_SIZE_MAX_LIMIT) {
        return error("File size limit exceeded!!!");

    }

    float ratio = <float>compressedSize / <float>uncompressedSize;
    //Compression Ratio - 1GB --> 1MB = 0.001
    if (ratio >= COMPRESSION_RATIO) {
        return;
    }
    // one of the limits was reached, report it
    return error("Zip Bomb Detected!!!");

}

# Create a zip file with files.
#
# + outputPath - The location of the zip file.
# + files - The list of files/directories.
# + return - Error if occurred.
public isolated function create(string outputPath, file:MetaData|string... files) returns error? {
    boolean fileExists = check file:test(check file:parentPath(outputPath), file:EXISTS);
    if !fileExists {
        check file:createDir(check file:parentPath(outputPath));
    }

    handle zipfile = newZipFile(java:fromString(outputPath));
    foreach file:MetaData|string filepath in files {
        if (filepath is string) {
            file:MetaData fileInfo = check file:getMetaData(filepath);
            if fileInfo.dir {
                handle file = newFile(java:fromString(filepath));
                check addFolderToZip(zipfile, file);
            } else {
                check addFileToZip(zipfile, java:fromString(filepath));
            }
        } else {
            if filepath.dir {
                handle file = newFile(java:fromString(check file:basename(filepath.absPath)));
                check addFolderToZip(zipfile, file);
            } else {
                check addFileToZip(zipfile, java:fromString(check file:basename(filepath.absPath)));
            }
        }
    }
}
