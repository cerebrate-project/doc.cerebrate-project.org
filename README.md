# Cerebrate Project Documentation

This repository contains all [doc.cerebrate-project.org](https://doc.cerebrate-project.org/) website. The website use mkdocs and [mkdocs-material](https://squidfunk.github.io/mkdocs-material/) which are the requirements to build this website.

## Building and testing the website

- `mkdocs build`
- `mkdocs serve` to test locally the documentation website

## Deployment (CIRCL)

`rsync -v -rz --checksum site/ circl@cppz.circl.lu:/var/www/doc.cerebrate-project.org/` You need the proper access to do the deployment.
