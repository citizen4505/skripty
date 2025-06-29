#create a new repository on the command line
#!/bin/bash
echo "# new repository" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/:user/:repo.git
git push -u origin main
