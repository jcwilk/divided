task :resize_assets do
  (1..8).each do |scale|
    i=Magick::Image.read('./app/assets/images/rotating_colors.png')[0]
    i.filter = Magick::PointFilter
    cols = i.columns
    rows = i.rows
    i.resize!(cols*scale,rows*scale)
    i.write("./app/assets/images/rotating_colors.x#{scale}.gif")
  end
end

Rake::Task['assets:precompile'].enhance ['resize_assets']