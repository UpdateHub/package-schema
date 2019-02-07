# Copyright (C) 2017 O.S. Systems Software LTDA.
# SPDX-License-Identifier: MIT

# Set working dir
cd $(dirname $0)

# Configure bash to be more rigorous:
set -eo pipefail

# Setup virtualenv and install dependencies:
if [ ! -d "venv" ]; then
    echo "Setting up virtualenv..."
    python3 -m venv venv
    . venv/bin/activate
    echo "Installing dependencies..."
    pip install -r requirements.txt
fi

# Activate virtualenv
. venv/bin/activate

SUCCESS=0
FAIL=0

runner() {
    local description=$1
    local schema=$2
    local document=$3
    local expect=$4
    local error=$5

    local python_checker="./checker.py"

    # Python validation
    python=$($python_checker $schema $document $expect "$error")

    if [ "$?" = "0" ]; then
        SUCCESS=$(($SUCCESS + 1))
	echo "PASSED: Python runner: $description"
    else
        FAIL=$(($FAIL + 1))
	echo "FAILED: Python runner: $description"
        echo "Fixture: $document"
        echo "Must be: $expect"
	echo "Error: $python"
        echo
    fi
}


# SCHEMA: copy-object.json
runner "copy-object expected document is valid" \
       copy-object.json \
       copy-object/expected-document.json \
       VALID

## PROPERTY: mode
runner "copy-object mode property is required" \
       copy-object.json \
       copy-object/without-mode-property.json \
       INVALID \
       "required: 'mode' is a required property"

runner "copy-object wrong mode property choice is invalid" \
       copy-object.json \
       copy-object/invalid-mode-property-choice.json \
       INVALID \
       "dependencies/mode/properties/mode/enum: 'tarball' is not one of ['copy']"

## PROPERTY: filename
runner "copy-object expected filename property is valid" \
       copy-object.json \
       copy-object/expected-filename-property.json \
       VALID

runner "copy-object filename property is required" \
       copy-object.json \
       copy-object/without-filename-property.json \
       INVALID \
       "required: 'filename' is a required property"

runner "copy-object filename property type must be an integer" \
       copy-object.json \
       copy-object/invalid-filename-property-type.json \
       INVALID \
       "properties/filename/type: 1 is not of type 'string'"

## PROPERTY: size
runner "copy-object expected size property is valid" \
       copy-object.json \
       copy-object/expected-size-property.json \
       VALID

runner "copy-object size property is required" \
       copy-object.json \
       copy-object/without-size-property.json \
       INVALID \
       "required: 'size' is a required property"

runner "copy-object size property type must be an integer" \
       copy-object.json \
       copy-object/invalid-size-property-type.json \
       INVALID \
       "properties/size/type: '1024' is not of type 'integer'"

## PROPERTY: target-type
runner "copy-object target-type property is required" \
       copy-object.json \
       copy-object/without-target-type-property.json \
       INVALID \
       "required: 'target-type' is a required property"

runner "copy-object invalid target-type property" \
       copy-object.json \
       copy-object/invalid-target-type-property.json \
       INVALID \
       "properties/target-type/enum: 'ubivolume' is not one of ['device']"

## PROPERTY: target
runner "copy-object target property is required" \
       copy-object.json \
       copy-object/without-target-property.json \
       INVALID \
       "required: 'target' is a required property"

## PROPERTY: target-mode
runner "copy-object expected target-mode is valid" \
       copy-object.json \
       copy-object/expected-target-mode-property.json \
       VALID

runner "copy-object invalid target-mode pattern" \
       copy-object.json \
       copy-object/invalid-target-mode-property-pattern.json \
       INVALID \
       "properties/target-mode/pattern: '777' does not match '^[0-9]{4}$'"

runner "copy-object target-mode property is not required" \
       copy-object.json \
       copy-object/without-target-mode-property.json \
       VALID

runner "copy-object target-mode property must be a string" \
       copy-object.json \
       copy-object/invalid-target-mode-property-type.json \
       INVALID \
       "properties/target-mode/type: 777 is not of type 'string'"

## PROPERTY: target-gid
runner "copy-object target-gid as a string is valid" \
       copy-object.json \
       copy-object/expected-string-target-gid-property.json \
       VALID

runner "copy-object target-gid as a number is valid" \
       copy-object.json \
       copy-object/expected-number-target-gid-property.json \
       VALID

runner "copy-object target-gid property must be a string or an integer" \
       copy-object.json \
       copy-object/invalid-target-gid-property-type.json \
       INVALID \
       "properties/target-gid/oneOf: [] is not valid under any of the given schemas"

runner "copy-object target-gid property requires target-uid" \
       copy-object.json \
       copy-object/with-target-gid-and-without-target-uid.json \
       INVALID \
       "dependencies: 'target-uid' is a dependency of 'target-gid'"

