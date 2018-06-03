default:
	@echo "specify what you want to make"

blog-index:
	@./scripts/generate_blog_index.sh

blog-posts:
	@./scripts/generate_blog_posts.sh

blog-tags:
	@./scripts/generate_blog_tags.sh

blog: blog-index blog-posts blog-tags

homepage:
	@./scripts/generate_home.sh

pages:
	@./scripts/generate_pages.sh
	@./scripts/generate_pages.sh private/ ../
	@./scripts/generate_pages.sh archive/ ../

all: pages blog sitemap

sitemap:
	@find . -name "*.html" | \
		sed 's/^.\//http:\/\/aaronsplace.co.uk\//' | \
		grep -ve private -e archive -e google | \
		sort > sitemap.txt

clean:
	@find . -name "*.md5" -print -delete

public:
	@chmod o+r -R .
	@gpg2 --yes --default-key 32716A1F --detach-sig -o index.asc index.html
	@rsync -av --delete . \
		escher.rhwyd.co.uk:/var/www/htdocs/aaronsplace.co.uk

