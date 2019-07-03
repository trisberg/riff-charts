#!/bin/bash

chart=$1
version=$2
destination=$3

# download config and apply overlays

mkdir -p charts/${chart}/templates

while IFS= read -r line
do
  arr=($line)
  name=${arr[0]%?}
  url=${arr[1]}
  args=$(echo $line | cut -d "#" -s -f 2)
  file=charts/${chart}/templates/${name}.yml

  curl -L -s ${url} > ${file}

  # escape existing go template so helm doesn't get confused
  cat ${file} | sed -e 's/{{/{{`{{/g' | sed -e 's/}}/}}`}}/g' > ${file}.tmp
  mv ${file}.tmp ${file}

  # apply ytt overlays
  ytt --ignore-unknown-comments -f overlays/ -f ${file} --file-mark $(basename ${file}):type=yaml-plain ${args} > ${file}.tmp
  mv ${file}.tmp ${file}
done < "charts/${chart}.yaml"

helm package ./charts/${chart} --destination ${destination} --version ${version}
