#!/usr/bin/env python3

import sys

from bs4 import BeautifulSoup

main_dir = sys.argv[1]

with open(main_dir + "/smyth/Smyth/index.html") as index_file:
    index = index_file.read()

soup = BeautifulSoup(index, "html.parser")

for module in soup.find_all(class_="spec module"):
    module_name = module.get("id")[7:]
    module_filename = main_dir + "/smyth/Smyth/" + module_name + "/index.html"
    with open(module_filename) as module_file:
        module_content = module_file.read()
    module_soup = BeautifulSoup(module_content, "html.parser")

    description = module_soup.find("aside")
    if description is None:
        continue
    actual_description = description.contents[0]
    for a in actual_description.find_all("a"):
        a["href"] = a["href"][3:]

    place_for_description = module.next_sibling
    place_for_description.append(actual_description)

print(soup)
