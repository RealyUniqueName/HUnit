#!/bin/bash

rm hunit.zip
zip -r hunit.zip src README.md LICENSE extraParams.hxml haxelib.json > /dev/null
haxelib submit hunit.zip