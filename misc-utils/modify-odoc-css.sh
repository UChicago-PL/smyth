#!/bin/bash

cd _build/default/_doc/_html

echo '' >> odoc.css
echo '/* Custom Modifications */' >> odoc.css
echo '' >> odoc.css

echo 'b { font-weight: 600; }' >> odoc.css
echo 'em { font-style: normal; font-variant: small-caps; }' >> odoc.css
echo '.content > header + aside { margin-top: -15px; }' >> odoc.css