## PROPERTY: target-uid
runner "copy-object target-uid as a string is valid" \
       copy-object.json \
       copy-object/expected-string-target-uid-property.json \
       VALID

runner "copy-object target-uid as a number is valid" \
       copy-object.json \
       copy-object/expected-number-target-uid-property.json \
       VALID

runner "copy-object target-uid property must be a string or an integer" \
       copy-object.json \
       copy-object/invalid-target-uid-property-type.json \
       INVALID \
       "properties/target-uid/oneOf: [] is not valid under any of the given schemas"

runner "copy-object target-uid property requires target-uid" \
       copy-object.json \
       copy-object/with-target-uid-and-without-target-gid.json \
       INVALID \
       "dependencies: 'target-gid' is a dependency of 'target-uid'"

## PROPERTY: compressed
runner "copy-object compressed property is not required" \
       copy-object.json \
       copy-object/without-compressed-property.json \
       VALID

runner "copy-object expected compressed property is valid" \
       copy-object.json \
       copy-object/expected-compressed-property.json \
       VALID

runner "copy-object invalid compressed property type" \
       copy-object.json \
       copy-object/invalid-compressed-property-type.json \
       INVALID \
       "properties/compressed/type: '1024' is not of type 'boolean'"

## PROPERTY: required-uncompressed-size
runner "copy-object required-uncompressed-size property is not required" \
       copy-object.json \
       copy-object/expected-required-uncompressed-size-property.json \
       VALID

runner "copy-object expected required-uncompressed-size property is valid" \
       copy-object.json \
       copy-object/expected-required-uncompressed-size-property.json \
       VALID

runner "copy-object invalid required-uncompressed-size property type" \
       copy-object.json \
       copy-object/invalid-required-uncompressed-size-property-type.json \
       INVALID \
       "properties/required-uncompressed-size/type: '1024' is not of type 'integer'"

## PROPERTY: filesystem
runner "copy-object filesystem property is required" \
       copy-object.json \
       copy-object/without-filesystem-property.json \
       INVALID \
       "required: 'filesystem' is a required property"

runner "copy-object expected filesystem property is valid" \
       copy-object.json \
       copy-object/expected-filesystem-property.json \
       VALID

runner "copy-object invalid filesystem property type" \
       copy-object.json \
       copy-object/invalid-filesystem-property-type.json \
       INVALID \
       "properties/filesystem/type: 1 is not of type 'string'"

runner "copy-object invalid filesystem choice" \
       copy-object.json \
       copy-object/invalid-filesystem-choice.json \
       INVALID \
       "properties/filesystem/enum: 'bad-filesystem' is not one of ['btrfs', 'ext2', 'ext3', 'ext4', 'vfat', 'f2fs', 'jffs2', 'ubifs', 'xfs']"


## PROPERTY: target-path
runner "copy-object target-path is required" \
       copy-object.json \
       copy-object/without-target-path-property.json \
       INVALID \
       "required: 'target-path' is a required property"

runner "copy-object expected target-path property is valid" \
       copy-object.json \
       copy-object/expected-target-path-property.json \
       VALID

runner "copy-object invalid target-path property type" \
       copy-object.json \
       copy-object/invalid-target-path-property-type.json \
       INVALID \
       "properties/target-path/type: 1 is not of type 'string'"

## PROPERTY: format?
runner "copy-object format? property is not required" \
       copy-object.json \
       copy-object/without-format-property.json \
       VALID

runner "copy-object expected format? property is valid" \
       copy-object.json \
       copy-object/expected-format-property.json \
       VALID

runner "copy-object invalid format? property type" \
       copy-object.json \
       copy-object/invalid-format-property-type.json \
       INVALID \
       "properties/format?/type: 1 is not of type 'boolean'"

## PROPERTY: format-options
runner "copy-object format-options property is not required" \
       copy-object.json \
       copy-object/without-format-options-property.json \
       VALID

runner "copy-object expected format-options property is valid" \
       copy-object.json \
       copy-object/expected-format-options-property.json \
       VALID

runner "copy-object invalid format-options property type" \
       copy-object.json \
       copy-object/invalid-format-options-property-type.json \
       INVALID \
       "properties/format-options/type: 1 is not of type 'string'"

runner "copy-object format-options requires format? to be true" \
       copy-object.json \
       copy-object/invalid-format-options-property-dependency.json \
       INVALID \
       "dependencies/format-options/properties/format?/enum: False is not one of [True]"

runner "copy-object format-options requires format?" \
       copy-object.json \
       copy-object/format-options-without-format.json \
       INVALID \
       "dependencies/format-options/required: 'format?' is a required property"

## PROPERTY: mount-options
runner "copy-object mount-options property is not required" \
       copy-object.json \
       copy-object/without-mount-options-property.json \
       VALID

