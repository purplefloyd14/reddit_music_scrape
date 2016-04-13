require "open-uri" #for getting the data from reddit
require 'json' #for parsing what is returned from reddit
require "tempfile" #working with the large amount of json from reddit
require "date" #month and year items
require "taglib" #tagging metadata
require "find" #for iterating through the songs in the folder
require "mechanize" #for downloading the image from the url
require "rmagick" #for adding text - used brew install gs to get it working.
include Magick


data_from_reddit = open("http://www.reddit.com/r/listentothis/top.json?sort=top&t=month&limit=30")
#gets top 20 posts from r/listentothis in the past month (usually) in tempfile format
image_from_reddit = open("http://www.reddit.com/r/earthporn/top.json?sort=top&t=month&limit=1")
#gets top 1 picture from r/earthporn from that month

month = Date::MONTHNAMES[Date.today.month]
year = Date.today.year
#the name of the current month

def get_pic(image_url_string, month, year)
  agent = Mechanize.new
  link = image_url_string
  agent.get(link).save "#{month}_#{year}_album_art.jpg"
end


def tag(month, year)
  image_data = File.open("./#{month}/#{month}_#{year}_with_text.jpg", 'rb') { |f| f.read }
  cover_art = TagLib::MP4::CoverArt.new(TagLib::MP4::CoverArt::JPEG, image_data)
  item = TagLib::MP4::Item.from_cover_art_list([cover_art])
  dir = "./#{month}/"
  Find.find(dir) do |song|
    next if song !~ /.m4a$/
    TagLib::MP4::File.open(song) do |el|
      tag = el.tag
      tag.album = "#{month} #{year}"
      tag.artist = "r/listentothis"
      tag.item_list_map.insert('covr', item)
      el.save
    end
    # Load an ID3v2 tag from a file
    # File is automatically closed at block end
  end
end  # File is automatically closed at block end

def add_text_to_pic(month, year)
  colors = ["blue", "red", "green", "orange", "yellow", "pink", "purple", "white", "black"]
  img = ImageList.new("./#{month}_#{year}_album_art.jpg")
  txt = Draw.new
  img.annotate(txt,0,0,0,0, "r/listentothis\n#{month}\n#{year}") do
    txt.font_family = 'Helvetica'
    txt.fill = colors.sample
    txt.pointsize = 114
    txt.font_weight = BoldWeight
    txt.gravity = CenterGravity
  end
  img.write("./#{month}/#{month}_#{year}_with_text.jpg")
end

def parse_img_data(image_from_reddit)
  objectified_image_data = make_object(image_from_reddit)
  return find_urls(objectified_image_data)[0]
end

def delete_original_pic
  `rm ./*.jpg`
end


def make_object(data)
  ## this method takes what the reddit api returns, determines its type,
  ## does the appropriate ready-ing (usually tempfile -> string -> JSONparse -> Hash)
  if data.class == Tempfile
    p "temp"
    closer =  IO.read(data.path)
    ready_version = JSON.parse(closer)
    return ready_version
  elsif data.class == StringIO
    p "stringIO"
    ready_version = JSON.parse(data.string)
    return ready_version
  end
end


def parse_img_data(image_from_reddit)
  objectified_image_data = make_object(image_from_reddit)
  return find_urls(objectified_image_data)[0]
end


def find_urls(data_object)
  #this method iterates through the data object for each post it is given
  #then it adds all of the urls from the data to an array and returns that array
  all_urls = []
  data_object["data"]["children"].each do |post|
    all_urls << post["data"]["url"]
  end
  return all_urls
  #also scrape artist and song title? Could be useful for naming
  #Would use reddit "title" and a regex
end

def make_dir(month)
  `mkdir #{month}` #creates directory with same name as current month
end


def run_download(url, month) #downloads url audio source as m4a, adds it to month directory
  `youtube-dl -x -i -f 140 -o\'./#{month}/%(title)s.%(ext)s\' #{url}`
end


def add_to_itunes(month) #adds month folder to itunes library
  `mv ./#{month}/ ~/Music/iTunes/iTunes\\ Media/Automatically\\ Add\\ to\\ iTunes.localized/`
end

def download_urls(url_array, month)
  url_array.each_with_index do |url, idx|
    count = Dir["./#{month}/**/*"].length
    if count < 20
      run_download(url, month)
    end
  end
end





def execute_everything(month, data_from_reddit, image_from_reddit, year)
  make_dir(month) #create dir for month
  objectified_data = make_object(data_from_reddit) #make reddit data an object
  url_array = find_urls(objectified_data) #scrapes all urls from object, returns array of urls
  download_urls(url_array, month) #download songs from url array
  image_url = parse_img_data(image_from_reddit) #get image from reddit
  get_pic(image_url, month, year) #saves image to current directory
  add_text_to_pic(month, year) #adds text to image
  delete_original_pic #deletes original image
  tag(month, year) #adds metadata tags for album, artist, cover art
  add_to_itunes(month) #adds everything to itunes
  #still need
    # run once per month
end

execute_everything(month, data_from_reddit, image_from_reddit, year)
