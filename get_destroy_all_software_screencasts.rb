require 'byebug'
require 'nokogiri'
require 'open-uri'
# Get all links

MAIN_PAGE = "https://www.destroyallsoftware.com"
main_page = Nokogiri::HTML(open("#{MAIN_PAGE}/screencasts/catalog"))

puts "Getting all screencast links..."
# Parse thru main page to pull all screencast links
links = main_page.css('.episode a').map do |e|
  link = e.attributes['href'].value
  { link: link, name: link.split("/").last }
end

links.each do |hash|
  puts "Opening screencast #{hash[:name]}"
  sub_page = Nokogiri::HTML(open("#{MAIN_PAGE}#{hash[:link]}"))

  extracted_video_link = sub_page.css('script')[1].children.first.content.scan(/src = \"(.*)\"/).first.first # second for 1040
  
  puts "Saving screencast #{hash[:name]}..."
  # Make destination DIR before running program
  download = open(extracted_video_link)
  IO.copy_stream(download, "/Users/chan/Downloads/destroy_all_software/#{hash[:name]}.mp4")
  puts "Saved!"
end

puts "Done!"