runner "copy-object expected mount-options property is valid" \
       copy-object.json \
       copy-object/expected-mount-options-property.json \
       VALID

runner "copy-object invalid mount-options property type" \
       copy-object.json \
       copy-object/invalid-mount-options-property-type.json \
       INVALID \
       "properties/mount-options/type: 1 is not of type 'string'"


# SCHEMA: flash-object.json
runner "flash-object minimal document is valid" \
       flash-object.json \
       flash-object/minimal-document.json \
       VALID

runner "flash-object full document is valid" \
       flash-object.json \
       flash-object/full-document.json \
       VALID

runner "flash-object with extra-properties is invalid" \
       flash-object.json \
       flash-object/with-extra-properties.json \
       INVALID \
       "additionalProperties: Additional properties are not allowed ('extra' was unexpected)"

## PROPERTY: mode
runner "flash-object mode property is required" \
       flash-object.json \
       flash-object/without-mode-property.json \
       INVALID \
       "required: 'mode' is a required property"

## PROPERTY: filename
runner "flash-object filename property is required" \
       flash-object.json \
       flash-object/without-filename-property.json \
       INVALID \
       "required: 'filename' is a required property"

## PROPERTY: size
runner "flash-object size property is required" \
       flash-object.json \
       flash-object/without-size-property.json \
       INVALID \
       "required: 'size' is a required property"

## PROPERTY: sha256sum
runner "flash-object sha256sum property is required" \
       flash-object.json \
       flash-object/without-sha256sum-property.json \
       INVALID \
       "required: 'sha256sum' is a required property"

## PROPERTY: target-type
runner "flash-object target-type property is required" \
       flash-object.json \
       flash-object/without-target-type-property.json \
       INVALID \
       "required: 'target-type' is a required property"

runner "flash-object target-type property must be mtdname or device" \
       flash-object.json \
       flash-object/invalid-target-type.json \
       INVALID  \
       "properties/target-type/enum: 'invalid' is not one of ['device', 'mtdname']"

## PROPERTY: target
runner "flash-object target property is required" \
       flash-object.json \
       flash-object/without-target-property.json \
       INVALID \
       "required: 'target' is a required property"


# SCHEMA: imxkobs-object.json
runner "imxkobs-object minimal document is valid" \
       imxkobs-object.json \
       imxkobs-object/minimal-document.json \
       VALID

runner "imxkobs-object full document is valid" \
       imxkobs-object.json \
       imxkobs-object/full-document.json \
       VALID

runner "imxkobs-object with extra-properties is invalid" \
       imxkobs-object.json \
       imxkobs-object/with-extra-properties.json \
       INVALID \
       "additionalProperties: Additional properties are not allowed ('extra' was unexpected)"

## PROPERTY: mode
runner "imxkobs-object mode property is required" \
       imxkobs-object.json \
       imxkobs-object/without-mode-property.json \
       INVALID \
       "required: 'mode' is a required property"

## PROPERTY: filename
runner "imxkobs-object filename property is required" \
       imxkobs-object.json \
       imxkobs-object/without-filename-property.json \
       INVALID \
       "required: 'filename' is a required property"

## PROPERTY: size
runner "imxkobs-object size property is required" \
       imxkobs-object.json \
       imxkobs-object/without-size-property.json \
       INVALID \
       "required: 'size' is a required property"

## PROPERTY: sha256sum
runner "imxkobs-object sha256sum property is required" \
       imxkobs-object.json \
       imxkobs-object/without-sha256sum-property.json \
       INVALID \
       "required: 'sha256sum' is a required property"


# SCHEMA: raw-object.json
runner "raw-object expected document is valid" \
       raw-object.json \
       raw-object/expected-document.json \
       VALID

## PROPERTY: filename
runner "raw-object expected filename property is valid" \
       raw-object.json \
       raw-object/expected-filename-property.json \
       VALID

runner "raw-object filename property is required" \
       raw-object.json \
       raw-object/without-filename-property.json \
       INVALID \
       "required: 'filename' is a required property"

runner "raw-object filename property type must be an integer" \
       raw-object.json \
       raw-object/invalid-filename-property-type.json \
       INVALID \
       "properties/filename/type: 1 is not of type 'string'"

## PROPERTY: size
runner "raw-object expected size property is valid" \
       raw-object.json \
       raw-object/expected-size-property.json \
       VALID

runner "raw-object size property is required" \
       raw-object.json \
       raw-object/without-size-property.json \
       INVALID \
       "required: 'size' is a required property"

runner "raw-object size property type must be an integer" \
       raw-object.json \
       raw-object/invalid-size-property-type.json \
       INVALID \
       "properties/size/type: '1024' is not of type 'integer'"

## PROPERTY: mode
runner "raw-object mode is required" \
       raw-object.json \
       raw-object/without-mode-property.json \
       INVALID \
       "required: 'mode' is a required property"

