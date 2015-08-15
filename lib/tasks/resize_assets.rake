task :resize_assets do
  %w(100x100_pathway_dirt.gif rotating_colors.png).each do |file|
    name = file.split('.')[0..-2].join('.')
    i=Magick::Image.read("./app/assets/images/#{file}")[0]
    (1..8).each do |scale|
      i.sample(scale).write("./app/assets/images/#{name}.x#{scale}.png")
    end
  end
end
Rake::Task['assets:precompile'].enhance ['resize_assets']

task :clear_resizes do
  Dir["./app/assets/images/*.x*.png"].each do |file|
    File.delete(file)
  end
end