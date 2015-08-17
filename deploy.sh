# deploy.sh

# Build Jekyll static site
( cd _static/ ; jekyll build --destination ../public )

# Push to Cloud Foundry
cf push