runner "raw-object wrong mode choice is invalid" \
       raw-object.json \
       raw-object/invalid-mode-property-choice.json \
       INVALID \
       "dependencies/mode/properties/mode/enum: 'tarball' is not one of ['raw']"

## PROPERTY: target-type
runner "raw-object target-type property is required" \
       raw-object.json \
       raw-object/without-target-type-property.json \
       INVALID \
       "required: 'target-type' is a required property"

runner "raw-object target-type property must be mtdname or device" \
       raw-object.json \
       raw-object/invalid-target-type.json \
       INVALID  \
       "properties/target-type/enum: 'ubivolume' is not one of ['device']"

## PROPERTY: target
runner "raw-object target is required" \
       raw-object.json \
       raw-object/without-target-property.json \
       INVALID \
       "required: 'target' is a required property"

## PROPERTY: compressed
runner "raw-object compressed property is not required" \
       raw-object.json \
       raw-object/without-compressed-property.json \
       VALID

runner "raw-object expected compressed property is valid" \
       raw-object.json \
       raw-object/expected-compressed-property.json \
       VALID

runner "raw-object invalid compressed property type" \
       raw-object.json \
       raw-object/invalid-compressed-property-type.json \
       INVALID \
       "properties/compressed/type: '1024' is not of type 'boolean'"

## PROPERTY: required-uncompressed-size
runner "raw-object required-uncompressed-size property is not required" \
       raw-object.json \
       raw-object/expected-required-uncompressed-size-property.json \
       VALID

runner "raw-object expected required-uncompressed-size property is valid" \
       raw-object.json \
       raw-object/expected-required-uncompressed-size-property.json \
       VALID

runner "raw-object invalid required-uncompressed-size property type" \
       raw-object.json \
       raw-object/invalid-required-uncompressed-size-property-type.json \
       INVALID \
       "properties/required-uncompressed-size/type: '1024' is not of type 'integer'"

## PROPERTY: chunk-size
runner "raw-object expected chunk-size property is valid" \
       raw-object.json \
       raw-object/expected-chunk-size-property.json \
       VALID

runner "raw-object chunk-size property is not required" \
       raw-object.json \
       raw-object/without-chunk-size-property.json \
       VALID

runner "raw-object chunk-size property type must be an integer" \
       raw-object.json \
       raw-object/invalid-chunk-size-property-type.json \
       INVALID \
       "properties/chunk-size/type: '1024' is not of type 'integer'"

## PROPERTY: skip
runner "raw-object expected skip property is valid" \
       raw-object.json \
       raw-object/expected-skip-property.json \
       VALID

runner "raw-object skip property is not required" \
       raw-object.json \
       raw-object/without-skip-property.json \
       VALID

runner "raw-object skip property type must be an integer" \
       raw-object.json \
       raw-object/invalid-skip-property-type.json \
       INVALID \
       "properties/skip/type: '1024' is not of type 'integer'"

## PROPERTY: seek
runner "raw-object expected seek property is valid" \
       raw-object.json \
       raw-object/expected-seek-property.json \
       VALID

runner "raw-object seek property is not required" \
       raw-object.json \
       raw-object/without-seek-property.json \
       VALID

runner "raw-object seek property type must be an object" \
       raw-object.json \
       raw-object/invalid-seek-property-type.json \
       INVALID \
       "properties/seek/type: '1024' is not of type 'integer'"

## PROPERTY: count
runner "raw-object expected count property is valid" \
       raw-object.json \
       raw-object/expected-count-property.json \
       VALID

runner "raw-object count property is not required" \
       raw-object.json \
       raw-object/without-count-property.json \
       VALID

runner "raw-object count property type must be an integer" \
       raw-object.json \
       raw-object/invalid-count-property-type.json \
       INVALID \
       "properties/count/type: '1024' is not of type 'integer'"

## PROPERTY: truncate
runner "raw-object expected truncate property is valid" \
       raw-object.json \
       raw-object/expected-truncate-property.json \
       VALID

runner "raw-object truncate property is not required" \
       raw-object.json \
       raw-object/without-truncate-property.json \
       VALID

runner "raw-object truncate property type must be a boolean" \
       raw-object.json \
       raw-object/invalid-truncate-property-type.json \
       INVALID \
       "properties/truncate/type: 1 is not of type 'boolean'"


# SCHEMA: tarball-object.json
runner "tarball-object expected document is valid" \
       tarball-object.json \
       tarball-object/expected-document.json \
       VALID

## PROPERTY: mode
runner "tarball-object mode property is required" \
       tarball-object.json \
       tarball-object/without-mode-property.json \
       INVALID \
       "required: 'mode' is a required property"

runner "tarball-object wrong mode property choice is invalid" \
       tarball-object.json \
       tarball-object/invalid-mode-property-choice.json \
       INVALID \
       "dependencies/mode/properties/mode/enum: 'copy' is not one of ['tarball']"

