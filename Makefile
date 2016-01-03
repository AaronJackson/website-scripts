default:
	@echo "specify what you want to make"

blog-index:
	./scripts/generate_blog_index.sh

blog-posts:
	./scripts/generate_blog_posts.sh

blog-tags:
	./scripts/generate_blog_tags.sh

blog: blog-index blog-posts blog-tags

pages:
	./scripts/generate_pages.sh

all: pages blog

publish:
	cd ~/public_html/
	chmod o+r -R .
	rsync -av --delete . aaronsplace.co.uk:/var/www/html/
