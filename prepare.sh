#!/bin/bash

chart=$1

# download config and apply overlays
# TODO remove fallback fetch that bypasses ytt
# cat projectriff.manifest | xargs -L1 sh -c 'echo "curl -L $$1 | ytt -f overlays/ --ignore-unknown-comments -f - > projectriff/templates/$$0.yml || curl -L $$1 > projectriff/templates/$$0.yml"' | sh

while IFS= read -r line
do
  arr=($line)
  name=${arr[0]%?}
  url=${arr[1]}
  file=${chart}/templates/${name}.yml

  curl -L ${url} > ${file}

  # escape existing go template
  cat ${file} | sed -e 's/{{/{{`{{/g' | sed -e 's/}}/}}`}}/g' > ${file}.tmp
  mv ${file}.tmp ${file}

  # apply ytt overlays
  if ytt --ignore-unknown-comments -f overlays/ -f ${file} --file-mark $(basename ${file}):type=yaml-plain > ${file}.tmp ; then
    mv ${file}.tmp ${file}
  else
    # TODO remove recovery
    rm ${file}.tmp
  fi
  
done < "${chart}.yaml"
