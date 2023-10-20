new_images=$(git ls-files --others --exclude-standard -- "blog_assets/*")
for image_path in $new_images; do
  filename=$(basename "${image_path}")
  echo "![${filename}]({{site_url}}/${image_path})"
done
