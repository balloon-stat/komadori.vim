#!/bin/sh

for ix in {1..300}
do
  usleep $(( $1 * 1000 ))
  count = `printf "%03d" ${ix}`
  name = ${2}komadori_${count}.gif
  import -silent -window $3 $4 ${name}
done
