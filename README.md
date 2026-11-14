# notes.rigascg.com

Teaching notes (bibliography, lecture material) for students. Minimal Jekyll site in the style of [rigascg.com](https://rigascg.com), edited with
[Sveltia CMS](https://sveltiacms.app) and deployed to GitHub Pages by GitHub Actions.
Not linked from the portfolio and marked `noindex` (not listed by search engines).

## Editing

Open <https://notes.rigascg.com/admin/>, choose **Sign In Using Access Token** and paste a fine-grained
GitHub token with *Contents: read and write* on this repository. Every save is a commit to `main`;
the site rebuilds in about a minute.

## Working locally

```sh
bundle install
bundle exec jekyll serve   # http://localhost:4000
```
