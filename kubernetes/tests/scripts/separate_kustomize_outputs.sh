#! /usr/bin/env bash

KUSTOMIZE_FILE_INPUT=${1}

# IFS=''
# while read data; do
#     echo "$data" >> /tmp/out2.txt
# done < ${KUSTOMIZE_FILE_INPUT}

LOG_LEVEL=${LOG_LEVEL:-INFO}

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
            echo "${file} is a file"

            # Doc: https://wiki.bash-hackers.org/syntax/pe
            # "${file##*/}" - Return only the chars after the last / - Only the filename
            # "${file%/*}" - Returns only the directory path prior to the last / - Only the path
            if [ "${file##*/}" == "kustomization.yaml" ]; then
                echo "Directory: ${file%/*}"
                echo "Found a kustomization.yaml file and path: ${file}"
                echo "Running kustomize build: /opt/bin/kustomize build ${file%/*} -o ${file%/*}/tmp.out.yaml"

                # Kustomize output of all files in this directory into one file
                /opt/bin/kustomize build ${file%/*} -o "${file%/*}/tmp.out.yaml"

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

                echo "yaml_document_counter: ${yaml_document_counter}"

                COUNTER=0
                while [  $COUNTER -lt ${yaml_document_counter} ]; do
                    log "DEBUG" "The counter is $COUNTER"

                    yq_document="-d${COUNTER}"

                    kind=$(yq r ${yq_document} ${file%/*}/tmp.out.yaml kind)

                    log "DEBUG" "kind: ${kind}"

                    if [ "${kind}" == "HelmRelease" ]; then
                        echo "Found a HelmRelease"
                        echo "Output this yaml document"

                        # YAML document name
                        yaml_document_name=$(yq r ${yq_document} ${file%/*}/tmp.out.yaml metadata.name)

                        # Output this yaml document to a file
                        yq r ${yq_document} ${file%/*}/tmp.out.yaml > ${file%/*}/tmp.out.${yaml_document_name}.yaml

                        # Run hrval on this yaml document
                        IGNORE_VALUES=false
                        KUBE_VER=master
                        HELM_VER=v3

                        hrval ${file%/*}/tmp.out.${yaml_document_name}.yaml $IGNORE_VALUES $KUBE_VER $HELM_VER


                    fi

                    let COUNTER=COUNTER+1
                done


                
#                 ## Loop through the tmp.out.yaml file and find the HelmReleases
#                 ##
#                 ## boolean to keep track of when a beginning of a yaml section if ound
#                 is_start_of_yaml_section=true
#                 ## boolean to keep track of when another yaml section if found
#                 found_beginning_of_another_yaml_section=false
#                 ## A var to hold the content of a yaml section
#                 yaml_section=""
#                 ## boolean to denote if this yaml section is a HelmRelease or not
#                 is_helmrelease=false
#                 IFS=''
#                 while read data; do
#                     # echo "$data"

#                     # Check for starting and ending of each yaml section
#                     if [ "${data}" == "---" ]; then

#                         if ${is_start_of_yaml_section}; then
#                             echo "Beginning of a yaml section"
#                             # Set to false since we have found the start of a yaml section
#                             is_start_of_yaml_section=false
#                             # Reset the yaml_section to an empty string to start capturing this section
#                             # yaml_section=""
#                         else
#                             echo "Beginning of a another yaml section"
#                             found_beginning_of_another_yaml_section=true
#                         fi
#                     fi

#                     if [ "${data}" == "kind: HelmRelease" ]; then
#                         echo "Found a HelmRelease"
#                         is_helmrelease=true
#                     fi

#                     # Found another yaml section, handle the previous one and reset the variables for the next yaml section iteration
#                     if ${found_beginning_of_another_yaml_section}; then
#                         if ${is_helmrelease}; then
#                             echo "The previous section is a HelmRelease, run hrval on this section"

#                             echo "${yaml_section}"
#                             echo "exiting"
#                             exit 1;

#                             # Reset variables
#                             # is_start_of_yaml_section=true
#                             # is_helmrelease=false
#                             # yaml_section=""
#                         fi

#                         # Reset variables
#                         echo "Resetting variables"
#                         found_beginning_of_another_yaml_section=false
#                         is_start_of_yaml_section=true
#                         is_helmrelease=false
#                         yaml_section=""
#                     fi

#                     # Append data
#                     yaml_section="${yaml_section}
# ${data}"

        

                    

#                 done < "${file%/*}/tmp.out.yaml"

            fi

        else
            echo "entering recursion with: ${file}"
            traverse "${file}"
        fi
    done
}

function main() {
    traverse "$1"
}

main "$1"