## PROPERTY: filename
runner "tarball-object expected filename property is valid" \
       tarball-object.json \
       tarball-object/expected-filename-property.json \
       VALID

runner "tarball-object filename property is required" \
       tarball-object.json \
       tarball-object/without-filename-property.json \
       INVALID \
       "required: 'filename' is a required property"

runner "tarball-object filename property type must be an integer" \
       tarball-object.json \
       tarball-object/invalid-filename-property-type.json \
       INVALID \
       "properties/filename/type: 1 is not of type 'string'"

## PROPERTY: size
runner "tarball-object expected size property is valid" \
       tarball-object.json \
       tarball-object/expected-size-property.json \
       VALID

runner "tarball-object size property is required" \
       tarball-object.json \
       tarball-object/without-size-property.json \
       INVALID \
       "required: 'size' is a required property"

runner "tarball-object size property type must be an integer" \
       tarball-object.json \
       tarball-object/invalid-size-property-type.json \
       INVALID \
       "properties/size/type: '1024' is not of type 'integer'"

## PROPERTY: target-type
runner "tarball-object target-type property is required" \
       tarball-object.json \
       tarball-object/without-target-type-property.json \
       INVALID \
       "required: 'target-type' is a required property"

runner "tarball-object target-type property must be mtdname, device or ubivolume" \
       tarball-object.json \
       tarball-object/invalid-target-type-property.json \
       INVALID \
       "properties/target-type/enum: 'invalid' is not one of ['device', 'mtdname', 'ubivolume']"

## PROPERTY: target
runner "tarball-object target property is required" \
       tarball-object.json \
       tarball-object/without-target-property.json \
       INVALID \
       "required: 'target' is a required property"

## PROPERTY: compressed
runner "tarball-object compressed property is not required" \
       tarball-object.json \
       tarball-object/without-compressed-property.json \
       VALID

runner "tarball-object expected compressed property is valid" \
       tarball-object.json \
       tarball-object/expected-compressed-property.json \
       VALID

runner "tarball-object invalid compressed property type" \
       tarball-object.json \
       tarball-object/invalid-compressed-property-type.json \
       INVALID \
       "properties/compressed/type: '1024' is not of type 'boolean'"

## PROPERTY: required-uncompressed-size
runner "tarball-object required-uncompressed-size property is not required" \
       tarball-object.json \
       tarball-object/expected-required-uncompressed-size-property.json \
       VALID

runner "tarball-object expected required-uncompressed-size property is valid" \
       tarball-object.json \
       tarball-object/expected-required-uncompressed-size-property.json \
       VALID

runner "tarball-object invalid required-uncompressed-size property type" \
       tarball-object.json \
       tarball-object/invalid-required-uncompressed-size-property-type.json \
       INVALID \
       "properties/required-uncompressed-size/type: '1024' is not of type 'integer'"

## PROPERTY: filesystem
runner "tarball-object filesystem property is required" \
       tarball-object.json \
       tarball-object/without-filesystem-property.json \
       INVALID \
       "required: 'filesystem' is a required property"

runner "tarball-object expected filesystem property is valid" \
       tarball-object.json \
       tarball-object/expected-filesystem-property.json \
       VALID

runner "tarball-object invalid filesystem property type" \
       tarball-object.json \
       tarball-object/invalid-filesystem-property-type.json \
       INVALID \
       "properties/filesystem/type: 1 is not of type 'string'"

runner "tarball-object invalid filesystem choice" \
       tarball-object.json \
       tarball-object/invalid-filesystem-choice.json \
       INVALID \
       "properties/filesystem/enum: 'bad-filesystem' is not one of ['btrfs', 'ext2', 'ext3', 'ext4', 'vfat', 'f2fs', 'jffs2', 'ubifs', 'xfs']"

## PROPERTY: target-path
runner "tarball-object target-path is required" \
       tarball-object.json \
       tarball-object/without-target-path-property.json \
       INVALID \
       "required: 'target-path' is a required property"

runner "tarball-object expected target-path property is valid" \
       tarball-object.json \
       tarball-object/expected-target-path-property.json \
       VALID

runner "tarball-object invalid target-path property type" \
       tarball-object.json \
       tarball-object/invalid-target-path-property-type.json \
       INVALID \
       "properties/target-path/type: 1 is not of type 'string'"

## PROPERTY: format?
runner "tarball-object format? property is not required" \
       tarball-object.json \
       tarball-object/without-format-property.json \
       VALID

runner "tarball-object expected format? property is valid" \
       tarball-object.json \
       tarball-object/expected-format-property.json \
       VALID

runner "tarball-object invalid format? property type" \
       tarball-object.json \
       tarball-object/invalid-format-property-type.json \
       INVALID \
       "properties/format?/type: 1 is not of type 'boolean'"

