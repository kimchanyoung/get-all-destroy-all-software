require 'nokogiri'
require 'open-uri'

abs_dir_to_save_files = ARGV[0]

unless abs_dir_to_save_files
  puts "Please supply a path to save downloads"
  exit 1
end

unless File.exist?(abs_dir_to_save_files)
  puts "Creating #{abs_dir_to_save_files}"
  Dir.mkdir(abs_dir_to_save_files)
end

MAIN_PAGE = "https://www.destroyallsoftware.com"
main_page = Nokogiri::HTML(open("#{MAIN_PAGE}/screencasts/catalog"))

puts "Getting all screencast links..."
# Parse thru main page to pull all screencast links
links = main_page.css('.episode a').map do |e|
  link = e.attributes['href'].value
  { link: link, name: link.split("/").last }
end

links.each_slice(4) do |group|
  group.map do |hash|
    next if File.exist?("#{abs_dir_to_save_files}/#{hash[:name]}.mp4")

    Thread.new(abs_dir_to_save_files, hash) do
      begin
        puts "Opening screencast #{hash[:name]}"
        sub_page = Nokogiri::HTML(open("#{MAIN_PAGE}#{hash[:link]}"))

        extracted_video_link = sub_page.css('script')[1]
          .children
          .first
          .content
          .scan(/src = \"(.*)\"/)
          .first
          .first # second for 1040

        puts "Saving screencast #{hash[:name]}..."
        # Make destination DIR before running program
        download = open("#{MAIN_PAGE}#{extracted_video_link}")
        IO.copy_stream(download, "#{abs_dir_to_save_files}/#{hash[:name]}.mp4")
        puts "Saved #{hash[:name]}!"
      rescue OpenURI::HTTPError => ex
        puts "Errors downloading #{hash[:name]} - #{ex.inspect}"
        next
      end
    end
  end.compact.each(&:join)
end

puts "Done!"
