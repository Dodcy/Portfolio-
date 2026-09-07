#!/bin/bash

sample_name="Single cell seq"
Sample_type="DNA/RNA"

if [ "$Sample_type" == "DNA" ]
then echo "The sample is DNA"
else echo "The sample is not DNA"
fi