## PROPERTY: format-options
runner "tarball-object format-options property is not required" \
       tarball-object.json \
       tarball-object/without-format-options-property.json \
       VALID

runner "tarball-object expected format-options property is valid" \
       tarball-object.json \
       tarball-object/expected-format-options-property.json \
       VALID

runner "tarball-object invalid format-options property type" \
       tarball-object.json \
       tarball-object/invalid-format-options-property-type.json \
       INVALID \
       "properties/format-options/type: 1 is not of type 'string'"

runner "tarball-object format-options requires format? to be true" \
       tarball-object.json \
       tarball-object/invalid-format-options-property-dependency.json \
       INVALID \
       "dependencies/format-options/properties/format?/enum: False is not one of [True]"

runner "tarball-object format-options requires format?" \
       tarball-object.json \
       tarball-object/format-options-without-format.json \
       INVALID \
       "dependencies/format-options/required: 'format?' is a required property"

## PROPERTY: mount-options
runner "tarball-object mount-options property is not required" \
       tarball-object.json \
       tarball-object/without-mount-options-property.json \
       VALID

runner "tarball-object expected mount-options property is valid" \
       tarball-object.json \
       tarball-object/expected-mount-options-property.json \
       VALID

runner "tarball-object invalid mount-options property type" \
       tarball-object.json \
       tarball-object/invalid-mount-options-property-type.json \
       INVALID \
       "properties/mount-options/type: 1 is not of type 'string'"


# SCHEMA: ubifs-object.json
runner "ubifs-object minimal document is valid" \
       ubifs-object.json \
       ubifs-object/minimal-document.json \
       VALID

runner "ubifs-object full document is valid" \
       ubifs-object.json \
       ubifs-object/full-document.json \
       VALID

runner "ubifs-object with extra-properties is invalid" \
       ubifs-object.json \
       ubifs-object/with-extra-properties.json \
       INVALID \
       "additionalProperties: Additional properties are not allowed ('extra' was unexpected)"

## PROPERTY: mode
runner "ubifs-object mode property is required" \
       ubifs-object.json \
       ubifs-object/without-mode-property.json \
       INVALID \
       "required: 'mode' is a required property"

## PROPERTY: filename
runner "ubifs-object filename property is required" \
       ubifs-object.json \
       ubifs-object/without-filename-property.json \
       INVALID \
       "required: 'filename' is a required property"

## PROPERTY: size
runner "ubifs-object size property is required" \
       ubifs-object.json \
       ubifs-object/without-size-property.json \
       INVALID \
       "required: 'size' is a required property"

## PROPERTY: sha256sum
runner "ubifs-object sha256sum property is required" \
       ubifs-object.json \
       ubifs-object/without-sha256sum-property.json \
       INVALID \
       "required: 'sha256sum' is a required property"

## PROPERTY: compressed
runner "ubifs-object with compressed false and without required-uncompressed-size is valid" \
       ubifs-object.json \
       ubifs-object/with-compressed-false.json \
       VALID

runner "ubifs-object required-uncompressed-size requires compressed to be true" \
       ubifs-object.json \
       ubifs-object/invalid-required-uncompressed-size.json \
       INVALID \
       "dependencies/required-uncompressed-size/properties/compressed/enum: False is not one of [True]"

## PROPERTY: target-type
runner "ubifs-object target-type property is required" \
       ubifs-object.json \
       ubifs-object/without-target-type-property.json \
       INVALID \
       "required: 'target-type' is a required property"

runner "ubifs-object target property must be ubivolume" \
       ubifs-object.json \
       ubifs-object/invalid-target-type-property.json \
       INVALID \
       "properties/target-type/enum: 'invalid' is not one of ['ubivolume']"

## PROPERTY: target
runner "ubifs-object target property is required" \
       ubifs-object.json \
       ubifs-object/without-target-property.json \
       INVALID \
       "required: 'target' is a required property"


# SCHEMA: mender-object.json
runner "mender-object expected document is valid" \
       mender-object.json \
       mender-object/expected-document.json \
       VALID

## PROPERTY: mode
runner "mender-object mode property is required" \
       mender-object.json \
       mender-object/without-mode-property.json \
       INVALID \
       "required: 'mode' is a required property"

runner "mender-object wrong mode property choice is invalid" \
       mender-object.json \
       mender-object/invalid-mode-property-choice.json \
       INVALID \
       "dependencies/mode/properties/mode/enum: 'tarball' is not one of ['mender']"

## PROPERTY: filename
runner "mender-object expected filename property is valid" \
       mender-object.json \
       mender-object/expected-filename-property.json \
       VALID

runner "mender-object filename property is required" \
       mender-object.json \
       mender-object/without-filename-property.json \
       INVALID \
       "required: 'filename' is a required property"

