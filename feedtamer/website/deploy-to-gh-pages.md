# Deploying Feedtamer Website to GitHub Pages

Follow these steps to deploy the Feedtamer website to GitHub Pages:

## 1. Create a GitHub Repository

1. Go to [GitHub](https://github.com) and sign in to your account
2. Click the "+" icon in the top right corner and select "New repository"
3. Name your repository `feedtamer` (or any name you prefer)
4. Set it to Public
5. Do not initialize it with a README, .gitignore, or license
6. Click "Create repository"

## 2. Push Your Code to GitHub

Run these commands, replacing `YOUR-USERNAME` with your GitHub username:

```bash
git remote add origin https://github.com/YOUR-USERNAME/feedtamer.git
git branch -M main
git push -u origin main
```

## 3. Configure GitHub Pages

1. Go to your repository on GitHub
2. Click on "Settings"
3. Scroll down to the "GitHub Pages" section
4. Under "Source", select the branch (main) and folder (root) where your website files are located
5. Click "Save"

## 4. View Your Website

After a few minutes, your website will be published at:
https://YOUR-USERNAME.github.io/feedtamer/

## 5. Custom Domain (Optional)

If you have a custom domain, you can configure it:

1. In the GitHub Pages section of Settings, enter your domain in the "Custom domain" field
2. Click "Save"
3. At your domain registrar, create a CNAME record pointing to YOUR-USERNAME.github.io

## Updating the Website

Whenever you want to update the website:

1. Make your changes locally
2. Commit them:
   ```bash
   git add .
   git commit -m "Description of changes"
   ```
3. Push to GitHub:
   ```bash
   git push origin main
   ```

The updates will be automatically deployed to GitHub Pages.