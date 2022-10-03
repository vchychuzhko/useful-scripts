#!/bin/bash

ES_SERVER='http://127.0.0.1:9200'
ES_INDEX_PREFIX='vue_storefront_magento_default'
ES_INDICES_STR=`curl -XGET ${ES_SERVER}/_cat/indices`
ES_ALIASES_STR=`curl -XGET ${ES_SERVER}/_cat/aliases`
ES_INDICES=()
ES_ALIASES=()


for i in $(echo $ES_INDICES_STR | tr "\n" "\n")
do
  if [[ $i == *$ES_INDEX_PREFIX* ]]; then
    ES_INDICES+=($i)
  fi
done

for i in $(echo $ES_ALIASES_STR | tr "\n" "\n")
do
  if [[ $i == *$ES_INDEX_PREFIX* ]]; then
    ES_ALIASES+=($i)
  fi
done

for INDEX_NAME in ${ES_INDICES[@]}; do
  if ! [[ " ${ES_ALIASES[*]} " =~ " ${INDEX_NAME} " ]]; then
    curl -XDELETE ${ES_SERVER}/$INDEX_NAME >> /dev/null
    printf "INDEX \033[0;33m${INDEX_NAME}\033[0m: STATUS \033[0;32mDELETED\033[0m\n"
  fi
done
