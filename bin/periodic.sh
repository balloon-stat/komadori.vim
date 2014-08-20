#!/bin/sh

for ix in `seq 1 300`
do
  sleep $(( $1 / 1000 ))
  count=`printf "%03d" ${ix}`
  name=${2}komadori_${count}.gif
  import -silent -window $3 -crop  4 ${name}
done
