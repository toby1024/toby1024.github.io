Dir["_posts/*"].each do |file|
  content = File.read(file)

  content.gsub!(/\{%\s*img\s+([^\s%]+).*?%\}/) do
    "![image](#{$1})"
  end

  File.write(file, content)
end

