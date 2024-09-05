DATE=$(curl -s -L \
-H "Accept: application/vnd.github+json" \
-H "Authorization: Bearer ${GITHUBTOKEN}" \
-H "X-GitHub-Api-Version: 2022-11-28" \
https://api.github.com/repos/opicron/cloudways_bashrc/commits/main | grep \"date\" | head -n 1 | cut -d'"' -f4)

echo $(date -d $DATE +%s)
