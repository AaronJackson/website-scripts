default:
	@echo "specify what you want to make"

blog-index:
	@./scripts/generate_blog_index.sh

blog-posts:
	@./scripts/generate_blog_posts.sh

blog-tags:
	@./scripts/generate_blog_tags.sh

blog: blog-index blog-posts blog-tags

pages:
	@./scripts/generate_pages.sh
	@./scripts/generate_pages.sh private/ ../
	@./scripts/generate_pages.sh archive/ ../

all: pages blog

clean:
	@find . -name "*.md5" -print -delete

public:
	@chmod o+r -R .
	@rsync -av --delete . escher.rhwyd.co.uk:/var/www/htdocs/aaronsplace.co.uk

