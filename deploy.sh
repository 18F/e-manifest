# deploy.sh

# Build Jekyll static site
( cd public/ ; jekyll build )

# Push to Cloud Foundry
cf push