runner "mender-object filename property type must be an integer" \
       mender-object.json \
       mender-object/invalid-filename-property-type.json \
       INVALID \
       "properties/filename/type: 1 is not of type 'string'"

## PROPERTY: size
runner "mender-object size property is required" \
       mender-object.json \
       mender-object/without-size-property.json \
       INVALID \
       "required: 'size' is a required property"

runner "mender-object size property type must be an integer" \
       mender-object.json \
       mender-object/invalid-size-property-type.json \
       INVALID \
       "properties/size/type: '1024' is not of type 'integer'"


# SCHEMA: zephyr-object.json
runner "zephyr-object expected document is valid" \
       zephyr-object.json \
       zephyr-object/expected-document.json \
       VALID

## PROPERTY: mode
runner "zephyr-object mode property is required" \
       zephyr-object.json \
       zephyr-object/without-mode-property.json \
       INVALID \
       "required: 'mode' is a required property"

runner "zephyr-object wrong mode property choice is invalid" \
       zephyr-object.json \
       zephyr-object/invalid-mode-property-choice.json \
       INVALID \
       "dependencies/mode/properties/mode/enum: 'tarball' is not one of ['zephyr']"

## PROPERTY: filename
runner "zephyr-object expected filename property is valid" \
       zephyr-object.json \
       zephyr-object/expected-filename-property.json \
       VALID

runner "zephyr-object filename property is required" \
       zephyr-object.json \
       zephyr-object/without-filename-property.json \
       INVALID \
       "required: 'filename' is a required property"

runner "zephyr-object filename property type must be an integer" \
       zephyr-object.json \
       zephyr-object/invalid-filename-property-type.json \
       INVALID \
       "properties/filename/type: 1 is not of type 'string'"

## PROPERTY: size
runner "zephyr-object size property is required" \
       zephyr-object.json \
       zephyr-object/without-size-property.json \
       INVALID \
       "required: 'size' is a required property"

runner "zephyr-object size property type must be an integer" \
       zephyr-object.json \
       zephyr-object/invalid-size-property-type.json \
       INVALID \
       "properties/size/type: '1024' is not of type 'integer'"


# SCHEMA: install-if-different.json

## sha256sum
runner "install-if-different expected document sha256sum is valid" \
       install-if-different.json \
       install-if-different/expected-document-sha256sum.json \
       VALID

runner "install-if-different invalid sha256sum type" \
       install-if-different.json \
       install-if-different/invalid-sha256sum-type.json \
       INVALID \
       "oneOf: 'md5' is not valid under any of the given schemas"

## known pattern
runner "install-if-different expected document known-pattern is valid" \
       install-if-different.json \
       install-if-different/expected-document-known-pattern.json \
       VALID

runner "install-if-different know-pattern with additional properties is invalid" \
       install-if-different.json \
       install-if-different/known-pattern-with-additional-properties.json \
       INVALID \
       "oneOf: OrderedDict([('version', '2.0'), ('pattern', 'u-boot'), ('extra', 'property')]) is not valid under any of the given schemas"

runner "install-if-different know-pattern with invalid pattern is invalid" \
       install-if-different.json \
       install-if-different/known-pattern-with-invalid-pattern.json \
       INVALID \
       "oneOf: OrderedDict([('version', '2.0'), ('pattern', 'invalid-pattern')]) is not valid under any of the given schemas"

runner "install-if-different know-pattern without version is invalid" \
       install-if-different.json \
       install-if-different/known-pattern-without-version.json \
       INVALID \
       "oneOf: OrderedDict([('pattern', 'u-boot')]) is not valid under any of the given schemas"

runner "install-if-different know-pattern without pattern is invalid" \
       install-if-different.json \
       install-if-different/known-pattern-without-pattern.json \
       INVALID \
       "oneOf: OrderedDict([('version', '2.0')]) is not valid under any of the given schemas"

## custom pattern
runner "install-if-different expected document custom-pattern is valid" \
       install-if-different.json \
       install-if-different/expected-document-custom-pattern.json \
       VALID

runner "install-if-different custom-pattern with additional properties is invalid" \
       install-if-different.json \
       install-if-different/custom-pattern-with-additional-properties.json \
       INVALID \
       "oneOf: OrderedDict([('version', '2.0'), ('pattern', OrderedDict([('regexp', '.+'), ('seek', 1024), ('buffer-size', 2024)])), ('extra', 'property')]) is not valid under any of the given schemas"

runner "install-if-different custom-pattern pattern with additional properties is invalid" \
       install-if-different.json \
       install-if-different/custom-pattern-pattern-with-additional-properties.json \
       INVALID \
       "oneOf: OrderedDict([('version', '2.0'), ('pattern', OrderedDict([('regexp', '.+'), ('seek', 1024), ('buffer-size', 2024), ('extra', 'property')]))]) is not valid under any of the given schemas"

