#!/bin/bash 

removes_shortest_part_of_pattern_from_front="removes_shortest_part_of_pattern_from_front"
removes_the_longest_part_of_the_pattern_from_front="removes_the_longest_part_of_the_pattern_from_front"

echo "removes_shortest_part_of_pattern_from_front = ""${removes_shortest_part_of_pattern_from_front#*_}"
echo "removes_the_longest_part_of_the_pattern_from_front = ${removes_the_longest_part_of_the_pattern_from_front##*_}"

