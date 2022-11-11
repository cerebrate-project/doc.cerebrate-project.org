mkdocs build
rsync -v -rz --checksum site/ circl@cppz.circl.lu:/var/www/doc.cerebrate-project.org/
