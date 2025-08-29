rm -rf .git
git init
git checkout -b master
git add .
git commit -m "Reinitialized repo"
git remote add origin git@github.com:DT9/homelab.git 
git push --force --set-upstream origin master