runner "install-if-different custom-pattern pattern without version is invalid" \
       install-if-different.json \
       install-if-different/custom-pattern-without-version.json \
       INVALID \
       "oneOf: OrderedDict([('pattern', OrderedDict([('regexp', '.+'), ('seek', 1024), ('buffer-size', 2024)]))]) is not valid under any of the given schemas"

runner "install-if-different custom-pattern pattern without pattern is invalid" \
       install-if-different.json \
       install-if-different/custom-pattern-without-pattern.json \
       INVALID \
       "oneOf: OrderedDict([('version', '2.0')]) is not valid under any of the given schemas"

runner "install-if-different custom-pattern pattern without regexp is invalid" \
       install-if-different.json \
       install-if-different/custom-pattern-without-regexp.json \
       INVALID \
       "oneOf: OrderedDict([('version', '2.0'), ('pattern', OrderedDict([('seek', 1024), ('buffer-size', 2024)]))]) is not valid under any of the given schemas"

runner "install-if-different custom-pattern with only required values is valid" \
       install-if-different.json \
       install-if-different/custom-pattern-without-seek-and-buffer-size.json \
       VALID


# SCHEMA: metadata.json
runner "metadata expected document is valid" \
       metadata.json \
       metadata/expected-document.json \
       VALID

runner "metadata active-inactive expected document is valid" \
       metadata.json \
       metadata/expected-active-inactive-document.json \
       VALID

runner "metadata with additional properties is invalid" \
       metadata.json \
       metadata/with-additional-properties.json \
       INVALID \
       "additionalProperties: Additional properties are not allowed ('extra-property' was unexpected)"

## PROPERTY: product
runner "metadata expected product property is valid" \
       metadata.json \
       metadata/expected-product-property.json \
       VALID

runner "metadata product property is required" \
       metadata.json \
       metadata/without-product-property.json \
       INVALID \
       "required: 'product' is a required property"

runner "metadata product property must be a 64 digits hexadecimal number" \
       metadata.json \
       metadata/invalid-product-property-format.json \
       INVALID \
       "properties/product/pattern: 'z3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b85z' does not match '^[a-f0-9]{64}$'"

## PROPERTY: version
runner "metadata expected version property is valid" \
       metadata.json \
       metadata/expected-version-property.json \
       VALID

runner "metadata version property is required" \
       metadata.json \
       metadata/without-version-property.json \
       INVALID \
       "required: 'version' is a required property"

runner "metadata empty version is invalid" \
       metadata.json \
       metadata/empty-version-property.json \
       INVALID \
       "properties/version/minLength: '' is too short"

## PROPERTY: supported-hardware
runner "metadata supported-hardware property is required" \
       metadata.json \
       metadata/without-supported-hardware-property.json \
       INVALID \
       "required: 'supported-hardware' is a required property"

runner "metadata supported-hardware as an array of identifiers is valid" \
       metadata.json \
       metadata/valid-supported-hardware-propert-with-array.json \
       VALID

runner "metadata supported-hardware as 'any' string is valid" \
       metadata.json \
       metadata/valid-supported-hardware-property-with-any.json \
       VALID

runner "metadata supported-hardware as array must not be empty" \
       metadata.json \
       metadata/empty-supported-hardware-property.json \
       INVALID \
       "properties/supported-hardware/oneOf: [] is not valid under any of the given schemas"

runner "metadata supported-hardware array items type must be a string" \
       metadata.json \
       metadata/invalid-supported-hardware-item-type.json \
       INVALID \
       "properties/supported-hardware/oneOf: [1] is not valid under any of the given schemas"

runner "metadata supported-hardware array items must be unique" \
       metadata.json \
       metadata/repeated-supported-hardware-items.json \
       INVALID \
       "properties/supported-hardware/oneOf: ['Super Board', 'Super Board'] is not valid under any of the given schemas"

runner "metadata supported-hardware accepts onle 'any' as string" \
       metadata.json \
       metadata/invalid-supported-hardware-string.json \
       INVALID \
       "properties/supported-hardware/oneOf: '' is not valid under any of the given schemas"

## PROPERTY: objects
runner "metadata objects property is required" \
       metadata.json \
       metadata/without-objects-property.json \
       INVALID \
       "required: 'objects' is a required property"

runner "metadata empty objects property is invalid" \
       metadata.json \
       metadata/empty-objects-property.json \
       INVALID \
       "properties/objects/minItems: [] is too short"

runner "metadata empty objects array item is invalid" \
       metadata.json \
       metadata/empty-objects-array-item.json \
       INVALID \
       "properties/objects/items/minItems: [] is too short"


# Results
echo "TOTAL TESTS: $(($SUCCESS + $FAIL))"
echo "SUCCESS: $SUCCESS"
echo "FAIL: $FAIL"

[ "$FAIL" = "0" ] && exit 0 || exit 1
