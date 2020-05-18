#! /usr/bin/env bash

# Exit on error
set -e

KUSTOMIZE_FILE_INPUT=${1}

LOG_LEVEL=${LOG_LEVEL:-INFO}
# hrval uses this variable for Helm charts that has a path via git (eg. cluster-issuer chart)
export GITHUB_TOKEN=${GITHUB_TOKEN:-foo}

echo "LOG_LEVEL: ${LOG_LEVEL}"

function log() {
    LEVEL=$1
    LOG=$2

    if [ "${LEVEL}" == "${LOG_LEVEL}" ]; then
        echo "${LOG}"
    fi

    if [ "${LEVEL}" == "${LOG_LEVEL}" ]; then
        echo "${LOG}"
    fi

}

function traverse() {
    for file in "$1"/*
    do
        if [ ! -d "${file}" ] ; then
            log "DEBUG" "${file} is a file"

            # Doc: https://wiki.bash-hackers.org/syntax/pe
            # "${file##*/}" - Return only the chars after the last / - Only the filename
            # "${file%/*}" - Returns only the directory path prior to the last / - Only the path
            if [ "${file##*/}" == "kustomization.yaml" ]; then
                log "DEBUG" "Directory: ${file%/*}"
                log "DEBUG" "Found a kustomization.yaml file and path: ${file}"
                log "DEBUG" "Running kustomize build: kustomize build ${file%/*} -o ${file%/*}/tmp.out.yaml"

                # Kustomize output of all files in this directory into one file
                kustomize build ${file%/*} -o "${file%/*}/tmp.out.yaml"

                # Add yaml section break to the beginning of the file - Kustomize does not output this for the first item
                sed -i '1s/^/---\n/' "${file%/*}/tmp.out.yaml"

                # Get a count of how many yaml documents are in the Kustomize output file
                yaml_document_counter=0
                IFS=''
                while read data; do
                    if [ "${data}" == "---" ]; then
                        yaml_document_counter=$[yaml_document_counter + 1]
                    fi
                done < "${file%/*}/tmp.out.yaml"

                log "DEBUG" "yaml_document_counter: ${yaml_document_counter}"

                COUNTER=0
                while [  $COUNTER -lt ${yaml_document_counter} ]; do
                    log "DEBUG" "The counter is $COUNTER"

                    yq_document="-d${COUNTER}"

                    kind=$(yq r ${yq_document} ${file%/*}/tmp.out.yaml kind)

                    log "DEBUG" "kind: ${kind}"

                    if [ "${kind}" == "HelmRelease" ]; then
                        log "DEBUG" "Found a HelmRelease"
                        log "DEBUG" "Output this yaml document"

                        # YAML document name
                        yaml_document_name=$(yq r ${yq_document} ${file%/*}/tmp.out.yaml metadata.name)

                        # Output this yaml document to a file
                        yq r ${yq_document} ${file%/*}/tmp.out.yaml > ${file%/*}/tmp.out.${yaml_document_name}.yaml

                        # Run hrval on this yaml document
                        IGNORE_VALUES=false
                        KUBE_VER=master
                        HELM_VER=v3

                        log "INFO" "Processing file: ${file%/*}/tmp.out.${yaml_document_name}.yaml"
                        log "INFO" "HelmRelease name: ${yaml_document_name}"
                        hrval ${file%/*}/tmp.out.${yaml_document_name}.yaml $IGNORE_VALUES $KUBE_VER $HELM_VER

                        # Remove temp HelmRelase file
                        rm ${file%/*}/tmp.out.${yaml_document_name}.yaml
                    fi

                    let COUNTER=COUNTER+1
                done

                # Remove temp kustomize all output file
                rm "${file%/*}/tmp.out.yaml"

            fi

        else
            log "DEBUG" "entering recursion with: ${file}"
            traverse "${file}"
        fi
    done
}

function main() {
    traverse "$1"
}

main "$1"
