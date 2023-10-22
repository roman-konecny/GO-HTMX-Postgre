#!/bin/bash

# Welcome into init_web_project.sh script!
# 
# Here we initialize all necesarry things for a new project.
# Requirements:
# - Docker
# - Go
# Initialization includes:
# - creating directories
# - creating files
# - initializing PostgreSQL database with Docker
# - initializing go mod if it's not already initialized
# - downloading htmx.min.js
# - creating main.go
# - creating index.html and reset.css
# - creating README.md
# - creating architecture.md
#
# Only thing you need to do is to run this script in the root of your project.

# Get the current directory name as the project name
PROJECT_NAME=$(basename "$PWD")

# Function to create directories
create_directories() {
    mkdir -p cmd/$PROJECT_NAME \
             api \
             web/templates \
             web/fragments \
             web/static/css \
             web/static/js \
             web/static/images \
             features/users \
             features/products \
             features/orders \
             internal/middleware \
             database/migrations \
             database/seeds \
             config \
             tests \
             scripts \
             docs
}

# Function to create files
create_files() {
    touch cmd/$PROJECT_NAME/main.go \
          api/endpoints.go \
          web/templates/some_template.html \
          features/users/users.go \
          features/products/products.go \
          features/orders/orders.go \
          database/migrations/some_migration.sql \
          database/seeds/some_seed.sql \
          config/config.yaml \
          tests/some_test.go \
          scripts/build.sh \
          docs/README.md
}

# Function to initialize PostgreSQL database with Docker
init_postgres_docker() {
    DB_NAME="${PROJECT_NAME}_db"
    DB_USER="${PROJECT_NAME}_user"
    DB_PASS="admin"  # Change this password as needed
    CONTAINER_NAME="${PROJECT_NAME}_db_container"

    # Pull the PostgreSQL image
    docker pull postgres:latest

    # Run a new PostgreSQL container
    docker run --name $CONTAINER_NAME -e POSTGRES_PASSWORD=$DB_PASS \
               -e POSTGRES_USER=$DB_USER -e POSTGRES_DB=$DB_NAME \
               -p 5432:5432 -d postgres:latest

    echo "PostgreSQL Docker container '$CONTAINER_NAME' has been created and configured."
}

# Function to download htmx.min.js
download_htmx() {
    wget -O web/static/js/htmx.min.js https://unpkg.com/htmx.org@1.6.1
    echo "htmx.min.js downloaded to web/static/js/"
}

# Function to create main.go
create_main_go() {
    cat <<EOL > cmd/$PROJECT_NAME/main.go
package main

import (
	"html/template"
	"log"
	"net/http"
)

func main() {
	http.Handle("/static/",
		http.StripPrefix("/static/", http.FileServer(http.Dir("web/static"))))

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		tmpl := template.Must(template.ParseFiles("web/templates/index.html"))
		tmpl.Execute(w, nil)
	})

	log.Println("App running on 3000...")
	log.Fatal(http.ListenAndServe(":3000", nil))
}
EOL

    echo "main.go has been created."
}

# Function to create index.html and reset.css
create_html_and_css() {
    # index.html
    cat <<EOL > web/templates/index.html
<!DOCTYPE html>
<html>
<head>
    <title>$PROJECT_NAME</title>
    <link rel="stylesheet" href="/static/css/reset.css">
    <script src="/static/js/htmx.min.js"></script>
</head>
<body>
    <h1>$PROJECT_NAME</h1>
</body>
</html>
EOL

    # reset.css
    cat <<EOL > web/static/css/reset.css
*, *::before, *::after {
box-sizing: border-box;
}
* {
margin: 0;
}
body {
line-height: calc(1em + 0.5rem);
-webkit-font-smoothing: antialiased;
}
img, picture, video, canvas, svg {
display: block;
max-width: 100%;
}
input, button, textarea, select {
font: inherit;
}
p, h1, h2, h3, h4, h5, h6 {
overflow-wrap: break-word;
}
#root, #__next {
isolation: isolate;
}
EOL

    echo "index.html and reset.css have been created."
}

# Function to add markdown file to docs directory with prepared content
create_readme() {
    cat <<EOL > docs/README.md
# $PROJECT_NAME

## Description
This is a web application written in Go. It uses PostgreSQL database and Docker for containerization.
Other than that it uses htmx for dynamic HTML and basic CSS.

Creation process of this project can be found in /scripts/init_web_project.sh
EOL

    echo "README.md has been created."
}

# Function to create architecture.md
create_architecture() {
    cat <<EOL > docs/architecture.md
# Project Architecture

This document outlines the directory structure of the project.

## Directory Structure

- your_project_root_directory
    - api                     # API endpoint definitions and protocol files (such as gRPC .proto files)
    - cmd                     # Entrypoints of the application
        - your_app_name       # Main application entrypoint
            - main.go         # The main application file
    - config                  # Configuration files (e.g., YAML or JSON files)
    - database                # Database-related files
        - migrations          # Database migration files
        - seeds               # Database seeding files
    - docs                    # Documentation files
        - architecture.md     # This file
    - features                # Feature-based directory
        - users               # User-related backend files (e.g., models, controllers)
        - products            # Product-related backend files
        - orders              # Order-related backend files
    - internal                # Private application and library code
        - middleware          # Middleware functions or packages
    - scripts                 # Scripts for various purposes (e.g., deployment, database management)
    - tests                   # Test files
    - web                     # Web-related files
        - static              # Static files (CSS, JS, images)
            - css             
            - js              
            - images          
        - templates           # HTML templates
        - fragments           # HTML fragments
EOL

    echo "architecture.md has been created."
}


# Function to initialize go mod if it's not already initialized
init_go_mod() {
    if [ ! -f "go.mod" ]; then
        go mod init $PROJECT_NAME
    fi
}

# Execute the functions
create_directories
create_main_go
init_go_mod
init_postgres_docker
create_files
download_htmx
create_html_and_css
create_readme
create_architecture

echo "Project $PROJECT_NAME has been initialized in the current directory."

# move the script itself into scripts directory
mv init_web_project.sh scripts/

go run cmd/$PROJECT_NAME/main.go