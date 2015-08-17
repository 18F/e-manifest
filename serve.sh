# serve.sh

# Build Jekyll static site
( cd _static/ ; jekyll build --destination ../public )

# Start Ruby app
rackup
