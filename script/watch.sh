#!/bin/bash

cd public
coffee -l -w -c -b -o js/ cs/ & 
compass watch
