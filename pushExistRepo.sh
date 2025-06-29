# push an existing repository from the command line
#!/bin/bash
git remote add origin https://github.com/:user/:repo.git
git branch -M main
git push -u origin main
